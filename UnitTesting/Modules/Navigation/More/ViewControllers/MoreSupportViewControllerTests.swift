import XCTest
import Combine
@testable import my_isp

final class MoreSupportViewControllerTests: XCTestCase {
    
    private var viewModel: MoreSupportViewModelProtocol!
    private var collectionViewDataSource: MoreSupportCollectionViewDataSourceMock!
    private var view: MoreSupportCollectionViewMock!
    private var viewController: MoreSupportViewController!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = MoreSupportViewModelMock()
        collectionViewDataSource = MoreSupportCollectionViewDataSourceMock()
        view = MoreSupportCollectionViewMock(collectionViewDataSource)
        viewController = MoreSupportViewController(viewModel: viewModel, view: view)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        collectionViewDataSource = nil
        view = nil
        viewController = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
    
    func testDataRequest() {
        let expectation = XCTestExpectation()
        
        view.dataPublisher.sink { [weak expectation] _ in
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        viewModel.internalEventPublisher.send(.dataRequest)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testSetupNavigationBar() {
        let expectation = XCTestExpectation()
        
        viewModel.internalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .setupNavigationBar:
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        viewController.viewWillAppear(false)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testSelectionEvent() {
        let expectation = XCTestExpectation()
        
        viewModel.internalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .transition(let type):
                    XCTAssertEqual(type, .phone)
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        collectionViewDataSource.selectDataPublisher.send(.phone)
        
        wait(for: [expectation], timeout: 2)
    }
    
}

// MARK: - MoreSupportViewModelMock
fileprivate class MoreSupportViewModelMock: MoreSupportViewModelProtocol {

    let internalEventPublisher = PassthroughSubject<MoreSupportViewModelInternalEvent, Never>()
    
    var dataPublisher: AnyPublisher<MoreSupportViewData, Never> {
        internalDataPublisher.eraseToAnyPublisher()
    }
    
    private let internalDataPublisher = PassthroughSubject<MoreSupportViewData, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    private func internalEventHandler(_ event: MoreSupportViewModelInternalEvent) {
        switch event {
            case .dataRequest:
                let layout = MoreSupportViewLayout()
                let data = MoreSupportViewData(layout: layout, items: [])
                internalDataPublisher.send(data)

            default:
                break
        }
    }
    
}

// MARK: - MoreSupportCollectionViewMock
fileprivate class MoreSupportCollectionViewMock: MoreSupportCollectionView {
    
    init(_ dataSource: MoreSupportCollectionViewDataSourceProtocol) {
        let layout = UICollectionViewLayout()
        super.init(dataSource: dataSource, delegate: nil, layout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - MoreSupportCollectionViewDataSourceMock
final class MoreSupportCollectionViewDataSourceMock: NSObject, MoreSupportCollectionViewDataSourceProtocol {

    let dataPublisher = PassthroughSubject<[Any], Never>()
    
    var selectPublisher: AnyPublisher<MoreSupportViewModelSelectEvent, Never> {
        selectDataPublisher.eraseToAnyPublisher()
    }
    
    let selectDataPublisher = PassthroughSubject<MoreSupportViewModelSelectEvent, Never>()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        defaultCell(collectionView, indexPath)
    }

}
