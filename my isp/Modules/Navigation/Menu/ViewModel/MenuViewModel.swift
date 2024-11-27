import Foundation
import Combine

class MenuViewModel: MenuViewModelProtocol {
    
    private weak var router: MenuRouterProtocol?
    private let dataManager: MenuDataManagerProtocol
    private let appearanceManager: MenuAppearanceManagerProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(router: MenuRouterProtocol, dataManager: MenuDataManagerProtocol, appearanceManager: MenuAppearanceManagerProtocol) {
        self.router = router
        self.dataManager = dataManager
        self.appearanceManager = appearanceManager
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension MenuViewModel {
    
    func setupObservers() {
        router?.externalEventPublisher.sink { [weak self] in
            guard case let .start(value) = $0 else { return }
            self?.dataManager.internalEventPublisher.send(.start(value))
        }.store(in: &subscriptions)
        
        dataManager.externalEventPublisher.sink { [weak self] in
            self?.dataManagerEventHandler($0)
        }.store(in: &subscriptions)
        
        appearanceManager.externalEventPublisher.sink { [weak self] in
            self?.dataManager.internalEventPublisher.send(.appearance($0))
        }.store(in: &subscriptions)
    }
    
    func dataManagerEventHandler(_ event: MenuDataManagerExternalEvent) {
        switch event {
            case .start(let value):
                router?.internalEventPublisher.send(.transition(.shift(value)))
            
            case .appearance(let value):
                appearanceManager.internalEventPublisher.send(value)

            case .biometrics:
                router?.internalEventPublisher.send(.transition(.biometrics))
        
            case .password:
                router?.internalEventPublisher.send(.transition(.password))
        }
    }
    
}
