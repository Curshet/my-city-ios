import Foundation
import Combine

class IntercomCoordinator: IntercomCoordinatorProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppInteractorActivity, Never>
    
    private weak var router: IntercomRouterProtocol?
    private var subscriptions: Set<AnyCancellable>
    
    init(router: IntercomRouterProtocol) {
        self.router = router
        self.internalEventPublisher = PassthroughSubject<AppInteractorActivity, Never>()
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.router?.internalEventPublisher.send($0)
        }.store(in: &subscriptions)
    }
    
}
