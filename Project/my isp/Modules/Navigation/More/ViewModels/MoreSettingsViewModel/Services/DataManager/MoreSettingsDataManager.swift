import Foundation
import Combine

class MoreSettingsDataManager: MoreSettingsDataManagerProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreSettingsDataManagerInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MoreSettingsDataManagerExternalEvent, Never>
    
    private weak var userManager: AppUserManagerInfoProtocol?
    private let dataSource: MoreSettingsDataSourceProtocol
    private let externalPublisher: PassthroughSubject<MoreSettingsDataManagerExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(userManager: AppUserManagerInfoProtocol, dataSource: MoreSettingsDataSourceProtocol) {
        self.userManager = userManager
        self.dataSource = dataSource
        self.internalEventPublisher = PassthroughSubject<MoreSettingsDataManagerInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MoreSettingsDataManagerExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension MoreSettingsDataManager {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        dataSource.externalEventPublisher.sink { [weak self] in
            self?.dataSourceEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MoreSettingsDataManagerInternalEvent) {
        switch event {
            case .view:
                dataSource.internalEventPublisher.send(.view(userManager?.information(of: .biometrics, .password)))
            
            case .update:
                dataSource.internalEventPublisher.send(.update(userManager?.information(of: .biometrics, .password)))
            
            case .appearance(let target):
                apperanceRequest(target)
        }
    }
    
    func apperanceRequest(_ target: AppearanceManagerExternalEvent) {
        switch target {
            case .update(let value):
                dataSource.internalEventPublisher.send(.view(userManager?.information(of: .biometrics, .password)))
                fallthrough
            
            case .setup(let value):
                dataSource.internalEventPublisher.send(.navigationBar(value.navigationBar))
        }
    }
    
    func dataSourceEventHandler(_ event: MoreSettingsDataSourceExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(.view(value))
            
            case .update(let value):
                externalPublisher.send(.update(value))
            
            case .appearance(let value):
                externalPublisher.send(.appearance(value))
        }
    }
    
}

// MARK: - MoreSettingsDataManagerInternalEvent
enum MoreSettingsDataManagerInternalEvent {
    case view
    case update
    case appearance(AppearanceManagerExternalEvent)
}

// MARK: - MoreSettingsDataManagerExternalEvent
enum MoreSettingsDataManagerExternalEvent {
    case view(MoreSettingsViewData)
    case update(MoreSettingsViewUpdateData)
    case appearance(AppearanceTarget)
}
