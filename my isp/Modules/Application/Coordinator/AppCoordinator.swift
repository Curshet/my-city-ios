import Foundation
import Combine

final class AppCoordinator: AppCoordinatorProtocol {
    
    private let interactor: AppInteractorProtocol
    private let builder: AppBuilderProtocol
    private var coordinators: [AppCoordinatorKey : Any]
    private var subscriptions: Set<AnyCancellable>
    
    init(interactor: AppInteractorProtocol, builder: AppBuilderProtocol) {
        self.interactor = interactor
        self.builder = builder
        self.coordinators = [AppCoordinatorKey : Any]()
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
    func start() -> Bool {
        startSplashModule()
        return true
    }
    
}

// MARK: Private
private extension AppCoordinator {
    
    func setupObservers() {
        interactor.externalEventPublisher.sink { [weak self] in
            self?.interactorEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func interactorEventHandler(_ event: AppInteractorExternalEvent) {
        switch event {
            case .start(let userAuthorization):
                startApplication(userAuthorization)
            
            case .activity(let type):
                activity(type)
        }
    }
    
    func startSplashModule() {
        guard let coordinator = builder.splashCoordinator else {
            interactor.internalEventPublisher.send(.fatalError(.splashCoordinator))
            return
        }
        
        coordinator.externalEventPublisher.sink { [weak self] in
            self?.interactor.internalEventPublisher.send(.start)
        }.store(in: &subscriptions)
        
        coordinators.removeAll()
        coordinators[.splash] = coordinator
        coordinator.internalEventPublisher.send()
    }
    
    func startApplication(_ userAuthorization: AppUserManagerAuthorization) {
        switch userAuthorization {
            case .unavaliable:
                startAuthorizationModule(.login)

            case .avaliable:
                startNavigationModule(.navigation)
        }
    }
    
    func startAuthorizationModule(_ type: AuthorizationCoordinatorStart) {
        guard let coordinator = builder.authorizationCoordinator else {
            interactor.internalEventPublisher.send(.fatalError(.authorizationCoordinator))
            return
        }
        
        coordinator.externalEventPublisher.sink { [weak self] in
            self?.authorizationEventHandler($0)
        }.store(in: &subscriptions)
        
        coordinators.removeAll()
        coordinators[.authorization] = coordinator
        coordinator.internalEventPublisher.send(.start(type))
    }
    
    func authorizationEventHandler(_ event: AuthorizationCoordinatorExternalEvent) {
        switch event {
            case .activityRequest:
                interactor.internalEventPublisher.send(.activity(.request))
            
            case .exit:
                startNavigationModule(.login)
        }
    }
    
    func startNavigationModule(_ type: MenuCoordinatorStart) {
        guard let coordinator = builder.navigationCoordinator else {
            interactor.internalEventPublisher.send(.fatalError(.navigationCoordinator))
            return
        }
        
        coordinator.externalEventPublisher.sink { [weak self] in
            self?.navigationEventHandler($0)
        }.store(in: &subscriptions)

        coordinators.removeAll()
        coordinators[.navigation] = coordinator
        coordinator.internalEventPublisher.send(.start(type))
    }
    
    func navigationEventHandler(_ event: MenuCoordinatorExternalEvent) {
        switch event {
            case .activityRequest:
                interactor.internalEventPublisher.send(.activity(.request))
            
            case .exit:
                startAuthorizationModule(.logout)
        }
    }
    
    func activity(_ type: AppInteractorActivity) {
        switch type {
            case .route(let value):
                coordinator(AuthorizationCoordinatorProtocol.self)?.internalEventPublisher.send(.route(value))
                fallthrough

            default:
                coordinator(MenuCoordinatorProtocol.self)?.internalEventPublisher.send(.activity(type))
        }
    }
    
    func coordinator<T>(_ type: T.Type) -> T? {
        let typeName = String(type)
        
        switch true {
            case _ where typeName.hasPrefix(AppCoordinatorKey.splash.rawValue):
                return coordinators[.splash] as? T
            
            case _ where typeName.hasPrefix(AppCoordinatorKey.authorization.rawValue):
                return coordinators[.authorization] as? T
            
            case _ where typeName.hasPrefix(AppCoordinatorKey.navigation.rawValue):
                return coordinators[.navigation] as? T
            
            default:
                return nil
        }
    }
    
}

// MARK: - AppCoordinatorKey
fileprivate enum AppCoordinatorKey: String {
    case splash = "Splash"
    case authorization = "Authorization"
    case navigation = "Menu"
}
