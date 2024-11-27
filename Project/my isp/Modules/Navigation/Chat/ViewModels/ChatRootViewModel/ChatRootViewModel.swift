import Foundation
import Combine

class ChatRootViewModel: ChatRootViewModelProtocol {
    
    let internalEventPublisher: PassthroughSubject<ChatRootViewModelInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<ChatRootViewModelExternalEvent, Never>
    
    private weak var router: ChatRouterProtocol?
    private let dataManager: ChatRootDataManagerProtocol
    private let appearanceManager: AppearanceManagerProtocol
    private let externalPublisher: PassthroughSubject<ChatRootViewModelExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(router: ChatRouterProtocol, dataManager: ChatRootDataManagerProtocol, appearanceManager: AppearanceManagerProtocol) {
        self.router = router
        self.dataManager = dataManager
        self.appearanceManager = appearanceManager
        self.internalEventPublisher = PassthroughSubject<ChatRootViewModelInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<ChatRootViewModelExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension ChatRootViewModel {
    
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
    
    func internalEventHandler(_ event: ChatRootViewModelInternalEvent) {
        switch event {
            case .request(let type):
                requestHandler(type)
            
            case .setupNavigationBar:
                appearanceManager.internalEvеntPublishеr.send(.configure)
        }
    }
    
    func requestHandler(_ type: ChatRootViewModelRequestType) {
        switch type {
            case .data:
                dataManager.internalEventPublisher.send(.view(appearanceManager.information))
            
            case .error:
                dataManager.internalEventPublisher.send(.notify)
        }
    }
    
    func dataManagerEventHandler(_ event: ChatRootDataManagerExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(.view(value))
            
            case .layout(let value):
                externalPublisher.send(.layout(value))
            
            case .appearance(let value):
                appearanceManager.internalEvеntPublishеr.send(.appearance(value))
            
            case .notify(let type):
                router?.internalEventPublisher.send(.notify(type))
        }
    }
    
}

// MARK: - ChatRootViewModelInternalEvent
enum ChatRootViewModelInternalEvent {
    case request(ChatRootViewModelRequestType)
    case setupNavigationBar
}

// MARK: - ChatRootViewModelRequestType
enum ChatRootViewModelRequestType {
    case data
    case error
}

// MARK: - ChatRootViewModelExternalEvent
enum ChatRootViewModelExternalEvent {
    case view(ChatRootViewData)
    case layout(ChatRootViewLayout)
}
