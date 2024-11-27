import Foundation
import Combine

class MoreSettingsViewModel: MoreSettingsViewModelProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreSettingsViewModelInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MoreSettingsViewModelExternalEvent, Never>
    
    private weak var router: MoreRouterProtocol?
    private let dataManager: MoreSettingsDataManagerProtocol
    private let appearanceManager: AppearanceManagerProtocol
    private let externalPublisher: PassthroughSubject<MoreSettingsViewModelExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(router: MoreRouterProtocol, dataManager: MoreSettingsDataManagerProtocol, appearanceManager: AppearanceManagerProtocol) {
        self.router = router
        self.dataManager = dataManager
        self.appearanceManager = appearanceManager
        self.internalEventPublisher = PassthroughSubject<MoreSettingsViewModelInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MoreSettingsViewModelExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension MoreSettingsViewModel {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        dataManager.externalEventPublisher.sink { [weak self] in
            self?.dataManagerEventHandler($0)
        }.store(in: &subscriptions)
        
        appearanceManager.extеrnalEvеntPublisher.sink { [weak self] in
            self?.dataManager.internalEventPublisher.send(.appearance($0))
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MoreSettingsViewModelInternalEvent) {
        switch event {
            case .dataRequest:
                dataManager.internalEventPublisher.send(.view)
            
            case .setupNavigationBar:
                appearanceManager.internalEvеntPublishеr.send(.configure)
            
            case .select(let type):
                router?.internalEventPublisher.send(.transition(.security(type)))
        }
    }
    
    func dataManagerEventHandler(_ event: MoreSettingsDataManagerExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(.view(value))
            
            case .update(let value):
                externalPublisher.send(.update(value))
            
            case .appearance(let value):
                appearanceManager.internalEvеntPublishеr.send(.appearance(value))
        }
    }
    
}

// MARK: - MoreSettingsViewModelInternalEvent
enum MoreSettingsViewModelInternalEvent {
    case dataRequest
    case setupNavigationBar
    case select(MoreSettingsViewModelSelectEvent)
}

// MARK: - MoreSettingsViewModelSelectEvent
enum MoreSettingsViewModelSelectEvent {
    case biometrics
    case password
}

// MARK: - MoreSettingsViewModelExternalEvent
enum MoreSettingsViewModelExternalEvent {
    case view(MoreSettingsViewData)
    case update(MoreSettingsViewUpdateData)
}
