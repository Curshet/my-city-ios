import Foundation
import Combine

class SplashViewModel: SplashViewModelProtocol {
    
    let internalEventPublisher: PassthroughSubject<SplashViewModelInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<SplashViewModelExternalEvent, Never>
    
    private weak var router: SplashRouterProtocol?
    private let dataSource: SplashDataSourceProtocol
    private let connectionManager: ConnectionManagerProtocol
    private let interfaceManager: InterfaceManagerInfoProtocol
    private let timer: AppTimerProtocol
    private let externalPublisher: PassthroughSubject<SplashViewModelExternalEvent, Never>
    private var state: SplashViewModelState
    private var subscriptions: Set<AnyCancellable>

    init(router: SplashRouterProtocol, dataSource: SplashDataSourceProtocol, connectionManager: ConnectionManagerProtocol, interfaceManager: InterfaceManagerInfoProtocol, timer: AppTimerProtocol) {
        self.router = router
        self.dataSource = dataSource
        self.connectionManager = connectionManager
        self.interfaceManager = interfaceManager
        self.timer = timer
        self.internalEventPublisher = PassthroughSubject<SplashViewModelInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<SplashViewModelExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.state = .free
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension SplashViewModel {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        router?.externalEventPublisher.filter {
            $0 == .start
        }.sink { [weak self] _ in
            self?.checkConnection()
        }.store(in: &subscriptions)

        dataSource.externalEventPublisher.sink { [weak self] in
            self?.dataSourceEventHandler($0)
        }.store(in: &subscriptions)
        
        interfaceManager.publisher.sink { [weak self] _ in
            self?.dataSource.internalEventPublisher.send(.view)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: SplashViewModelInternalEvent) {
        switch event {
            case .dataRequest:
                dataSource.internalEventPublisher.send(.view)
            
            case .exit:
                router?.internalEventPublisher.send(.exit)
                router?.internalEventPublisher.send(completion: .finished)
        }
    }
    
    func checkConnection() {
        if let isConnected = connectionManager.information.isConnected {
            finish(isConnected)
            return
        }
        
        connectionManager.publisher.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.finish($0.isConnected)
        }.store(in: &subscriptions)
    }
    
    func finish(_ isConnected: Bool) {
        guard state.isPresentable else { return }
        
        switch isConnected {
            case true:
                dataSource.internalEventPublisher.send(.exit)
                
            case false:
                changeState(.presenting)
        }
    }
    
    func dataSourceEventHandler(_ event: SplashDataSourceExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(.view(value))

            case .airplaneMode(let enabled):
                transition(enabled)
            
            case .alert(let value):
                router?.internalEventPublisher.send(.transition(.alert(value)))
            
            case .exit(let type):
                changeState(.exit(type))
        }
    }
    
    func transition(_ isAirplaneMode: Bool) {
        switch isAirplaneMode {
            case true:
                dataSource.internalEventPublisher.send(.alert(type: .airplaneMode, leftAction: { [weak self] in self?.backgroundReconnection() }, rightAction: { [weak self] in self?.router?.internalEventPublisher.send(.transition(.settings)); self?.backgroundReconnection() }))
            
            case false:
                dataSource.internalEventPublisher.send(.alert(type: .connectionError, leftAction: { [weak self] in self?.backgroundReconnection() }, rightAction: { [weak self] in self?.foregroundReconnection() }))
        }
    }
    
    func changeState(_ type: SplashViewModelState) {
        switch type {
            case .free, .timer:
                state = type
                timer.stop()
                
            case .presenting:
                state = type
                timer.stop()
                dataSource.internalEventPublisher.send(.airplaneMode)
            
            case .exit(let target):
                state = .presenting
                timer.stop()
                exit(target)
        }
    }
    
    func exit(_ target: SplashImageViewLayout?) {
        switch target {
            case .some(let value):
                externalPublisher.send(.animation(value))
            
            case nil:
                router?.internalEventPublisher.send(.exit)
                router?.internalEventPublisher.send(completion: .finished)
        }
    }
    
    func foregroundReconnection() {
        changeState(.timer)
        
        let action: () -> Void = { [weak self] in
            guard let isConnected = self?.connectionManager.information.isConnected, isConnected else {
                self?.changeState(.presenting)
                return
            }
            
            self?.dataSource.internalEventPublisher.send(.exit)
        }
        
        timer.start(seconds: 5, repeats: false, action: action)
    }
    
    func backgroundReconnection() {
        changeState(.timer)
        
        let action: () -> Void = { [weak self] in
            guard let isConnected = self?.connectionManager.information.isConnected, isConnected else { return }

            self?.dataSource.internalEventPublisher.send(.exit)
        }

        timer.start(seconds: 3, repeats: true, action: action)
    }
    
}

// MARK: - SplashViewModelStates
fileprivate enum SplashViewModelState {
    case free
    case presenting
    case timer
    case exit(SplashImageViewLayout?)
    
    var isPresentable: Bool {
        switch self {
            case .free:
                true
            
            default:
                false
        }
    }
}

// MARK: - SplashViewModelInternalEvent
enum SplashViewModelInternalEvent {
    case dataRequest
    case exit
}

// MARK: - SplashViewModelExternalEvent
enum SplashViewModelExternalEvent {
    case view(SplashViewData)
    case animation(SplashImageViewLayout)
}
