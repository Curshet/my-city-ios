import Foundation
import Combine

final class AppRouteManager: NSObject, AppRouteManagerProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppRouteManagerInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AppRouteManagerExternalEvent, Never>
    
    @ReadHoldsOptional private var userActivity: AppRouteManagerExternalEvent?
    private let externalPublisher: PassthroughSubject<AppRouteManagerExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    override init() {
        self.internalEventPublisher = PassthroughSubject<AppRouteManagerInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AppRouteManagerExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
}

// MARK: Private
private extension AppRouteManager {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AppRouteManagerInternalEvent) {
        switch event {
            case .request:
                requestHandler()
            
            case .deepLink(let url):
                deepLinkHandler(url)
            
            case .universalLink(let userActivity):
                universalLinkHandler(userActivity)
        }
    }
    
    func requestHandler() {
        guard let userActivity else { return }
        externalPublisher.send(userActivity)
        self.userActivity = nil
    }
    
    func deepLinkHandler(_ url: URL) {
        let string = url.absoluteString
        logger.console(event: .any(info: AppRouteManagerMessage.deepLinkCase + string))
        
        guard !string.isEmpty() else {
            logger.console(event: .error(info: AppRouteManagerMessage.deepLinkError))
            return
        }
        
        deepPathHandler(string)
    }
    
    func deepPathHandler(_ value: String) {
        let prefix = "sevtech://"
        let route = prefix + "sevtech.org/mobileLink/"
        
        switch value.hasPrefix(prefix) {
            case true:
                guard let path = value.components(separatedBy: route).last, path.hasPrefix(URL.Universal.telegramBot) else { fallthrough }
                universalPathHandler(path)
            
            case false:
                logger.console(event: .error(info: AppRouteManagerMessage.deepLinkFail))
        }
    }
    
    func universalLinkHandler(_ userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
            logger.console(event: .error(info: AppRouteManagerMessage.userActivityFail + String(userActivity.activityType)))
            return
        }
        
        let string = String(userActivity.webpageURL?.absoluteString)
        let prefix = URL.Universal.prefix
        logger.console(event: .any(info: AppRouteManagerMessage.universalLinkCase + string))
        
        guard !string.isEmptyContent, string.hasPrefix(prefix) else {
            logger.console(event: .error(info: AppRouteManagerMessage.universalPrefixError + string))
            return
        }
        
        guard let path = string.components(separatedBy: prefix).last, !path.isEmpty() else {
            logger.console(event: .error(info: AppRouteManagerMessage.universalPathError + string))
            return
        }
        
        universalPathHandler(path)
    }
    
    func universalPathHandler(_ value: String) {
        lazy var completion: ((AppRouteManagerExternalEvent) -> Void) = { [weak self] in
            self?.userActivity = $0
            self?.externalPublisher.send($0)
        }
        
        switch true {
            case _ where value.hasPrefix(URL.Universal.telegramBot):
                guard let path = value.components(separatedBy: URL.Universal.telegramBot).last?.base64Decoded(), !path.isEmpty() else { break }
                completion(.authorization(path))
                return
                
            case _ where value.hasPrefix(URL.Universal.intercom):
                guard let path = value.components(separatedBy: URL.Universal.intercom).last, !path.isEmpty() else { break }
                completion(.intercom(path))
                return
                
            case _ where value.hasPrefix(URL.Universal.sbp):
                guard let path = value.components(separatedBy: URL.Universal.sbp).last, !path.isEmpty() else { break }
                completion(.payment(.sbp(path)))
                return
           
            case _ where value.hasPrefix(URL.Universal.paymentSuccess):
                guard let path = value.components(separatedBy: URL.Universal.paymentSuccess).last, !path.isEmpty() else { break }
                completion(.payment(.success(path)))
                return
            
            case _ where value.hasPrefix(URL.Universal.paymentError):
                guard let path = value.components(separatedBy: URL.Universal.paymentError).last, !path.isEmpty() else { break }
                completion(.payment(.error(path)))
                return

            default:
                break
        }
        
        userActivity = nil
        logger.console(event: .error(info: AppRouteManagerMessage.universalLinkFail))
    }
    
}

// MARK: - AppRouteManagerMessage
fileprivate enum AppRouteManagerMessage {
    static let userActivityFail = "Application can't handle the user activity with type: "
    static let deepLinkCase = "Application has taken an activity from the deep link: "
    static let deepLinkError = "Incorrect empty value of the deep link"
    static let deepLinkFail = "Application can't handle the case of a deep link"
    static let universalLinkCase = "Application has taken an activity from the universal link: "
    static let universalPrefixError = "Incorrect prefix of the universal link: "
    static let universalPathError = "Incorrect path of the universal link: "
    static let universalLinkFail = "Application can't handle the case of a universal link"
}

// MARK: - AppRouteManagerInternalEvent
enum AppRouteManagerInternalEvent {
    case request
    case deepLink(URL)
    case universalLink(NSUserActivity)
}

// MARK: - AppRouteManagerExternalEvent
enum AppRouteManagerExternalEvent: Equatable {
    case authorization(String)
    case intercom(String)
    case payment(AppRouteManagerPayment)
}

// MARK: - AppRouteManagerPayment
enum AppRouteManagerPayment: Equatable {
    case sbp(String)
    case success(String)
    case error(String)
}
