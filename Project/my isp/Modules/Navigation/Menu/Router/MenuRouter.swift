import UIKit
import Combine

class MenuRouter: ScreenRouter, MenuRouterProtocol {
    
    let internalEventPublisher: PassthroughSubject<MenuRouterInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MenuRouterExternalEvent, Never>
    
    private weak var tabBarController: AppTabBarControllerProtocol?
    private weak var builder: MenuBuilderRoutingProtocol?
    private let externalPublisher: PassthroughSubject<MenuRouterExternalEvent, Never>
    private var state: MenuRouterState
    private var subscriptions: Set<AnyCancellable>
    
    init(builder: MenuBuilderRoutingProtocol, notificationsManager: AppNotificationsManagerPresentProtocol, displaySpinner: DisplaySpinnerProtocol, application: ApplicationProtocol) {
        self.builder = builder
        self.internalEventPublisher = PassthroughSubject<MenuRouterInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MenuRouterExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.state = .catalog
        self.subscriptions = Set<AnyCancellable>()
        super.init(notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
        setupObservers()
    }

}

// MARK: Private
private extension MenuRouter {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MenuRouterInternalEvent) {
        switch event {
            case .inject(let value):
                setupDependencies(value)
            
            case .transition(let type):
                transition(type)
            
            case .output(let value):
                externalPublisher.send(value)
        }
    }
    
    func setupDependencies(_ value: AppTabBarControllerProtocol) {
        guard tabBarController == nil else { return }
        
        tabBarController = value
        
        tabBarController?.publisher.sink { [weak self] in
            guard case let .didSelect(viewController) = $0 else { return }
            self?.changeState(viewController)
        }.store(in: &subscriptions)
    }
    
    func changeState(_ viewController: UIViewController) {
        switch viewController.tabBarItem.tag {
            case 0:
                state = .catalog
            
            case 1:
                state = .profile
            
            case 2:
                state = .chat
            
            case 3:
                state = .more
            
            default:
                break
        }
    }
    
    func transition(_ type: MenuRouterTransition) {
        guard let tabBarController, let view = tabBarController.view else {
            logger.console(event: .error(info: MenuRouterMessage.tabBarControllerError))
            return
        }
        
        guard let window = builder?.window, let keyView = window.rootViewController?.topViewController.view else {
            logger.console(event: .error(info: MenuRouterMessage.windowError))
            return
        }
        
        guard isPresentable(type) else {
            logger.console(event: .error(info: MenuRouterMessage.transitionError))
            return
        }
        
        switch type {
            case .shift(let type):
                shift(type, window, keyView, view)
            
            case .catalog:
                tabBarController.selectedIndex = 0
                state = .catalog
            
            case .profile:
                tabBarController.selectedIndex = 1
                state = .profile
            
            case .chat:
                tabBarController.selectedIndex = 2
                state = .chat
            
            case .more:
                tabBarController.selectedIndex = 3
                state = .more
            
            case .biometrics, .password:
                break
        }
    }
    
    func shift(_ type: MenuRouterShift, _ window: UIWindow, _ keyView: UIView, _ view: UIView) {
        switch type {
            case .login(let value):
                login(window, keyView, view, value)
            
            case .navigation(let value):
                navigation(window, keyView, value)
        }
    }
    
    func login(_ window: UIWindow, _ keyView: UIView, _ view: UIView, _ value: MenuLoginShift) {
        keyView.backgroundColor = keyView.backgroundColor?.withBrightness(value.keyViewBrightness)
        let keySnapshot = keyView.snapshotView(afterScreenUpdates: true)
        let viewSnapshot = view.snapshotView(afterScreenUpdates: true)
        viewSnapshot?.frame = value.viewFrameOne
        window.addSubview(keySnapshot)
        window.addSubview(viewSnapshot)
    
        animate(duration: value.duration) {
            keySnapshot?.frame = value.keyViewFrame
            viewSnapshot?.frame = value.viewFrameTwo
        } completion: {
            window.rootViewController = self.tabBarController
            keySnapshot?.removeFromSuperview()
            viewSnapshot?.removeFromSuperview()
            self.userNotification(.success(value.message))
        }
    }
    
    func navigation(_ window: UIWindow, _ keyView: UIView, _ value: MenuNavigationShift) {
        window.rootViewController = tabBarController
        window.addSubview(keyView)
        
        animate(duration: value.duration) {
            keyView.alpha = value.alpha
        } completion: {
            keyView.removeFromSuperview()
        }
    }

    func isPresentable(_ type: MenuRouterTransition) -> Bool {
        switch type {
            case .shift:
                true
            
            case .catalog:
                state != .security && state != .catalog
            
            case .profile:
                state != .security && state != .profile
            
            case .chat:
                state != .security && state != .chat
            
            case .more:
                state != .security && state != .more
            
            case .biometrics, .password:
                state != .security
        }
    }
    
}

// MARK: - MenuRouterMessage
fileprivate enum MenuRouterMessage {
    static let windowError = "Navigation menu router doesn't have a window"
    static let tabBarControllerError = "Navigation menu router doesn't have a view controller"
    static let transitionError = "Navigation menu router can't open another one active screen at the moment"
}

// MARK: - MenuRouterState
fileprivate enum MenuRouterState {
    case alert
    case catalog
    case profile
    case chat
    case more
    case security
}

// MARK: - MenuRouterInternalEvent
enum MenuRouterInternalEvent {
    case inject(tabBarController: AppTabBarControllerProtocol)
    case transition(MenuRouterTransition)
    case output(MenuRouterExternalEvent)
}

// MARK: - MenuRouterTransition
enum MenuRouterTransition {
    case shift(MenuRouterShift)
    case catalog
    case profile
    case chat
    case more
    case biometrics
    case password
}

// MARK: - MenuRouterShift
enum MenuRouterShift {
    case login(MenuLoginShift)
    case navigation(MenuNavigationShift)
}

// MARK: - MenuRouterExternalEvent
enum MenuRouterExternalEvent {
    case start(MenuCoordinatorStart)
    case trigger(AppInteractorActivity)
}
