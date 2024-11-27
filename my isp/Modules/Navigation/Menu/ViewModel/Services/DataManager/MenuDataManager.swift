import Foundation
import Combine

class MenuDataManager: MenuDataManagerProtocol {
    
    let internalEventPublisher: PassthroughSubject<MenuDataManagerInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MenuDataManagerExternalEvent, Never>
    
    private weak var userManager: AppUserManagerControlProtocol?
    private let dataSource: MenuDataSourceProtocol
    private let externalPublisher: PassthroughSubject<MenuDataManagerExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(userManager: AppUserManagerControlProtocol, dataSource: MenuDataSourceProtocol) {
        self.userManager = userManager
        self.dataSource = dataSource
        self.internalEventPublisher = PassthroughSubject<MenuDataManagerInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MenuDataManagerExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension MenuDataManager {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        dataSource.externalEventPublisher.sink { [weak self] in
            self?.dataSourceEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MenuDataManagerInternalEvent) {
        switch event {
            case .start(let value):
                start(value)
            
            case .appearance(let target):
                appearanceRequest(target)
        }
    }
    
    func start(_ type: MenuCoordinatorStart) {
        if userManager?.information(of: .biometrics).biometrics != nil {
            dataSource.internalEventPublisher.send(.biometrics)
            return
        }
        
        if userManager?.information(of: .password).password != nil {
            dataSource.internalEventPublisher.send(.password)
            return
        }
        
        switch type {
            case .login:
                dataSource.internalEventPublisher.send(.login)
            
            case .navigation:
                dataSource.internalEventPublisher.send(.navigation)
        }
    }
    
    func appearanceRequest(_ target: MenuAppearancePresenterExternalEvent) {
        switch target {
            case .setup(let frame):
                dataSource.internalEventPublisher.send(.tabBarData(frame))
            
            case .update(let frame):
                dataSource.internalEventPublisher.send(.tabBarApperance(frame))
        }
    }
    
    func dataSourceEventHandler(_ type: MenuDataSourceExternalEvent) {
        switch type {
            case .login(let value):
                externalPublisher.send(.start(.login(value)))
            
            case .navigation(let value):
                externalPublisher.send(.start(.navigation(value)))
            
            case .tabBarData(let value):
                externalPublisher.send(.appearance(.setup(value)))
            
            case .tabBarApperance(let value):
                externalPublisher.send(.appearance(.update(value)))
        
            case .biometrics:
                externalPublisher.send(.biometrics)
        
            case .password:
                externalPublisher.send(.password)
        }
    }
    
}

// MARK: - MenuDataManagerInternalEvent
enum MenuDataManagerInternalEvent {
    case start(MenuCoordinatorStart)
    case appearance(MenuAppearancePresenterExternalEvent)
}

// MARK: - MenuDataManagerExternalEvent
enum MenuDataManagerExternalEvent {
    case start(MenuRouterShift)
    case appearance(MenuPresenterData)
    case biometrics
    case password
}
