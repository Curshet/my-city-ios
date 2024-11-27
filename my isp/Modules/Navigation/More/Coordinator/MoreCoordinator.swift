import Foundation
import Combine

class MoreCoordinator: MoreCoordinatorProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppInteractorActivity, Never>
    
    private weak var router: MoreRouterProtocol?
    private var subscriptions: Set<AnyCancellable>
    
    init(router: MoreRouterProtocol) {
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
