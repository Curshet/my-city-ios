import Foundation
import Combine

class MoreRootDataProcessor: MoreRootDataProcessorProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreRootDataProcessorInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MoreRootDataProcessorExternalEvent, Never>
    
    private weak var userManager: AppUserManagerInfoProtocol?
    private weak var dataCache: MoreRootDataCacheControlProtocol?
    private let dataSource: MoreRootDataSourceProtocol
    private let presenter: AppearancePresenterProtocol
    private let interfaceManager: InterfaceManagerInfoProtocol
    private let pasteboard: PasteboardProtocol
    private let externalPublisher: PassthroughSubject<MoreRootDataProcessorExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(dependencies: MoreRootDataProcessorDependencies) {
        self.userManager = dependencies.userManager
        self.dataCache = dependencies.dataCache
        self.dataSource = dependencies.dataSource
        self.presenter = dependencies.presenter
        self.interfaceManager = dependencies.interfaceManager
        self.pasteboard = dependencies.pasteboard
        self.internalEventPublisher = PassthroughSubject<MoreRootDataProcessorInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MoreRootDataProcessorExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension MoreRootDataProcessor {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        dataSource.externalEventPublisher.sink { [weak self] in
            self?.dataSourceEventHandler($0)
        }.store(in: &subscriptions)
        
        interfaceManager.publisher.sink { [weak self] _ in
            self?.interfaceManagerEventHandler()
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MoreRootDataProcessorInternalEvent) {
        switch event {
            case .view:
                dataSource.internalEventPublisher.send(.view(userManager?.information(of: .jsonWebToken)))

            case .navigationBar:
                dataSource.internalEventPublisher.send(.navigationBarAppearance(presenter.information.navigationBar))

            case .systemInfo:
                dataSource.internalEventPublisher.send(.systemInfo)
            
            case .cache(let value):
                dataCache?.saveData(value)
        }
    }
    
    func dataSourceEventHandler(_ event: MoreRootDataSourceExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(.view(value))
            
            case .navigationBarAppearance(let value):
                presenter.internalEventPublisher.send(.setup(.navigationBar(value)))
            
            case .request(let value):
                externalPublisher.send(.request(value))
            
            case .systemInfo(let value, let notify):
                pasteboard.string = value
                externalPublisher.send(.notify(notify))
        }
    }
    
    func interfaceManagerEventHandler() {
        guard presenter.information.viewLoaded else { return }
        
        dataSource.internalEventPublisher.send(.navigationBarAppearance(presenter.information.navigationBar))
        dataSource.internalEventPublisher.send(.layout)
    }
    
}

// MARK: - MoreRootDataProcessorDependencies
struct MoreRootDataProcessorDependencies {
    let userManager: AppUserManagerInfoProtocol
    let dataCache: MoreRootDataCacheControlProtocol
    let dataSource: MoreRootDataSourceProtocol
    let presenter: AppearancePresenterProtocol
    let interfaceManager: InterfaceManagerInfoProtocol
    let pasteboard: PasteboardProtocol
}

// MARK: - MoreRootDataManagerInternalEvent
enum MoreRootDataProcessorInternalEvent {
    case view
    case navigationBar
    case systemInfo
    case cache(MoreSupportContacts)
}

// MARK: - MoreRootDataProcessorExternalEvent
enum MoreRootDataProcessorExternalEvent {
    case view(MoreRootViewData)
    case request(NetworkManagerRequest)
    case notify(AppUserNotificationType)
}
