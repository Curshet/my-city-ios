import Foundation
import Combine

class SplashCoordinator: SplashCoordinatorProtocol {
    
    let internalEventPublisher: PassthroughSubject<Void, Never>
    let externalEventPublisher: AnyPublisher<Void, Never>
    
    private let router: SplashRouterProtocol
    private let externalPublisher: PassthroughSubject<Void, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(router: SplashRouterProtocol) {
        self.router = router
        self.internalEventPublisher = PassthroughSubject<Void, Never>()
        self.externalPublisher = PassthroughSubject<Void, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.router.internalEventPublisher.send(.start)
        }.store(in: &subscriptions)
        
        router.externalEventPublisher.filter {
            $0 == .exit
        }.sink { [weak self] _ in
            self?.externalPublisher.send()
        }.store(in: &subscriptions)
    }
    
}
