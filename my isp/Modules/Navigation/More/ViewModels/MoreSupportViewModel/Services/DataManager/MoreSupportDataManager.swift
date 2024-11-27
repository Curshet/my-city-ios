import Foundation
import Combine

class MoreSupportDataManager: MoreSupportDataManagerProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreSupportDataManagerInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MoreSupportDataManagerExternalEvent, Never>
    
    private weak var dataCache: MoreRootDataCacheInfoProtocol?
    private let dataSource: MoreSupportDataSourceProtocol
    private let externalPublisher: PassthroughSubject<MoreSupportDataManagerExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(dataCache: MoreRootDataCacheInfoProtocol, dataSource: MoreSupportDataSourceProtocol) {
        self.dataCache = dataCache
        self.dataSource = dataSource
        self.internalEventPublisher = PassthroughSubject<MoreSupportDataManagerInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MoreSupportDataManagerExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension MoreSupportDataManager {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        dataSource.externalEventPublisher.sink { [weak self] in
            self?.dataSourceEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MoreSupportDataManagerInternalEvent) {
        switch event {
            case .view:
                dataSource.internalEventPublisher.send(.view(dataCache?.contacts?.tel))
            
            case .appearance(let target):
                appearanceRequest(target)
            
            case .select(let type):
                dataSource.internalEventPublisher.send(.path(type: type, contacts: dataCache?.contacts))
        }
    }
    
    func appearanceRequest(_ target: AppearanceManagerExternalEvent) {
        switch target {
            case .update(let value):
                dataSource.internalEventPublisher.send(.view(dataCache?.contacts?.tel))
                fallthrough
            
            case .setup(let value):
                dataSource.internalEventPublisher.send(.navigationBar(value.navigationBar))
        }
    }
    
    func dataSourceEventHandler(_ event: MoreSupportDataSourceExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(.view(value))
            
            case .appearance(let value):
                externalPublisher.send(.appearance(value))
            
            case .path(let value):
                externalPublisher.send(.path(value))
        }
    }
    
}

// MARK: - MoreSupportDataManagerInternalEvent
enum MoreSupportDataManagerInternalEvent {
    case view
    case appearance(AppearanceManagerExternalEvent)
    case select(MoreSupportViewModelSelectEvent)
}

// MARK: - MoreSupportDataManagerExternalEvent
enum MoreSupportDataManagerExternalEvent {
    case view(MoreSupportViewData)
    case appearance(AppearanceTarget)
    case path(String)
}
