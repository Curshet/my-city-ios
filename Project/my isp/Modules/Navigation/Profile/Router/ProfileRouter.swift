import UIKit
import Combine

class ProfileRouter: ScreenRouter, ProfileRouterProtocol {
    
    let internalEventPublisher: PassthroughSubject<ProfileRouterInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<ProfileRouterExternalEvent, Never>
    
    private weak var navigationController: AppNavigationControllerProtocol?
    private weak var builder: ProfileBuilderRoutingProtocol?
    private let externalPublisher: PassthroughSubject<ProfileRouterExternalEvent, Never>
    private var state: ProfileRouterState
    private var subscriptions: Set<AnyCancellable>
    
    init(builder: ProfileBuilderRoutingProtocol, notificationsManager: AppNotificationsManagerPresentProtocol, displaySpinner: DisplaySpinnerProtocol, application: ApplicationProtocol) {
        self.builder = builder
        self.internalEventPublisher = PassthroughSubject<ProfileRouterInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<ProfileRouterExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.state = .root
        self.subscriptions = Set<AnyCancellable>()
        super.init(notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
        setupObservers()
    }
    
}

// MARK: Private
private extension ProfileRouter {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: ProfileRouterInternalEvent) {
        switch event {
            case .inject(let value):
                setupDependencies(value)
            
            case .transition(let type):
                transition(type)
            
            case .output(let value):
                externalPublisher.send(value)
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
            case _ where viewController is ProfileRootViewController:
                state = .root
            
            default:
                break
        }
    }
    
    func transition(_ type: ProfileRouterTransition) {
        guard navigationController != nil else {
            logger.console(event: .error(info: ProfileRouterMessage.navigationControllerError))
            return
        }
        
        guard isPresentable(type) else {
            logger.console(event: .error(info: ProfileRouterMessage.transitionError))
            return
        }
        
        switch type {
            case .notify(let type):
                userNotification(type)
            
            default:
                break
        }
    }
    
    func isPresentable(_ type: ProfileRouterTransition) -> Bool {
        switch type {
            case .notify:
                true
            
            case .editImage, .editName, .exit, .delete:
                state == .root
        }
    }
    
}

// MARK: - ProfileRouterMessage
fileprivate enum ProfileRouterMessage {
    static let navigationControllerError = "Screen router doesn't have a navigation controller"
    static let viewControllerError = "Screen router doesn't have a view controller"
    static let transitionError = "Screen router can't open another one active screen at the moment"
}

// MARK: - ProfileRouterState
fileprivate enum ProfileRouterState {
    case root
    case editImage
    case editName
    case alert
}

// MARK: - ProfileRouterInternalEvent
enum ProfileRouterInternalEvent {
    case inject(navigationController: AppNavigationControllerProtocol)
    case transition(ProfileRouterTransition)
    case output(ProfileRouterExternalEvent)
}

// MARK: - ProfileRouterTransition
enum ProfileRouterTransition {
    case notify(AppUserNotificationType)
    case editImage
    case editName
    case exit
    case delete
}

// MARK: - ProfileRouterExternalEvent
enum ProfileRouterExternalEvent: Equatable {
    case trigger(AppInteractorActivity)
    case exit
}
