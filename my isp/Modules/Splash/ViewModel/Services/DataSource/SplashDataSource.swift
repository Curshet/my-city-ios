import UIKit
import Combine

class SplashDataSource: SplashDataSourceProtocol {
    
    let internalEventPublisher: PassthroughSubject<SplashDataSourceInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<SplashDataSourceExternalEvent, Never>
    
    private let device: DeviceProtocol
    private let screen: ScreenProtocol
    private let externalPublisher: PassthroughSubject<SplashDataSourceExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(device: DeviceProtocol, screen: ScreenProtocol) {
        self.device = device
        self.screen = screen
        self.internalEventPublisher = PassthroughSubject<SplashDataSourceInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<SplashDataSourceExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension SplashDataSource {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: SplashDataSourceInternalEvent) {
        switch event {
            case .view:
                let value = view()
                externalPublisher.send(.view(value))
            
            case .airplaneMode:
                let isEnabled = device.isAirplaneMode
                externalPublisher.send(.airplaneMode(isEnabled))
            
            case .alert(let type, let leftAction, let rightAction):
                let value = type == .airplaneMode ? airplaneMode(leftAction, rightAction) : connectionError(leftAction, rightAction)
                externalPublisher.send(.alert(value))
            
            case .exit:
                let value: SplashImageViewLayout? = screen.isLegacyPhone ? nil : SplashImageViewLayout()
                externalPublisher.send(.exit(value))
        }
    }
    
    func view() -> SplashViewData {
        let layout = SplashViewLayout()
        let image = UIImage.appLogo
        let data = SplashViewData(layout: layout, image: image)
        return data
    }
    
    func airplaneMode(_ leftAction: (() -> Void)?, _ rightAction: (() -> Void)?) -> AlertContent {
        let title = String.localized.splashAirplaneMode
        let message = "\(String.localized.splashAirplaneGuide)."
        let leftTitle = String.localized.okay
        let leftButton = AlertButton(title: leftTitle, style: .default, action: leftAction)
        let rightTitle = String.localized.settings
        let rightButton = AlertButton(title: rightTitle, style: .default, action: rightAction)
        let content = AlertContent(style: .alert, title: title, message: message, type: .twoButtons(left: leftButton, right: rightButton))
        return content
    }
    
    func connectionError(_ leftAction: (() -> Void)?, _ rightAction: (() -> Void)?) -> AlertContent {
        let title = String.localized.splashLostConnection
        let message = "\(String.localized.splashConnectionError)."
        let leftTitle = String.localized.okay
        let leftButton = AlertButton(title: leftTitle, style: .default, action: leftAction)
        let rightTitle = String.localized.tryAgain
        let rightButton = AlertButton(title: rightTitle, style: .default, action: rightAction)
        let content = AlertContent(style: .alert, title: title, message: message, type: .twoButtons(left: leftButton, right: rightButton))
        return content
    }
    
}

// MARK: - SplashDataSourceInternalEvent
enum SplashDataSourceInternalEvent {
    case view
    case airplaneMode
    case alert(type: SplashDataSourceAlertContent, leftAction: (() -> Void)?, rightAction: (() -> Void)?)
    case exit
}

// MARK: - SplashDataSourceAlertContent
enum SplashDataSourceAlertContent {
    case airplaneMode
    case connectionError
}

// MARK: - SplashDataSourceExternalEvent
enum SplashDataSourceExternalEvent {
    case view(SplashViewData)
    case airplaneMode(Bool)
    case alert(AlertContent)
    case exit(SplashImageViewLayout?)
}
