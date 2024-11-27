import Foundation
import Combine

class IntercomDataManager: IntercomDataManagerProtocol {
    
    private weak var userManager: AppUserManagerControlProtocol?
    private let pushRegistry: IntercomVoipPushRegistryProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(userManager: AppUserManagerControlProtocol, pushRegistry: IntercomVoipPushRegistryProtocol) {
        self.userManager = userManager
        self.pushRegistry = pushRegistry
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
    private func setupObservers() {
        pushRegistry.publisher.sink { [weak self] in
            self?.userManager?.internalEventPublisher.send(.saveInfo(.voipToken($0.token)))
        }.store(in: &subscriptions)
    }
    
}
