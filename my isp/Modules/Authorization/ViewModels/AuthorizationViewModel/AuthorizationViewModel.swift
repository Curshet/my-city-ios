import Foundation
import Combine

class AuthorizationViewModel: AuthorizationViewModelProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationViewModelInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AuthorizationViewModelExternalEvent, Never>
    
    var isLightMode: Bool {
        dataManager.isLightMode
    }
    
    private weak var router: AuthorizationRouterProtocol?
    private let dataManager: AuthorizationDataManagerProtocol
    private let networkManager: AuthorizationNetworkManagerProtocol
    private let interfaceManager: InterfaceManagerControlProtocol
    private let externalPublisher: PassthroughSubject<AuthorizationViewModelExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(router: AuthorizationRouterProtocol, dataManager: AuthorizationDataManagerProtocol, networkManager: AuthorizationNetworkManagerProtocol, interfaceManager: InterfaceManagerControlProtocol) {
        self.router = router
        self.dataManager = dataManager
        self.networkManager = networkManager
        self.interfaceManager = interfaceManager
        self.internalEventPublisher = PassthroughSubject<AuthorizationViewModelInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AuthorizationViewModelExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension AuthorizationViewModel {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        router?.externalEventPublisher.sink { [weak self] in
            self?.routerEventHandler($0)
        }.store(in: &subscriptions)
        
        dataManager.externalEventPublisher.sink { [weak self] in
            self?.dataManagerEventHandler($0)
        }.store(in: &subscriptions)
        
        networkManager.responsePublisher.sink { [weak self] in
            self?.networkManagerResponseHandler($0)
        }.store(in: &subscriptions)
        
        interfaceManager.publisher.sink { [weak self] _ in
            self?.dataManager.internalEventPublisher.send(.view)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AuthorizationViewModelInternalEvent) {
        switch event {
            case .dataRequest:
                dataManager.internalEventPublisher.send(.view)
                router?.internalEventPublisher.send(.output(.action(.activityRequest)))
        
            case .select(let value):
                transition(value)
        }
    }
    
    func transition(_ value: AuthorizationViewModelSelectEvent) {
        switch value {
            case .telegram:
                dataManager.internalEventPublisher.send(.telegram)
                
            case .phone:
                router?.internalEventPublisher.send(.transition(.phone))
        }
    }
    
    func routerEventHandler(_ event: AuthorizationRouterExternalEvent) {
        switch event {
            case .start(let type):
                dataManager.internalEventPublisher.send(.shift(type))
            
            case .output(let value):
                guard case let .trigger(type) = value, case let .route(result) = type, case let .success(path) = result else { return }
                dataManager.internalEventPublisher.send(.route(path))
        }
    }
    
    func dataManagerEventHandler(_ event: AuthorizationDataManagerExternalEvent) {
        switch event {
            case .shift(let value):
                router?.internalEventPublisher.send(.transition(.shift(value)))
            
            case .view(let value):
                externalPublisher.send(.data(value))
            
            case .telegram(let url):
                router?.internalEventPublisher.send(.transition(.open(url)))
            
            case .request(let value):
                router?.internalEventPublisher.send(.transition(.spinner(.start(.defаult))))
                externalPublisher.send(.animation(.active))
                networkManager.requestPublisher.send(value)
            
            case .notify(let type):
                router?.internalEventPublisher.send(.transition(.notify(type)))
            
            case .brеak:
                router?.internalEventPublisher.send(.output(.trigger(.route(.failure(.system)))))
            
            case .exit:
                router?.internalEventPublisher.send(.output(.action(.exit)))
                router?.internalEventPublisher.send(completion: .finished)
        }
    }

    func networkManagerResponseHandler(_ result: Result<AuthorizationNetworkData, NSError>) {
        router?.internalEventPublisher.send(.transition(.spinner(.stop)))
        externalPublisher.send(.animation(.inactive))
        dataManager.internalEventPublisher.send(.response(result))
        guard case let .failure(error) = result else { return }
        router?.internalEventPublisher.send(.output(.trigger(.route(.failure(error)))))
    }
    
}

// MARK: - AuthorizationViewModelInternalEvent
enum AuthorizationViewModelInternalEvent {
    case dataRequest
    case select(AuthorizationViewModelSelectEvent)
}

// MARK: - AuthorizationViewModelSelectEvent
enum AuthorizationViewModelSelectEvent {
    case telegram
    case phone
}

// MARK: - AuthorizationViewModelExternalEvent
enum AuthorizationViewModelExternalEvent {
    case data(AuthorizationViewData)
    case animation(ActionTargetState)
}
