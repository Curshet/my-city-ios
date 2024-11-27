import UIKit
import Combine

class SplashRouter: ScreenRouter, SplashRouterProtocol {
    
    let internalEventPublisher: PassthroughSubject<SplashRouterInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<SplashRouterExternalEvent, Never>

    private weak var viewController: UIViewController?
    private let builder: SplashBuilderRoutingProtocol
    private let externalPublisher: PassthroughSubject<SplashRouterExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(builder: SplashBuilderRoutingProtocol, notificationsManager: AppNotificationsManagerPresentProtocol, displaySpinner: DisplaySpinnerProtocol, application: ApplicationProtocol) {
        self.builder = builder
        self.internalEventPublisher = PassthroughSubject<SplashRouterInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<SplashRouterExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
        setupObservers()
    }
    
}

// MARK: Private
private extension SplashRouter {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: SplashRouterInternalEvent) {
        switch event {
            case .inject(let value):
                setupDependencies(value)
            
            case .start:
                externalPublisher.send(.start)
            
            case .transition(let type):
                transition(type)

            case .exit:
                externalPublisher.send(.exit)
        }
    }
    
    func setupDependencies(_ value: UIViewController) {
        guard viewController == nil else { return }
        
        guard let window = builder.window() else {
            logger.console(event: .error(info: SplashRouterMessage.windowError))
            return
        }
        
        viewController = value
        window.rootViewController = viewController
    }
    
    func transition(_ type: SplashRouterTransition) {
        guard let viewController else {
            logger.console(event: .error(info: SplashRouterMessage.viewControllerError))
            return
        }
        
        switch type {
            case .alert(let content):
                alert(builder, viewController, content)
            
            case .settings:
                open(path: URL.Settings.airplaneMode)
        }
    }
    
    func alert(_ builder: SplashBuilderRoutingProtocol, _ viewController: UIViewController, _ content: AlertContent) {
        guard let alertController = builder.alertController(content) else {
            logger.console(event: .error(info: SplashRouterMessage.alertControllerError))
            return
        }
        
        present(in: viewController, the: alertController)
    }
    
}

// MARK: - SplashRouterMessage
fileprivate enum SplashRouterMessage {
    static let windowError = "Splash router doesn't have a window"
    static let viewControllerError = "Splash router doesn't have a view controller"
    static let alertControllerError = "Splash router doesn't have an alert controller"
}

// MARK: - SplashRouterInternalEvent
enum SplashRouterInternalEvent {
    case inject(viewController: UIViewController)
    case start
    case transition(SplashRouterTransition)
    case exit
}

// MARK: - SplashRouterTransition
enum SplashRouterTransition {
    case alert(AlertContent)
    case settings
}

// MARK: - SplashRouterExternalEvent
enum SplashRouterExternalEvent: Equatable {
    case start
    case exit
}
