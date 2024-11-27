import Foundation
import Combine

class ChatCoordinator: ChatCoordinatorProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppInteractorActivity, Never>

    private weak var router: ChatRouterProtocol?
    private var subscriptions: Set<AnyCancellable>
    
    init(router: ChatRouterProtocol) {
        self.router = router
        self.internalEventPublisher = PassthroughSubject<AppInteractorActivity, Never>()
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.router?.internalEventPublisher.send(.trigger($0))
        }.store(in: &subscriptions)
    }
    
}
