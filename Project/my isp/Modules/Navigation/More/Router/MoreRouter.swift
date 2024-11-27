import UIKit
import Combine

class MoreRouter: ScreenRouter, MoreRouterProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreRouterInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AppInteractorActivity, Never>
    
    private weak var navigationController: AppNavigationControllerProtocol?
    private weak var builder: MoreBuilderRoutingProtocol?
    private let externalPublisher: PassthroughSubject<AppInteractorActivity, Never>
    private var state: MoreRouterState
    private var subscriptions: Set<AnyCancellable>
    
    init(builder: MoreBuilderRoutingProtocol, notificationsManager: AppNotificationsManagerPresentProtocol, displaySpinner: DisplaySpinnerProtocol, application: ApplicationProtocol) {
        self.builder = builder
        self.internalEventPublisher = PassthroughSubject<MoreRouterInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AppInteractorActivity, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.state = .root
        self.subscriptions = Set<AnyCancellable>()
        super.init(notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
        setupObservers()
    }

}

// MARK: Private
private extension MoreRouter {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MoreRouterInternalEvent) {
        switch event {
            case .inject(let value):
                setupDependencies(value)
            
            case .transition(let type):
                transition(type)
            
            case .trigger(let type):
                externalPublisher.send(type)
        }
    }
    
    func setupDependencies(_ value: AppNavigationControllerProtocol) {
        guard navigationController == nil else { return }
        
        navigationController = value
        
        navigationController?.publisher.sink { [weak self] in
            guard case let .didShow(viewController, _) = $0 else { return }
            self?.changeState(viewController)
        }.store(in: &subscriptions)
    }
    
    func changeState(_ viewController: UIViewController) {
        switch true {
            case _ where viewController is MoreRootViewController:
                state = .root
            
            case _ where viewController is MoreSupportViewController:
                state = .support
            
            case _ where viewController is MoreSettingsViewController:
                state = .settings
            
            default:
                break
        }
    }
    
    func transition(_ type: MoreRouterTransition) {
        guard let navigationController else {
            logger.console(event: .error(info: MoreRouterMessage.navigationControllerError))
            return
        }
        
        guard isPresentable(type) else {
            logger.console(event: .error(info: MoreRouterMessage.transitionError))
            return
        }

        switch type {
            case .notify(let type):
                userNotification(type)
            
            case .open(let path):
                open(path: path)
        
            case .support:
                support(navigationController, builder)
            
            case .settings:
                settings(navigationController, builder)
            
            case .security(_):
                break
                    
            case .share:
                share(navigationController, builder)
        }
    }
    
    func isPresentable(_ type: MoreRouterTransition) -> Bool {
        switch type {
            case .notify, .open:
                true
            
            case .support, .settings, .share:
                state == .root
            
            case .security(_):
                true
        }
    }
    
    func support(_ navigationController: AppNavigationControllerProtocol, _ builder: MoreBuilderRoutingProtocol?) {
        guard let viewController = builder?.supportViewController else {
            logger.console(event: .error(info: MoreRouterMessage.viewControllerError))
            return
        }
    
        push(in: navigationController, the: viewController)
    }
    
    func settings(_ navigationController: AppNavigationControllerProtocol, _ builder: MoreBuilderRoutingProtocol?) {
        guard let viewController = builder?.settingsViewController else {
            logger.console(event: .error(info: MoreRouterMessage.viewControllerError))
            return
        }
    
        push(in: navigationController, the: viewController)
    }
    
    func share(_ navigationController: AppNavigationControllerProtocol, _ builder: MoreBuilderRoutingProtocol?) {
        guard let viewController = builder?.shareViewController else {
            logger.console(event: .error(info: MoreRouterMessage.viewControllerError))
            return
        }
        
        viewController.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.state = .root
        }
        
        state = .share
        present(in: navigationController, the: viewController)
    }
    
}

// MARK: - MoreRouterMessage
fileprivate enum MoreRouterMessage {
    static let navigationControllerError = "Screen router doesn't have a navigation controller"
    static let viewControllerError = "Screen router doesn't have a view controller"
    static let transitionError = "Screen router can't open another one active screen at the moment"
}

// MARK: - MoreRouterState
fileprivate enum MoreRouterState {
    case root
    case support
    case settings
    case share
}

// MARK: - MoreRouterInternalEvent
enum MoreRouterInternalEvent {
    case inject(navigationController: AppNavigationControllerProtocol)
    case transition(MoreRouterTransition)
    case trigger(AppInteractorActivity)
}

// MARK: - MoreRouterTransition
enum MoreRouterTransition: Equatable {
    case notify(AppUserNotificationType)
    case open(String)
    case support
    case settings
    case security(MoreSettingsViewModelSelectEvent)
    case share
}
