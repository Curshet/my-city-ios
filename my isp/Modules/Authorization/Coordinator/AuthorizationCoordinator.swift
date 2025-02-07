import Foundation
import Combine

class AuthorizationCoordinator: AuthorizationCoordinatorProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationCoordinatorInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AuthorizationCoordinatorExternalEvent, Never>
    
    private weak var router: AuthorizationRouterProtocol?
    private let externalPublisher: PassthroughSubject<AuthorizationCoordinatorExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(router: AuthorizationRouterProtocol) {
        self.router = router
        self.internalEventPublisher = PassthroughSubject<AuthorizationCoordinatorInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AuthorizationCoordinatorExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension AuthorizationCoordinator {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        router?.externalEventPublisher.sink { [weak self] in
            guard case let .output(type) = $0, case let .action(value) = type else { return }
            self?.externalPublisher.send(value)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AuthorizationCoordinatorInternalEvent) {
        switch event {
            case .start(let type):
                router?.internalEventPublisher.send(.start(type))
            
            case .route(let type):
                guard case let .authorization(value) = type else { return }
                router?.internalEventPublisher.send(.output(.trigger(.route(.success(value)))))
        }
    }
    
}

// MARK: - AuthorizationCoordinatorInternalEvent
enum AuthorizationCoordinatorInternalEvent {
    case start(AuthorizationCoordinatorStart)
    case route(AppRouteManagerExternalEvent)
}

// MARK: - AuthorizationCoordinatorStart
enum AuthorizationCoordinatorStart {
    case login
    case logout
}

// MARK: - AuthorizationCoordinatorExternalEvent
enum AuthorizationCoordinatorExternalEvent {
    case activityRequest
    case exit
}
