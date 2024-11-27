import XCTest
import Combine
@testable import my_isp

final class ChatDataSourceTests: XCTestCase {
    
    private var bundle: BundleProtocol!
    private var device: DeviceProtocol!
    private var dataSource: ChatDataSource!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        bundle = Bundle.main
        device = UIDevice()
        dataSource = ChatDataSource(bundle: bundle, device: device)
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
        
        dataSource.publisher.sink { [weak expectation] in
            XCTAssertNotNil($0.request)
            XCTAssertFalse($0.script.isEmpty)
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        dataSource.request()
        
        wait(for: [expectation], timeout: 2)
    }

}
