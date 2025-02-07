import Foundation
import Combine

class AuthorizationPhoneCodeViewModel: AuthorizationPhoneCodeViewModelProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationPhoneCodeViewModelInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AppPhoneCodeViewInternalEvent, Never>
    
    private weak var router: AuthorizationRouterProtocol?
    private weak var timer: AppTimerProtocol?
    private weak var userManager: AppUserManagerControlProtocol?
    private weak var dataCache: AuthorizationPhoneCodeDataCacheInfoProtocol?
    private let dataSource: AuthorizationPhoneCodeDataSourceProtocol
    private let networkManager: AuthorizationPhoneCodeNetworkManagerProtocol
    private let interfaceManager: InterfaceManagerInfoProtocol
    private let externalPublisher: PassthroughSubject<AppPhoneCodeViewInternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    private let mainQueue: DispatchQueue
    private var dataRequestItem: DispatchWorkItem?
    private var networkRequestItem: DispatchWorkItem?
    
    init(dependencies: AuthorizationPhoneCodeViewModelDependencies) {
        self.router = dependencies.router
        self.timer = dependencies.timer
        self.userManager = dependencies.userManager
        self.dataCache = dependencies.dataCache
        self.dataSource = dependencies.dataSource
        self.networkManager = dependencies.networkManager
        self.interfaceManager = dependencies.interfaceManager
        self.internalEventPublisher = PassthroughSubject<AuthorizationPhoneCodeViewModelInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AppPhoneCodeViewInternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        self.mainQueue = DispatchQueue.main
        setupObservers()
    }
    
}

// MARK: Private
private extension AuthorizationPhoneCodeViewModel {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        router?.externalEventPublisher.sink { [weak self] in
            self?.routerEventHandler($0)
        }.store(in: &subscriptions)
        
        dataSource.externalEventPublisher.sink { [weak self] in
            self?.dataSourceEventHandler($0)
        }.store(in: &subscriptions)
        
        networkManager.responsePublisher.sink { [weak self] in
            self?.networkManagerResponseHandler($0)
        }.store(in: &subscriptions)
        
        interfaceManager.publisher.sink { [weak self] _ in
            self?.dataSource.internalEventPublisher.send(.view)
        }.store(in: &subscriptions)
    }
    
    func routerEventHandler(_ event: AuthorizationRouterExternalEvent) {
        guard case .output(let value) = event, case let .trigger(type) = value else { return }
                
        switch type {
            case .route(let value):
                routeHandler(value)
            
            case .response:
                externalPublisher.send(.reset)
            
            default:
                break
        }
    }
    
    func routeHandler(_ value: Result<String, NSError>) {
        switch value {
            case .success:
                externalPublisher.send(.animation(.active))
            
            case .failure:
                externalPublisher.send(.animation(.inactive))
        }
    }
    
    func internalEventHandler(_ event: AuthorizationPhoneCodeViewModelInternalEvent) {
        switch event {
            case .dataRequest:
                dataRequest()
            
            case .select(let value):
                transition(value)
        }
    }
    
    func dataRequest() {
        dataSource.internalEventPublisher.send(.view)
        
        timer?.publisher.sink { [weak self] in
            self?.timerEventHandler($0)
        }.store(in: &subscriptions)
        
        dataRequestItem = DispatchWorkItem { [weak self] in
            self?.dataSource.internalEventPublisher.send(.repeаt)
        }
        
        mainQueue.asyncAfter(seconds: 1.2, item: dataRequestItem)
    }
    
    func transition(_ value: AppPhoneCodeViewExternalEvent) {
        networkRequestItem?.cancel()
        
        switch value {
            case .validation(let code):
                validation(code)
            
            case .repeаt:
                externalPublisher.send(.animation(.active))
                router?.internalEventPublisher.send(.output(.trigger(.request)))
            
            case .exit:
                router?.internalEventPublisher.send(.transition(.phone))
            
            default:
                break
        }
    }
    
    func timerEventHandler(_ event: AppTimeEvent) {
        dataRequestItem?.cancel()
        
        switch event {
            case .countdown(let seconds):
                dataSource.internalEventPublisher.send(.timer(seconds))

            case .stop:
                dataSource.internalEventPublisher.send(.repeаt)
            
            default:
                break
        }
    }
    
    func validation(_ code: String) {
        networkRequestItem = DispatchWorkItem { [weak self] in
            self?.dataSource.internalEventPublisher.send(.request(phone: self?.dataCache?.phone, code: code))
        }
        
        mainQueue.asyncAfter(seconds: 1, item: networkRequestItem)
    }
    
    func dataSourceEventHandler(_ event: AuthorizationPhoneCodeDataSourceExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(.data(value))
            
            case .timer(let value):
                externalPublisher.send(.timer(value))
            
            case .request(let value):
                router?.internalEventPublisher.send(.transition(.spinner(.start(.defаult))))
                externalPublisher.send(.animation(.active))
                networkManager.requestPublisher.send(value)
            
            case .notify(let type):
                router?.internalEventPublisher.send(.transition(.notify(type)))
        }
    }
    
    func networkManagerResponseHandler(_ result: Result<String, NSError>) {
        router?.internalEventPublisher.send(.transition(.spinner(.stop)))
        
        switch result {
            case .success(let data):
                userManager?.internalEventPublisher.send(.saveInfo(.userPhone(String(dataCache?.phone))))
                userManager?.internalEventPublisher.send(.saveInfo(.jsonWebToken(data)))
                
            case .failure(let error):
                externalPublisher.send(.reset)
                dataSource.internalEventPublisher.send(.notify(.request(error)))
        }
    }

}

// MARK: - AuthorizationPhoneCodeViewModelDependencies
struct AuthorizationPhoneCodeViewModelDependencies {
    let router: AuthorizationRouterProtocol
    let timer: AppTimerProtocol
    let userManager: AppUserManagerControlProtocol
    let dataCache: AuthorizationPhoneCodeDataCacheInfoProtocol
    let dataSource: AuthorizationPhoneCodeDataSourceProtocol
    let networkManager: AuthorizationPhoneCodeNetworkManagerProtocol
    let interfaceManager: InterfaceManagerInfoProtocol
}

// MARK: - AuthorizationPhoneCodeViewModelInternalEvent
enum AuthorizationPhoneCodeViewModelInternalEvent {
    case dataRequest
    case select(AppPhoneCodeViewExternalEvent)
}
