import XCTest
import Combine
@testable import my_isp

final class SplashCoordinatorTests: XCTestCase {

    private var router: SplashRouterProtocol!
    private var coordinator: SplashCoordinator!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        router = SplashRouterMock()
        coordinator = SplashCoordinator(router: router)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        router = nil
        coordinator = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
    
    func testStartEvent() {
        let expectation = XCTestExpectation()
        
        router.internalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .start:
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        coordinator.startPublisher.send(nil)
        
        wait(for: [expectation], timeout: 2)
    }

    func testExitEvent() {
        let expectation = XCTestExpectation()
        
        coordinator.exitPublisher.sink { [weak expectation] _ in
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        router.internalEventPublisher.send(.exit)
        
        wait(for: [expectation], timeout: 2)
    }

}

// MARK: - SplashRouterMock
final class SplashRouterMock: SplashRouterProtocol {
    
    let internalEventPublisher = PassthroughSubject<SplashRouterInternalEvent, Never>()
    
    var externalEventPublisher: AnyPublisher<SplashRouterExternalEvent, Never> {
        externalEventDataPublisher.eraseToAnyPublisher()
    }
    
    private let externalEventDataPublisher = PassthroughSubject<SplashRouterExternalEvent, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    private func internalEventHandler(_ event: SplashRouterInternalEvent) {
        switch event {
            case .start:
                externalEventDataPublisher.send(.start)
            
            case .exit:
                externalEventDataPublisher.send(.exit)
            
            default:
                break
        }
    }
    
}
