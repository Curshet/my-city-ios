import Foundation
import Combine

class CatalogRootDataManager: CatalogRootDataManagerProtocol {
    
    let internalEventPublisher: PassthroughSubject<CatalogRootDataManagerInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<CatalogRootDataManagerExternalEvent, Never>
    
    private weak var userManager: AppUserManagerInfoProtocol?
    private let dataSource: CatalogRootDataSourceProtocol
    private let notificationsManager: AppNotificationsManagerAuthorizationProtocol
    private let permissionManager: PermissionManagerProtocol
    private let externalPublisher: PassthroughSubject<CatalogRootDataManagerExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(userManager: AppUserManagerInfoProtocol, dataSource: CatalogRootDataSourceProtocol, notificationsManager: AppNotificationsManagerAuthorizationProtocol, permissionManager: PermissionManagerProtocol) {
        self.userManager = userManager
        self.dataSource = dataSource
        self.notificationsManager = notificationsManager
        self.permissionManager = permissionManager
        self.internalEventPublisher = PassthroughSubject<CatalogRootDataManagerInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<CatalogRootDataManagerExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension CatalogRootDataManager {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        userManager?.externalEventPublisher.sink { [weak self] in
            guard case let .success(type) = $0, type == .firebaseToken else { return }
            self?.dataSource.internalEventPublisher.send(.firebase(self?.userManager?.information(of: .jsonWebToken, .firebaseToken)))
        }.store(in: &subscriptions)
        
        dataSource.externalEventPublisher.sink { [weak self] in
            self?.dataSourceEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: CatalogRootDataManagerInternalEvent) {
        switch event {
            case .view:
                dataRequest()
            
            case .appearance(let target):
                appearanceRequest(target)
        }
    }
    
    func dataRequest() {
        dataSource.internalEventPublisher.send(.view)
        
        notificationsManager.requestAuthorization { [weak self] in
            guard let self else { return }
            let permission = CatalogRootPermissionData(settings: $0, information: permissionManager.information)
            dataSource.internalEventPublisher.send(.systemInfo(userInfo: userManager?.information(of: .jsonWebToken, .firebaseToken), permission: permission))
        }
    }
    
    func appearanceRequest(_ target: AppearanceManagerExternalEvent) {
        switch target {
            case .update(let value):
                dataSource.internalEventPublisher.send(.view)
                fallthrough
            
            case .setup(let value):
                dataSource.internalEventPublisher.send(.navigationBar(value.navigationBar))
        }
    }
    
    func dataSourceEventHandler(_ event: CatalogRootDataSourceExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(.view(value))
            
            case .appearance(let value):
                externalPublisher.send(.appearance(value))
                
            case .request(let value):
                externalPublisher.send(.request(value))
        }
    }
    
}

// MARK: - CatalogRootDataManagerInternalEvent
enum CatalogRootDataManagerInternalEvent {
    case view
    case appearance(AppearanceManagerExternalEvent)
}

// MARK: - CatalogRootDataManagerExternalEvent
enum CatalogRootDataManagerExternalEvent {
    case view(CatalogRootViewLayout)
    case appearance(AppearanceTarget)
    case request(CatalogRootNetworkInternalEvent)
}
