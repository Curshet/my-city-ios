import Foundation
import Combine

class CatalogRootViewModel: CatalogRootViewModelProtocol {
    
    let internalEventPublisher: PassthroughSubject<CatalogRootViewModelInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<CatalogRootViewLayout, Never>
    
    private weak var router: CatalogRouterProtocol?
    private let dataManager: CatalogRootDataManagerProtocol
    private let networkManager: CatalogRootNetworkManagerProtocol
    private let appearanceManager: AppearanceManagerProtocol
    private let externalPublisher: PassthroughSubject<CatalogRootViewLayout, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(router: CatalogRouterProtocol, dataManager: CatalogRootDataManagerProtocol, networkManager: CatalogRootNetworkManagerProtocol, appearanceManager: AppearanceManagerProtocol) {
        self.router = router
        self.dataManager = dataManager
        self.networkManager = networkManager
        self.appearanceManager = appearanceManager
        self.internalEventPublisher = PassthroughSubject<CatalogRootViewModelInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<CatalogRootViewLayout, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension CatalogRootViewModel {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)

        dataManager.externalEventPublisher.sink { [weak self] in
            self?.dataSourceEventHandler($0)
        }.store(in: &subscriptions)
        
        networkManager.externalEventPublisher.sink { [weak self] in
            self?.networkManagerEventHandler($0)
        }.store(in: &subscriptions)
        
        appearanceManager.extеrnalEvеntPublisher.sink { [weak self] in
            self?.dataManager.internalEventPublisher.send(.appearance($0))
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: CatalogRootViewModelInternalEvent) {
        switch event {
            case .dataRequest:
                dataManager.internalEventPublisher.send(.view)
            
            case .setupNavigationBar:
                appearanceManager.internalEvеntPublishеr.send(.configure)
        }
    }
    
    func dataSourceEventHandler(_ event: CatalogRootDataManagerExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(value)
            
            case .appearance(let value):
                appearanceManager.internalEvеntPublishеr.send(.appearance(value))
                
            case .request(let value):
                networkManager.internalEventPublisher.send(value)
                guard case .systemInfo(_) = value else { return }
                router?.internalEventPublisher.send(.output(.activityRequest))
        }
    }
    
    func networkManagerEventHandler(_ event: Result<CatalogRootNetworkManagerResponse, CatalogRootNetworkManagerError>) {
        switch event {
            case .success(_):
                break
            
            case .failure(_):
                break
        }
    }
    
}

// MARK: - CatalogRootViewModelInternalEvent
enum CatalogRootViewModelInternalEvent {
    case dataRequest
    case setupNavigationBar
}
