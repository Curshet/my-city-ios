import XCTest
import Combine
@testable import my_isp

final class SplashRouterTests: XCTestCase {
    
    private var router: SplashRouter!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        router = SplashRouter()
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        router = nil
        subscriptions = nil
        try super.tearDownWithError()
    }

    func testStartEvent() {
        let expectation = XCTestExpectation()
        
        router.externalEventPublisher.sink { [weak expectation] in
            XCTAssertEqual($0, .start)
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        router.internalEventPublisher.send(.start)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testExitEvent() {
        let expectation = XCTestExpectation()
        
        router.externalEventPublisher.sink { [weak expectation] in
            XCTAssertEqual($0, .exit)
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        router.internalEventPublisher.send(.exit)
        
        wait(for: [expectation], timeout: 2)
    }
    
}
