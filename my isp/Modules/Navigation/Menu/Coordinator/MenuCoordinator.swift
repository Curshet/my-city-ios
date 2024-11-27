import Foundation
import Combine

class MenuCoordinator: MenuCoordinatorProtocol {

    let internalEventPublisher: PassthroughSubject<MenuCoordinatorInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MenuCoordinatorExternalEvent, Never>
    
    private weak var router: MenuRouterProtocol?
    private let builder: MenuBuilderProtocol
    private let externalPublisher: PassthroughSubject<MenuCoordinatorExternalEvent, Never>
    private var coordinators: [MenuCoordinatorKey : Any]
    private var subscriptions: Set<AnyCancellable>
    
    init(router: MenuRouterProtocol, builder: MenuBuilderProtocol) {
        self.router = router
        self.builder = builder
        self.internalEventPublisher = PassthroughSubject<MenuCoordinatorInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MenuCoordinatorExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.coordinators = [MenuCoordinatorKey : Any]()
        self.subscriptions = Set<AnyCancellable>()
        startConfiguration()
    }
    
}

// MARK: Private
private extension MenuCoordinator {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        let catalogCoordinator = builder.catalogCoordinator
        let profileCoordinator = builder.profileCoordinator
        let chatCoordinator = builder.chatCoordinator
        let moreCoordinator = builder.moreCoordinator
        let intercomCoordinator = builder.intercomCoordinator
        
        coordinators[.catalog] = catalogCoordinator
        coordinators[.profile] = profileCoordinator
        coordinators[.chat] = chatCoordinator
        coordinators[.more] = moreCoordinator
        coordinators[.intercom] = intercomCoordinator
        
        catalogCoordinator?.externalEventPublisher.sink { [weak self] in
            self?.externalPublisher.send(.activityRequest)
        }.store(in: &subscriptions)
        
        profileCoordinator?.externalEventPublisher.sink { [weak self] in
            self?.externalPublisher.send(.exit)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MenuCoordinatorInternalEvent) {
        switch event {
            case .start(let value):
                router?.internalEventPublisher.send(.output(.start(value)))
            
            case .activity(let value):
                activityHandler(value)
        }
    }
    
    func activityHandler(_ value: AppInteractorActivity) {
        router?.internalEventPublisher.send(.output(.trigger(value)))
        
        coordinators.keys.forEach {
            switch $0 {
                case .catalog:
                    coordinator(CatalogCoordinatorProtocol.self)?.internalEventPublisher.send(value)
                
                case .profile:
                    coordinator(ProfileCoordinatorProtocol.self)?.internalEventPublisher.send(value)
                
                case .chat:
                    coordinator(ChatCoordinatorProtocol.self)?.internalEventPublisher.send(value)
                
                case .more:
                    coordinator(MoreCoordinatorProtocol.self)?.internalEventPublisher.send(value)
                
                case .intercom:
                    coordinator(IntercomCoordinatorProtocol.self)?.internalEventPublisher.send(value)
            }
        }
    }
    
    func coordinator<T>(_ type: T.Type) -> T? {
        let typeName = String(type)
        
        switch true {
            case _ where typeName.hasPrefix(MenuCoordinatorKey.catalog.rawValue):
                return coordinators[.catalog] as? T
            
            case _ where typeName.hasPrefix(MenuCoordinatorKey.profile.rawValue):
                return coordinators[.profile] as? T
            
            case _ where typeName.hasPrefix(MenuCoordinatorKey.chat.rawValue):
                return coordinators[.chat] as? T
            
            case _ where typeName.hasPrefix(MenuCoordinatorKey.more.rawValue):
                return coordinators[.more] as? T
            
            case _ where typeName.hasPrefix(MenuCoordinatorKey.intercom.rawValue):
                return coordinators[.intercom] as? T
            
            default:
                return nil
        }
    }
                                                
}

// MARK: - MenuCoordinatorKey
fileprivate enum MenuCoordinatorKey: String {
    case catalog = "Catalog"
    case profile = "Profile"
    case chat = "Chat"
    case more = "More"
    case intercom = "Intercom"
}

// MARK: - MenuCoordinatorInternalEvent
enum MenuCoordinatorInternalEvent {
    case start(MenuCoordinatorStart)
    case activity(AppInteractorActivity)
}

// MARK: - MenuCoordinatorStart
enum MenuCoordinatorStart {
    case login
    case navigation
}

// MARK: - MenuCoordinatorExternalEvent
enum MenuCoordinatorExternalEvent {
    case activityRequest
    case exit
}
