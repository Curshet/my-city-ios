import Foundation
import Combine

class AuthorizationDataManager: AuthorizationDataManagerProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationDataManagerInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AuthorizationDataManagerExternalEvent, Never>
    
    var isLightMode: Bool {
        dataSource.isLightMode
    }
    
    private weak var userManager: AppUserManagerControlProtocol?
    private let dataSource: AuthorizationDataSourceProtocol
    private let externalPublisher: PassthroughSubject<AuthorizationDataManagerExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(userManager: AppUserManagerControlProtocol, dataSource: AuthorizationDataSourceProtocol) {
        self.userManager = userManager
        self.dataSource = dataSource
        self.internalEventPublisher = PassthroughSubject<AuthorizationDataManagerInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AuthorizationDataManagerExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension AuthorizationDataManager {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        userManager?.externalEventPublisher.sink { [weak self] in
            self?.userManagerEventHandler($0)
        }.store(in: &subscriptions)
        
        dataSource.externalEventPublisher.sink { [weak self] in
            self?.dataSourceEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AuthorizationDataManagerInternalEvent) {
        switch event {
            case .shift(let type):
                dataSource.internalEventPublisher.send(.shift(type))
            
            case .route(let path):
                dataSource.internalEventPublisher.send(.route(path))
            
            case .view:
                dataSource.internalEventPublisher.send(.view)
                
            case .telegram:
                dataSource.internalEventPublisher.send(.telegram)
            
            case .response(let result):
                responseHandler(result)
        }
    }
    
    func responseHandler(_ result: Result<AuthorizationNetworkData, NSError>) {
        switch result {
            case .success(let data):
                userManager?.internalEventPublisher.send(.saveInfo(.userPhone(String(data.phone))))
                userManager?.internalEventPublisher.send(.saveInfo(.jsonWebToken(String(data.token))))
                
            case .failure(let error):
                dataSource.internalEventPublisher.send(.notify(.request(error)))
        }
    }
    
    func userManagerEventHandler(_ event: AppUserManagerExternalEvent) {
        switch event {
            case .success(let value):
                guard value == .jsonWebToken else { return }
                externalPublisher.send(.exit)
            
            case .error(let value):
                guard value == .jsonWebToken else { return }
                externalPublisher.send(.brеak)
                dataSource.internalEventPublisher.send(.notify(.system))
                
            default:
                break
        }
    }
    
    func dataSourceEventHandler(_ event: AuthorizationDataSourceExternalEvent) {
        switch event {
            case .shift(let value):
                externalPublisher.send(.shift(value))
                
            case .view(let value):
                externalPublisher.send(.view(value))
            
            case .telegram(let url):
                externalPublisher.send(.telegram(url))
            
            case .request(let value):
                externalPublisher.send(.request(value))
            
            case .notify(let type):
                externalPublisher.send(.notify(type))
        }
    }
    
}

// MARK: - AuthorizationDataManagerInternalEvent
enum AuthorizationDataManagerInternalEvent {
    case shift(AuthorizationCoordinatorStart)
    case route(String)
    case view
    case telegram
    case response(Result<AuthorizationNetworkData, NSError>)
}

// MARK: - AuthorizationDataManagerExternalEvent
enum AuthorizationDataManagerExternalEvent {
    case shift(AuthorizationRouterShift)
    case view(AuthorizationViewData)
    case telegram(String)
    case request(AuthorizationNetworkRequest)
    case notify(AppUserNotificationType)
    case brеak
    case exit
}
