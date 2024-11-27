import XCTest
import Combine
@testable import my_isp

final class AppWindowTests: XCTestCase {

    private var interfaceManager: InterfaceManagerMock!
    private var window: AppWindow!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        interfaceManager = InterfaceManagerMock()
        window = AppWindow(interfaceManager: interfaceManager)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        interfaceManager = nil
        window = nil
        subscriptions = nil
        try super.tearDownWithError()
    }

    func testInterfaceStyleSwitching() {
        let expectation = XCTestExpectation()
        let traitCollection = UITraitCollection()

        interfaceManager.publisher.sink { [weak expectation] _ in
            expectation?.fulfill()
        }.store(in: &subscriptions)

        window.traitCollectionDidChange(traitCollection)
        
        wait(for: [expectation], timeout: 2)
    }

}

// MARK: - InterfaceManagerMock
final class InterfaceManagerMock: InterfaceManagerEventProtocol, InterfaceManagerUpdateProtocol {
    
    var publisher: AnyPublisher<UIUserInterfaceStyle, Never> {
        internalPublisher.eraseToAnyPublisher()
    }
    
    private let internalPublisher = PassthroughSubject<UIUserInterfaceStyle, Never>()
    
    func update() {
        internalPublisher.send(.unspecified)
    }
    
}
