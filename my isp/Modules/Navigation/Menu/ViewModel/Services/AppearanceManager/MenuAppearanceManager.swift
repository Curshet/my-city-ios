import Foundation
import Combine

class MenuAppearanceManager: MenuAppearanceManagerProtocol {
    
    let internalEventPublisher: PassthroughSubject<MenuPresenterData, Never>
    let externalEventPublisher: AnyPublisher<MenuAppearancePresenterExternalEvent, Never>
    
    private let presenter: MenuAppearancePresenterProtocol
    private let interfaceManager: InterfaceManagerInfoProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(presenter: MenuAppearancePresenterProtocol, interfaceManager: InterfaceManagerInfoProtocol) {
        self.presenter = presenter
        self.interfaceManager = interfaceManager
        self.internalEventPublisher = PassthroughSubject<MenuPresenterData, Never>()
        self.externalEventPublisher = presenter.externalEventPublisher
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.presenter.internalEventPublisher.send(.setup($0))
        }.store(in: &subscriptions)
        
        interfaceManager.publisher.sink { [weak self] _ in
            self?.presenter.internalEventPublisher.send(.update)
        }.store(in: &subscriptions)
    }
    
}
