import UIKit
import Combine

class ChatRootDataManager: ChatRootDataManagerProtocol {
    
    let internalEventPublisher: PassthroughSubject<ChatRootDataManagerInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<ChatRootDataManagerExternalEvent, Never>
    
    private let dataSource: ChatRootDataSourceProtocol
    private let localizationManager: LocalizationManagerInfoProtocol
    private let externalPublisher: PassthroughSubject<ChatRootDataManagerExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(dataSource: ChatRootDataSourceProtocol, localizationManager: LocalizationManagerInfoProtocol) {
        self.dataSource = dataSource
        self.localizationManager = localizationManager
        self.internalEventPublisher = PassthroughSubject<ChatRootDataManagerInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<ChatRootDataManagerExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension ChatRootDataManager {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        dataSource.externalEventPublisher.sink { [weak self] in
            self?.dataSourceEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: ChatRootDataManagerInternalEvent) {
        switch event {
            case .view(let value):
                dataSource.internalEventPublisher.send(.view(safeArea: value.safeArea, localization: localizationManager.information.appLanguage))
            
            case .appearance(let target):
                appearanceRequest(target)
            
            case .notify:
                dataSource.internalEventPublisher.send(.notify)
        }
    }
    
    func appearanceRequest(_ target: AppearanceManagerExternalEvent) {
        switch target {
            case .update(let value):
                dataSource.internalEventPublisher.send(.layout)
                fallthrough
            
            case .setup(let value):
                dataSource.internalEventPublisher.send(.navigationBar(value.navigationBar))
        }
    }
    
    func dataSourceEventHandler(_ event: ChatDataSourceExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(.view(value))
            
            case .layout(let value):
                externalPublisher.send(.layout(value))
            
            case .appearance(let value):
                externalPublisher.send(.appearance(.navigationBar(value)))
            
            case .notify(let type):
                externalPublisher.send(.notify(type))
        }
    }
    
}

// MARK: - ChatRootDataManagerInternalEvent
enum ChatRootDataManagerInternalEvent {
    case view(AppearancePresenterData)
    case appearance(AppearanceManagerExternalEvent)
    case notify
}

// MARK: - ChatRootDataManagerExternalEvent
enum ChatRootDataManagerExternalEvent {
    case view(ChatRootViewData)
    case layout(ChatRootViewLayout)
    case appearance(AppearanceTarget)
    case notify(AppUserNotificationType)
}
