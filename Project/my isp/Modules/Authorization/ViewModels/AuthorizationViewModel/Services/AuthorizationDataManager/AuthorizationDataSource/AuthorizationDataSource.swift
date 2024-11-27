import UIKit
import Combine

class AuthorizationDataSource: AuthorizationDataSourceProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationDataSourceInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AuthorizationDataSourceExternalEvent, Never>
    
    var isLightMode: Bool {
        screen.isLightMode
    }
    
    private let screen: ScreenProtocol
    private let externalPublisher: PassthroughSubject<AuthorizationDataSourceExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(screen: ScreenProtocol) {
        self.screen = screen
        self.internalEventPublisher = PassthroughSubject<AuthorizationDataSourceInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AuthorizationDataSourceExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension AuthorizationDataSource {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AuthorizationDataSourceInternalEvent) {
        switch event {
            case .shift(let type):
                let value = start(type)
                externalPublisher.send(.shift(value))
            
            case .route(let value):
                let request = request(value)
                externalPublisher.send(.request(request))
            
            case .view:
                let value = view()
                externalPublisher.send(.view(value))
            
            case .telegram:
                let url = URL.Service.telegramBot
                externalPublisher.send(.telegram(url))
            
            case .notify(let type):
                let notify = notify(type)
                externalPublisher.send(.notify(notify))
        }
    }
    
    func start(_ type: AuthorizationCoordinatorStart) -> AuthorizationRouterShift {
        switch type {
            case .login:
                let value = login()
                return .login(value)
            
            case .logout:
                let value = logout()
                return .logout(value)
        }
    }
    
    func login() -> AuthorizationLoginShift {
        let duration = 0.5
        let alpha = 0.0
        let value = AuthorizationLoginShift(duration: duration, alpha: alpha)
        return value
    }
    
    func logout() -> AuthorizationLogoutShift {
        let duration = 0.45
        let screen = screen.bounds
        let viewFrameOne = CGRect(x: -screen.width, y: screen.minY, width: screen.width, height: screen.height)
        let viewAlphaOne = 0.8
        let viewAlphaTwo = 1.0
        let keyViewFrame = CGRect(x: screen.width, y: screen.minY, width: screen.width, height: screen.height)
        let keyViewAlpha = 0.3
        let value = AuthorizationLogoutShift(duration: duration, viewFrameOne: viewFrameOne, viewFrameTwo: screen, viewAlphaOne: viewAlphaOne, viewAlphaTwo: viewAlphaTwo, keyViewFrame: keyViewFrame, keyViewAlpha: keyViewAlpha)
        return value
    }
    
    func view() -> AuthorizationViewData {
        let layout = AuthorizationViewLayout()
        let header = headerSection()
        let center = centerSection()
        let data = AuthorizationViewData(layout: layout, header: header, center: center)
        return data
    }
    
    func headerSection() -> AuthorizationHeaderData {
        let layout = AuthorizationHeaderViewLayout()
        let image = UIImage.appLogo
        let text = String.localized.authorizationGreetingHeader
        let data = AuthorizationHeaderData(layout: layout, image: image, text: text)
        return data
    }
    
    func centerSection() -> AuthorizationCenterData {
        let layout = centerLayout()
        let telegramColor = UIColor.interfaceManager.white()
        let telegramIcon = UIImage.system(.paperplane).withTintColor(telegramColor)
        let telegramTitle = String.localized.authorizationTelegramLogin
        let separatingLine = String.init(repeating: "─", count: 9)
        let separatingText = separatingLine + " \(String.localized.authorizationOtherwise) " + separatingLine
        let phoneTitle = String.localized.authorizationPhoneLogin
        let data = AuthorizationCenterData(layout: layout, telegramIcon: telegramIcon, telegramTitle: telegramTitle, separatingText: separatingText, phoneTitle: phoneTitle)
        return data
    }
    
    func centerLayout() -> AuthorizationCenterViewLayout {
        let activitySize = CGSize(width: 40, height: 40)
        let activityColor = UIColor.interfaceManager.white()
        let activityIndicator = AppOverlayActivityIndicatorLayout(type: .medium, backgroundColor: .clear, color: activityColor, size: activitySize, cornerRadius: .zero)
        let backgroundColor = UIColor.interfaceManager.lightPurple()
        let overlay = AppOverlayViewLayout(activityIndicator: activityIndicator, effect: nil, backgroundColor: backgroundColor, cornerRadius: 10.fitWidth, startDelay: .zero, stopDelay: .zero)
        let telegramButton = AuthorizationCenterTelegramButtonLayout(overlay: overlay)
        let layout = AuthorizationCenterViewLayout(telegramButton: telegramButton)
        return layout
    }
    
    func request(_ value: String) -> AuthorizationNetworkRequest {
        let separated = value.components(separatedBy: "&")
        let phone = String(separated.first?.replacingOccurrences(of: "phone=", with: ""))
        let hash = String(separated.last?.replacingOccurrences(of: "hash=", with: ""))
        let path = URL.Server.telegramAuthorization
        let parameters = ["phone" : phone, "hash" : hash]
        let value = NetworkManagerRequest(type: .post, path: path, headers: .required, parameters: .value(parameters))
        let request = AuthorizationNetworkRequest(value: value, phone: phone)
        return request
    }
    
    func notify(_ type: NetworkManagerErrorType) -> AppUserNotificationType {
        switch type {
            case .request(let error):
                let description = error.localizedDescription.isEmpty() ? String.localized.authorizationError : error.localizedDescription
                let message = description + " (\(error.code))"
                return .error(message)
                
            case .system:
                let message = String.localized.authorizationError + " (\(NSError.system.code))"
                return .error(message)
        }
    }
    
}

// MARK: - AuthorizationDataSourceInternalEvent
enum AuthorizationDataSourceInternalEvent {
    case shift(AuthorizationCoordinatorStart)
    case route(String)
    case view
    case telegram
    case notify(NetworkManagerErrorType)
}

// MARK: - AuthorizationDataSourceExternalEvent
enum AuthorizationDataSourceExternalEvent {
    case shift(AuthorizationRouterShift)
    case view(AuthorizationViewData)
    case telegram(String)
    case request(AuthorizationNetworkRequest)
    case notify(AppUserNotificationType)
}
