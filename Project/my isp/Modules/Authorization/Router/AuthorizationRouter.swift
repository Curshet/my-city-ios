import UIKit
import Combine

class AuthorizationRouter: ScreenRouter, AuthorizationRouterProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationRouterInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AuthorizationRouterExternalEvent, Never>
    
    private weak var viewController: UIViewController?
    private let builder: AuthorizationBuilderRoutingProtocol
    private let externalPublisher: PassthroughSubject<AuthorizationRouterExternalEvent, Never>
    private var state: AuthorizationRouterState
    private var subscriptions: Set<AnyCancellable>
    
    init(builder: AuthorizationBuilderRoutingProtocol, notificationsManager: AppNotificationsManagerPresentProtocol, displaySpinner: DisplaySpinnerProtocol, application: ApplicationProtocol) {
        self.builder = builder
        self.internalEventPublisher = PassthroughSubject<AuthorizationRouterInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AuthorizationRouterExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.state = .root
        self.subscriptions = Set<AnyCancellable>()
        super.init(notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
        setupObservers()
    }
    
}

// MARK: Private
private extension AuthorizationRouter {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AuthorizationRouterInternalEvent) {
        switch event {
            case .inject(let value):
                guard viewController == nil else { return }
                viewController = value
            
            case .start(let type):
                start(type)
            
            case .transition(let type):
                transition(type)
            
            case .output(let value):
                externalPublisher.send(.output(value))
        }
    }
    
    func start(_ type: AuthorizationCoordinatorStart) {
        switch type {
            case .login:
                externalPublisher.send(.start(.login))
                
            case .logout:
                externalPublisher.send(.start(.logout))
        }
    }
    
    func transition(_ type: AuthorizationRouterTransition) {
        guard let window = builder.window, let keyView = window.rootViewController?.view else {
            logger.console(event: .error(info: AuthorizationRouterMessage.windowError))
            return
        }
        
        guard let viewController, let view = viewController.view else {
            logger.console(event: .error(info: AuthorizationRouterMessage.viewControllerError))
            return
        }
        
        guard isPresentable(type) else {
            logger.console(event: .error(info: AuthorizationRouterMessage.transitionError))
            return
        }
        
        switch type {
            case .shift(let type):
                shift(type, window, keyView, view)
            
            case .notify(let type):
                userNotification(type)
            
            case .spinner(let event):
                displaySpinner(event)
            
            case .open(let path):
                open(path: path)
            
            case .root:
                root(viewController)
            
            case .phone:
                phone(viewController)
            
            case .phoneCode:
                phoneCode(viewController)
        }
    }
    
    func isPresentable(_ type: AuthorizationRouterTransition) -> Bool {
        switch type {
            case .shift, .open, .notify, .spinner:
                true
            
            case .root:
                state != .root
            
            case .phone:
                state != .phone
            
            case .phoneCode:
                state != .phoneCode
        }
    }
    
    func shift(_ type: AuthorizationRouterShift, _ window: UIWindow, _ keyView: UIView, _ view: UIView) {
        switch type {
            case .login(let value):
                userLogin(window, keyView, value)
            
            case .logout(let value):
                userLogout(window, keyView, view, value)
        }
    }
    
    func userLogin(_ window: UIWindow, _ keyView: UIView, _ value: AuthorizationLoginShift) {
        window.rootViewController = viewController
        window.addSubview(keyView)
    
        animate(duration: value.duration) {
            keyView.alpha = value.alpha
        } completion: {
            keyView.removeFromSuperview()
        }
    }
    
    func userLogout(_ window: UIWindow, _ keyView: UIView, _ view: UIView, _ value: AuthorizationLogoutShift) {
        view.frame = value.viewFrameOne
        view.alpha = value.viewAlphaOne
        window.addSubview(view)
    
        animate(duration: value.duration) {
            view.frame = value.viewFrameTwo
            view.alpha = value.viewAlphaTwo
            keyView.frame = value.keyViewFrame
            keyView.alpha = value.keyViewAlpha
        } completion: {
            window.rootViewController = self.viewController
        }
    }
    
    func root(_ viewController: UIViewController) {
        guard let target = viewController.presentedViewController else {
            logger.console(event: .error(info: AuthorizationRouterMessage.viewControllerError))
            return
        }
        
        state = .root
        dismiss(target)
    }
    
    func phone(_ target: UIViewController) {
        guard state != .phoneCode else {
            state = .phone
            dismiss(target.topViewController)
            return
        }
        
        guard let viewController = builder.phoneNavigationController else {
            logger.console(event: .error(info: AuthorizationRouterMessage.viewControllerError))
            return
        }
    
        state = .phone
        present(in: target, the: viewController)
    }
    
    func phoneCode(_ viewController: UIViewController) {
        guard let target = viewController.presentedViewController, let viewController = builder.phoneCodeViewController else {
            logger.console(event: .error(info: AuthorizationRouterMessage.viewControllerError))
            return
        }
    
        state = .phoneCode
        present(in: target, the: viewController)
    }
    
}

// MARK: - AuthorizationRouterMessage
fileprivate enum AuthorizationRouterMessage {
    static let windowError = "Authorization router doesn't has a window"
    static let viewControllerError = "Authorization router doesn't have a view controller"
    static let transitionError = "Authorization router can't open another one active screen at the moment"
}

// MARK: - AuthorizationRouterState
fileprivate enum AuthorizationRouterState {
    case root
    case phone
    case phoneCode
}

// MARK: - AuthorizationRouterInternalEvent
enum AuthorizationRouterInternalEvent {
    case inject(viewController: UIViewController)
    case start(AuthorizationCoordinatorStart)
    case transition(AuthorizationRouterTransition)
    case output(AuthorizationRouterOutput)
}

// MARK: - AuthorizationRouterOutput
enum AuthorizationRouterOutput {
    case action(AuthorizationCoordinatorExternalEvent)
    case trigger(AuthorizationRouterTrigger)
}

// MARK: - AuthorizationRouterTrigger
enum AuthorizationRouterTrigger: Equatable {
    case route(Result<String, NSError>)
    case request
    case response
}

// MARK: - AuthorizationRouterTransition
enum AuthorizationRouterTransition {
    case shift(AuthorizationRouterShift)
    case notify(AppUserNotificationType)
    case spinner(DisplaySpinnerEvent)
    case open(String)
    case root
    case phone
    case phoneCode
}

// MARK: - AuthorizationRouterShift
enum AuthorizationRouterShift {
    case login(AuthorizationLoginShift)
    case logout(AuthorizationLogoutShift)
}

// MARK: - AuthorizationRouterExternalEvent
enum AuthorizationRouterExternalEvent {
    case start(AuthorizationCoordinatorStart)
    case output(AuthorizationRouterOutput)
}
