import XCTest
import Combine
@testable import my_isp

final class MoreSupportDataSourceTests: XCTestCase {
    
    private var device: DeviceProtocol!
    private var dataSource: MoreSupportDataSource!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        device = UIDevice()
        dataSource = MoreSupportDataSource(device: device)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
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
    
    func testPathSending() {
        let expectation = XCTestExpectation()
        
        dataSource.externalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .path(let value):
                    XCTAssertFalse(value.isEmpty)
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        dataSource.internalEventPublisher.send(.path(.phone))
        
        wait(for: [expectation], timeout: 2)
    }
    
}
