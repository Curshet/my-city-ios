import UIKit
import Combine

class CatalogRouter: ScreenRouter, CatalogRouterProtocol {
    
    let internalEventPublisher: PassthroughSubject<CatalogRouterInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<CatalogRouterExternalEvent, Never>
    
    private weak var navigationController: AppNavigationControllerProtocol?
    private weak var builder: CatalogBuilderRoutingProtocol?
    private let externalPublisher: PassthroughSubject<CatalogRouterExternalEvent, Never>
    private var state: CatalogRouterState
    private var subscriptions: Set<AnyCancellable>
    
    init(builder: CatalogBuilderRoutingProtocol, notificationsManager: AppNotificationsManagerPresentProtocol, displaySpinner: DisplaySpinnerProtocol, application: ApplicationProtocol) {
        self.builder = builder
        self.internalEventPublisher = PassthroughSubject<CatalogRouterInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<CatalogRouterExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.state = .root
        self.subscriptions = Set<AnyCancellable>()
        super.init(notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
        setupObservers()
    }
    
}

// MARK: Private
private extension CatalogRouter {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: CatalogRouterInternalEvent) {
        switch event {
            case .inject(let value):
                setupDependencies(value)
            
            case .transition(let type):
                transition(type)
            
            case .output(let type):
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
            case _ where viewController is CatalogRootViewController:
                state = .root
            
            default:
                break
        }
    }
    
    func transition(_ type: CatalogRouterTransition) {
        guard navigationController != nil else {
            logger.console(event: .error(info: CatalogRouterMessage.navigationControllerError))
            return
        }
        
        guard isPresentable(type) else {
            logger.console(event: .error(info: CatalogRouterMessage.transitionError))
            return
        }
    }
    
    func isPresentable(_ type: CatalogRouterTransition) -> Bool {
        switch type {
            case .notify:
                true
            
            case .root:
                state != .root
            
            case .notifications:
                state == .root
        }
    }
    
}

// MARK: - CatalogRouterMessage
fileprivate enum CatalogRouterMessage {
    static let navigationControllerError = "Screen router doesn't have a navigation controller"
    static let viewControllerError = "Screen router doesn't have a view controller"
    static let transitionError = "Screen router can't open another one active screen at the moment"
}

// MARK: - CatalogRouterState
fileprivate enum CatalogRouterState {
    case root
    case notifications
    case alert
}

// MARK: - CatalogRouterInternalEvent
enum CatalogRouterInternalEvent {
    case inject(navigationController: AppNavigationControllerProtocol)
    case transition(CatalogRouterTransition)
    case output(CatalogRouterExternalEvent)
}

// MARK: - CatalogRouterTransition
enum CatalogRouterTransition {
    case notify(AppUserNotificationType)
    case root
    case notifications
}

// MARK: - CatalogRouterExternalEvent
enum CatalogRouterExternalEvent: Equatable {
    case activityRequest
    case trigger(AppInteractorActivity)
}
