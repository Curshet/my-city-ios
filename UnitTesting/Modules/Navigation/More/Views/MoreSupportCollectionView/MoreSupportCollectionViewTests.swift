import XCTest
import Combine
@testable import my_isp

final class MoreSupportCollectionViewTests: XCTestCase {

    private var dataSource: MoreSupportCollectionViewDataSourceMock!
    private var delegate: AppCollectionViewDelegateProtocol!
    private var layout: UICollectionViewLayout!
    private var view: MoreSupportCollectionView!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        dataSource = MoreSupportCollectionViewDataSourceMock()
        delegate = AppCollectionViewDelegate()
        layout = UICollectionViewLayout()
        view = MoreSupportCollectionView(dataSource: dataSource, delegate: delegate, layout: layout)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        dataSource = nil
        delegate = nil
        layout = nil
        view = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
    
    func testDataSending() {
        let expectation = XCTestExpectation()
        let layout = MoreSupportViewLayout()
        let data = MoreSupportViewData(layout: layout, items: [])
        
        dataSource.dataPublisher.sink { [weak expectation] _ in
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        view.dataPublisher.send(data)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testSelectionEvent() {
        let expectation = XCTestExpectation()

        view.selectPublisher.sink { [weak expectation] in
            XCTAssertEqual($0, .phone)
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        dataSource.selectDataPublisher.send(.phone)
        
        wait(for: [expectation], timeout: 2)
    }
    
}
