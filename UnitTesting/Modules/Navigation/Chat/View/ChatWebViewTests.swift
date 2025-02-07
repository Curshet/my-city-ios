import XCTest
import WebKit
import Combine
@testable import my_isp

final class ChatWebViewTests: XCTestCase {
    
    private var refreshControl: AppRefreshControl!
    private var configuration: WKWebViewConfiguration!
    private var view: ChatWebView!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        refreshControl = AppRefreshControl()
        configuration = WKWebViewConfiguration()
        view = ChatWebView(refreshControl: refreshControl, configuration: configuration)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        refreshControl = nil
        configuration = nil
        view = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
    
    func testRefreshControl() {
        let expectation = XCTestExpectation()
        
        view.externalEventPublisher.sink { [weak expectation] in
            XCTAssertEqual($0, .dataRequest)
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        refreshControl.sendActions(for: .valueChanged)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testRequestError() {
        let expectation = XCTestExpectation()
        let layout = ChatViewLayout()
        let data = ChatData(layout: layout, request: nil, script: "Test")
        
        view.externalEventPublisher.sink { [weak expectation] in
            XCTAssertEqual($0, .requestError)
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        view.dataPublisher.send(data)
        
        wait(for: [expectation], timeout: 2)
    }
    
}
