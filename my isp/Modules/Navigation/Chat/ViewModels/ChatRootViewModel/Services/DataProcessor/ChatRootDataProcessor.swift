import Foundation
import Combine

class ChatRootDataProcessor: ChatRootDataProcessorProtocol {
    
    let internalEventPublisher: PassthroughSubject<ChatRootDataProcessorInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<ChatRootDataProcessorExternalEvent, Never>
    
    private let dataSource: ChatRootDataSourceProtocol
    private let presenter: AppearancePresenterProtocol
    private let interfaceManager: InterfaceManagerInfoProtocol
    private let externalPublisher: PassthroughSubject<ChatRootDataProcessorExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(dataSource: ChatRootDataSourceProtocol, presenter: AppearancePresenterProtocol, interfaceManager: InterfaceManagerInfoProtocol) {
        self.dataSource = dataSource
        self.presenter = presenter
        self.interfaceManager = interfaceManager
        self.internalEventPublisher = PassthroughSubject<ChatRootDataProcessorInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<ChatRootDataProcessorExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension ChatRootDataProcessor {
    
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
    
    func internalEventHandler(_ event: ChatRootDataProcessorInternalEvent) {
        switch event {
            case .view:
                dataSource.internalEventPublisher.send(.view(presenter.information.safeArea))
            
            case .navigationBar:
                dataSource.internalEventPublisher.send(.navigationBarAppearance(presenter.information.navigationBar))
            
            case .notify:
                dataSource.internalEventPublisher.send(.notify)
        }
    }
    
    func dataSourceEventHandler(_ event: ChatDataSourceExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(.view(value))
            
            case .layout(let value):
                externalPublisher.send(.layout(value))
            
            case .navigationBarAppearance(let value):
                presenter.internalEventPublisher.send(.setup(.navigationBar(value)))
            
            case .notify(let type):
                externalPublisher.send(.notify(type))
        }
    }
    
    func interfaceManagerEventHandler() {
        guard presenter.information.viewLoaded else { return }
        
        dataSource.internalEventPublisher.send(.navigationBarAppearance(presenter.information.navigationBar))
        dataSource.internalEventPublisher.send(.layout)
    }
    
}

// MARK: - ChatRootDataProcessorInternalEvent
enum ChatRootDataProcessorInternalEvent {
    case view
    case navigationBar
    case notify
}

// MARK: - ChatRootDataProcessorExternalEvent
enum ChatRootDataProcessorExternalEvent {
    case view(ChatRootViewData)
    case layout(ChatRootViewLayout)
    case notify(AppUserNotificationType)
}
