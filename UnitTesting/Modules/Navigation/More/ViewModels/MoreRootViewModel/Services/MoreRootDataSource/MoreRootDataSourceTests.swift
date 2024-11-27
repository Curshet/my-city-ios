import XCTest
import Combine
@testable import my_isp

final class MoreRootDataSourceTests: XCTestCase {

    private var bundle: BundleProtocol!
    private var device: DeviceProtocol!
    private var dataSource: MoreRootDataSource!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        bundle = Bundle()
        device = UIDevice()
        dataSource = MoreRootDataSource(bundle: bundle, device: device)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        bundle = nil
        device = nil
        dataSource = nil
        subscriptions = nil
        try super.tearDownWithError()
    }

    func testDataSending() {
        let expectation = XCTestExpectation()

        dataSource.externalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .data(let value):
                    XCTAssertFalse(value.items.isEmpty)
                    expectation?.fulfill()

                default:
                    break
            }
        }.store(in: &subscriptions)

        dataSource.internalEventPublisher.send(.data)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testSystemInfoSending() {
        let expectation = XCTestExpectation()

        dataSource.externalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .systemInfo(let value):
                    XCTAssertFalse(value.isEmpty)
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)

        dataSource.internalEventPublisher.send(.systemInfo)
        
        wait(for: [expectation], timeout: 2)
    }

}
