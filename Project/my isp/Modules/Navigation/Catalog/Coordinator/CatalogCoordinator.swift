import Foundation
import Combine

class CatalogCoordinator: CatalogCoordinatorProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppInteractorActivity, Never>
    let externalEventPublisher: AnyPublisher<Void, Never>
    
    private weak var router: CatalogRouterProtocol?
    private let externalPublisher: PassthroughSubject<Void, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(router: CatalogRouterProtocol?) {
        self.router = router
        self.internalEventPublisher = PassthroughSubject<AppInteractorActivity, Never>()
        self.externalPublisher = PassthroughSubject<Void, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.router?.internalEventPublisher.send(.output(.trigger($0)))
        }.store(in: &subscriptions)
        
        router?.externalEventPublisher.sink { [weak self] in
            guard $0 == .activityRequest else { return }
            self?.externalPublisher.send()
        }.store(in: &subscriptions)
    }
    
}
