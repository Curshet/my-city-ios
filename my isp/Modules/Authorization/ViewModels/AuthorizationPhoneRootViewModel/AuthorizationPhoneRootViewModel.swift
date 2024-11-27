import Foundation
import Combine

class AuthorizationPhoneRootViewModel: NSObject, AuthorizationPhoneRootViewModelProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootViewModelInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AuthorizationPhoneRootViewModelExternalEvent, Never>
    
    private weak var router: AuthorizationRouterProtocol?
    private weak var timer: AppTimerProtocol?
    private weak var dataCache: AuthorizationPhoneRootDataCacheControlProtocol?
    private let dataSource: AuthorizationPhoneRootDataSourceProtocol
    private let presenter: AppearancePresenterProtocol
    private let networkManager: AuthorizationPhoneRootNetworkManagerProtocol
    private let interfaceManager: InterfaceManagerInfoProtocol
    private let externalPublisher: PassthroughSubject<AuthorizationPhoneRootViewModelExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(dependencies: AuthorizationPhoneRootViewModelDependencies) {
        self.router = dependencies.router
        self.timer = dependencies.timer
        self.dataCache = dependencies.dataCache
        self.dataSource = dependencies.dataSource
        self.presenter = dependencies.presenter
        self.networkManager = dependencies.networkManager
        self.interfaceManager = dependencies.interfaceManager
        self.internalEventPublisher = PassthroughSubject<AuthorizationPhoneRootViewModelInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AuthorizationPhoneRootViewModelExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
    deinit {
        timer?.stop()
        dataCache?.removeData()
    }
    
}

// MARK: Private
private extension AuthorizationPhoneRootViewModel {
    
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
            self?.interfaceManagerEventHandler()
        }.store(in: &subscriptions)
    }
    
    func routerEventHandler(_ event: AuthorizationRouterExternalEvent) {
        guard case .output(let value) = event, case let .trigger(type) = value else { return }
        
        switch type {
            case .route(let value):
                routeHandler(value)
            
            case .request:
                dataSource.internalEventPublisher.send(.trigger(dataCache?.phone))
            
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
    
    func internalEventHandler(_ event: AuthorizationPhoneRootViewModelInternalEvent) {
        switch event {
            case .dataRequest:
                dataSource.internalEventPublisher.send(.view)
            
            case .setupNavigationBar:
                dataSource.internalEventPublisher.send(.navigationBarAppearance(presenter.information.navigationBar))
            
            case .select(let value):
                transition(value)
        }
    }
    
    func transition(_ value: AuthorizationPhoneRootViewModelSelectEvent) {
        switch value {
            case .activity(let value):
                activityHandler(value)
            
            case .enter(let text):
                dataSource.internalEventPublisher.send(.enter(text: text, phone: dataCache?.phone))
            
            case .rеturn:
                router?.internalEventPublisher.send(.transition(.root))
        }
    }
    
    func activityHandler(_ value: AuthorizationPhoneRootViewModelActivity) {
        switch value {
            case .input(let text):
                dataSource.internalEventPublisher.send(.input(text))
            
            case .paste:
                dataSource.internalEventPublisher.send(.paste)
        }
    }
    
    func dataSourceEventHandler(_ event: AuthorizationPhoneRootDataSourceExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(.data(value))
            
            case .navigationBarAppearance(let value):
                presenter.internalEvеntPublisher.send(.setup(.navigationBar(value)))
            
            case .textField(let value):
                externalPublisher.send(.textField(value))
            
            case .request(let value):
                guard let value else { return }
                networkRequestHandler(value)
            
            case .notify(let type):
                guard let type else { return }
                router?.internalEventPublisher.send(.transition(.notify(type)))
        }
    }
    
    func networkRequestHandler(_ value: AuthorizationPhoneRootNetworkRequest) {
        switch value.unique {
            case true:
                router?.internalEventPublisher.send(.transition(.spinner(.start(.defаult))))
                externalPublisher.send(.animation(.active))
                networkManager.requestPublisher.send(value)
            
            case false:
                router?.internalEventPublisher.send(.transition(.phoneCode))
        }
    }
    
    func networkManagerResponseHandler(_ result: Result<AuthorizationPhoneRootResponseData, NSError>) {
        router?.internalEventPublisher.send(.transition(.spinner(.stop)))
        externalPublisher.send(.animation(.inactive))
        
        switch result {
            case .success(let data):
                dataCache?.saveData(data.phone)
                timer?.start(seconds: data.timeInterval, repeats: false, action: nil)
                router?.internalEventPublisher.send(data.triggerred ? .output(.trigger(.response)) : .transition(.phoneCode))
            
            case .failure(let error):
                timer?.stop()
                router?.internalEventPublisher.send(.output(.trigger(.response)))
                dataSource.internalEventPublisher.send(.notify(.request(error)))
        }
    }
    
    func interfaceManagerEventHandler() {
        dataSource.internalEventPublisher.send(.navigationBarAppearance(presenter.information.navigationBar))
        dataSource.internalEventPublisher.send(.view)
    }
    
}

// MARK: - AuthorizationPhoneRootViewModelDependencies
struct AuthorizationPhoneRootViewModelDependencies {
    let router: AuthorizationRouterProtocol
    let timer: AppTimerProtocol
    let dataCache: AuthorizationPhoneRootDataCacheControlProtocol
    let dataSource: AuthorizationPhoneRootDataSourceProtocol
    let presenter: AppearancePresenterProtocol
    let networkManager: AuthorizationPhoneRootNetworkManagerProtocol
    let interfaceManager: InterfaceManagerInfoProtocol
}

// MARK: - AuthorizationPhoneRootViewModelInternalEvent
enum AuthorizationPhoneRootViewModelInternalEvent {
    case dataRequest
    case setupNavigationBar
    case select(AuthorizationPhoneRootViewModelSelectEvent)
}

// MARK: - AuthorizationPhoneRootViewModelSelectEvent
enum AuthorizationPhoneRootViewModelSelectEvent {
    case activity(AuthorizationPhoneRootViewModelActivity)
    case enter(String?)
    case rеturn
}

// MARK: - AuthorizationPhoneRootViewModelActivity
enum AuthorizationPhoneRootViewModelActivity {
    case input(String?)
    case paste
}

// MARK: - AuthorizationPhoneRootViewModelExternalEvent
enum AuthorizationPhoneRootViewModelExternalEvent {
    case data(AuthorizationPhoneRootViewData)
    case textField(AuthorizationPhoneRootCenterTextFieldState)
    case animation(ActionTargetState)
}
