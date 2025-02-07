import Foundation
import Combine

class MoreSupportViewModel: MoreSupportViewModelProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreSupportViewModelInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MoreSupportViewData, Never>
    
    private weak var router: MoreRouterProtocol?
    private let dataManager: MoreSupportDataManagerProtocol
    private let appearanceManager: AppearanceManagerProtocol
    private let externalPublisher: PassthroughSubject<MoreSupportViewData, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(router: MoreRouterProtocol, dataManager: MoreSupportDataManagerProtocol, appearanceManager: AppearanceManagerProtocol) {
        self.router = router
        self.dataManager = dataManager
        self.appearanceManager = appearanceManager
        self.internalEventPublisher = PassthroughSubject<MoreSupportViewModelInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MoreSupportViewData, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension MoreSupportViewModel {
    
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
    
    func internalEventHandler(_ event: MoreSupportViewModelInternalEvent) {
        switch event {
            case .dataRequest:
                dataManager.internalEventPublisher.send(.view)
            
            case .setupNavigationBar:
                appearanceManager.internalEvеntPublishеr.send(.configure)
            
            case .select(let type):
                dataManager.internalEventPublisher.send(.select(type))
        }
    }
    
    func dataManagerEventHandler(_ event: MoreSupportDataManagerExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(value)
            
            case .appearance(let value):
                appearanceManager.internalEvеntPublishеr.send(.appearance(value))
            
            case .path(let value):
                router?.internalEventPublisher.send(.transition(.open(value)))
        }
    }
    
}

// MARK: - MoreSupportViewModelInternalEvent
enum MoreSupportViewModelInternalEvent {
    case dataRequest
    case setupNavigationBar
    case select(MoreSupportViewModelSelectEvent)
}

// MARK: - MoreSupportViewModelSelectEvent
enum MoreSupportViewModelSelectEvent {
    case phone
    case telegram
    case whatsApp
    case viber
}
