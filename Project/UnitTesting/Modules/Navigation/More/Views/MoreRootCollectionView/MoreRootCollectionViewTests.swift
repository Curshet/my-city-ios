import XCTest
import Combine
@testable import my_isp

final class MoreRootCollectionViewTests: XCTestCase {

    private var dataSource: MoreRootCollectionViewDataSourceMock!
    private var delegate: AppCollectionViewDelegateProtocol!
    private var layout: UICollectionViewLayout!
    private var view: MoreRootCollectionView!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        dataSource = MoreRootCollectionViewDataSourceMock()
        delegate = AppCollectionViewDelegate()
        layout = UICollectionViewLayout()
        view = MoreRootCollectionView(dataSource: dataSource, delegate: delegate, layout: layout)
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
        let layout = MoreRootViewLayout()
        let data = MoreRootViewData(layout: layout, items: [])
        
        dataSource.dataPublisher.sink { [weak expectation] _ in
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        view.dataPublisher.send(data)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testSelectionEvent() {
        let expectation = XCTestExpectation()

        view.selectPublisher.sink { [weak expectation] _ in
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        dataSource.selectDataPublisher.send(.supportScreen)
        
        wait(for: [expectation], timeout: 2)
    }
    
}
