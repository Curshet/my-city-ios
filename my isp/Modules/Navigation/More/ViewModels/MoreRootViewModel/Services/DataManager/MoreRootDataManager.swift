import Foundation
import Combine

class MoreRootDataManager: MoreRootDataManagerProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreRootDataManagerInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MoreRootDataManagerExternalEvent, Never>
    
    private weak var userManager: AppUserManagerInfoProtocol?
    private weak var dataCache: MoreRootDataCacheControlProtocol?
    private let dataSource: MoreRootDataSourceProtocol
    private let pasteboard: PasteboardProtocol
    private let externalPublisher: PassthroughSubject<MoreRootDataManagerExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(userManager: AppUserManagerInfoProtocol, dataCache: MoreRootDataCacheControlProtocol, dataSource: MoreRootDataSourceProtocol, pasteboard: PasteboardProtocol) {
        self.userManager = userManager
        self.dataCache = dataCache
        self.dataSource = dataSource
        self.pasteboard = pasteboard
        self.internalEventPublisher = PassthroughSubject<MoreRootDataManagerInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MoreRootDataManagerExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension MoreRootDataManager {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        dataSource.externalEventPublisher.sink { [weak self] in
            self?.dataSourceEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MoreRootDataManagerInternalEvent) {
        switch event {
            case .view:
                dataSource.internalEventPublisher.send(.view)
                dataSource.internalEventPublisher.send(.request(userManager?.information(of: .jsonWebToken)))

            case .appearance(let target):
                appearanceRequest(target)
            
            case .cache(let value):
                dataCache?.saveData(value)
            
            case .systemInfo:
                dataSource.internalEventPublisher.send(.systemInfo)
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
    
    func dataSourceEventHandler(_ event: MoreRootDataSourceExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(.view(value))
            
            case .appearance(let value):
                externalPublisher.send(.appearance(value))
            
            case .request(let value):
                externalPublisher.send(.request(value))
            
            case .systemInfo(let value, let notify):
                pasteboard.string = value
                externalPublisher.send(.notify(notify))
        }
    }
    
}

// MARK: - MoreRootDataManagerInternalEvent
enum MoreRootDataManagerInternalEvent {
    case view
    case appearance(AppearanceManagerExternalEvent)
    case cache(MoreSupportContacts)
    case systemInfo
}

// MARK: - MoreRootDataManagerExternalEvent
enum MoreRootDataManagerExternalEvent {
    case view(MoreRootViewData)
    case appearance(AppearanceTarget)
    case request(NetworkManagerRequest)
    case notify(AppUserNotificationType)
}
