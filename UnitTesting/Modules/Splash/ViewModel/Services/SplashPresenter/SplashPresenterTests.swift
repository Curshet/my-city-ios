import XCTest
import Combine
@testable import my_isp

final class SplashPresenterTests: XCTestCase {

    private var logoView: UIImageView!
    private var screen: ScreenProtocol!
    private var presenter: SplashPresenter!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        logoView = UIImageView()
        screen = UIScreen()
        presenter = SplashPresenter(logoView: logoView, screen: screen)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        logoView = nil
        screen = nil
        presenter = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
    
    func testExitEvent() {
        let expectation = XCTestExpectation()

        presenter.exitPublisher.sink { [weak expectation] _ in
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        presenter.internalEventPublisher.send(.force)
        
        wait(for: [expectation], timeout: 2)
    }

}
