import Foundation
import Combine

class MoreRootViewModel: MoreRootViewModelProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreRootViewModelInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MoreRootViewData, Never>
    
    private weak var router: MoreRouterProtocol?
    private let dataManager: MoreRootDataManagerProtocol
    private let networkManager: MoreRootNetworkManagerProtocol
    private let appearanceManager: AppearanceManagerProtocol
    private let externalPublisher: PassthroughSubject<MoreRootViewData, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(router: MoreRouterProtocol, dataManager: MoreRootDataManagerProtocol, networkManager: MoreRootNetworkManagerProtocol, appearanceManager: AppearanceManagerProtocol) {
        self.router = router
        self.dataManager = dataManager
        self.networkManager = networkManager
        self.appearanceManager = appearanceManager
        self.internalEventPublisher = PassthroughSubject<MoreRootViewModelInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MoreRootViewData, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension MoreRootViewModel {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        dataManager.externalEventPublisher.sink { [weak self] in
            self?.dataManagerEventHandler($0)
        }.store(in: &subscriptions)
        
        networkManager.externalEventPublisher.sink { [weak self] in
            guard case let .success(data) = $0 else { return }
            self?.dataManager.internalEventPublisher.send(.cache(data))
        }.store(in: &subscriptions)
        
        appearanceManager.extеrnalEvеntPublisher.sink { [weak self] in
            self?.dataManager.internalEventPublisher.send(.appearance($0))
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MoreRootViewModelInternalEvent) {
        switch event {
            case .dataRequest:
                dataManager.internalEventPublisher.send(.view)
                
            case .setupNavigationBar:
                appearanceManager.internalEvеntPublishеr.send(.configure)
            
            case .select(let value):
                transition(value)
        }
    }
    
    func transition(_ value: MoreRootViewModelSelectEvent) {
        switch value {
            case .support:
                router?.internalEventPublisher.send(.transition(.support))
            
            case .settings:
                router?.internalEventPublisher.send(.transition(.settings))
            
            case .share:
                router?.internalEventPublisher.send(.transition(.share))
            
            case .copySystemInfo:
                dataManager.internalEventPublisher.send(.systemInfo)
        }
    }
    
    func dataManagerEventHandler(_ event: MoreRootDataManagerExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(value)
            
            case .appearance(let value):
                appearanceManager.internalEvеntPublishеr.send(.appearance(value))
            
            case .request(let value):
                networkManager.internalEventPublisher.send(value)
            
            case .notify(let type):
                router?.internalEventPublisher.send(.transition(.notify(type)))
        }
    }
    
}

// MARK: - MoreRootViewModelInternalEvent
enum MoreRootViewModelInternalEvent {
    case dataRequest
    case setupNavigationBar
    case select(MoreRootViewModelSelectEvent)
}

// MARK: - MoreRootViewModelSelectEvent
enum MoreRootViewModelSelectEvent {
    case support
    case settings
    case share
    case copySystemInfo
}
