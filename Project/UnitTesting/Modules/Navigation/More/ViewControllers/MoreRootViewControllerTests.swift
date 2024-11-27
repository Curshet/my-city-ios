import XCTest
import Combine
@testable import my_isp

final class MoreRootViewControllerTests: XCTestCase {

    private var viewModel: MoreRootViewModelProtocol!
    private var collectionViewDataSource: MoreRootCollectionViewDataSourceMock!
    private var view: MoreRootCollectionViewMock!
    private var viewController: MoreRootViewController!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = MoreRootViewModelMock()
        collectionViewDataSource = MoreRootCollectionViewDataSourceMock()
        view = MoreRootCollectionViewMock(collectionViewDataSource)
        viewController = MoreRootViewController(viewModel: viewModel, view: view)
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
                case .select(_):
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        collectionViewDataSource.selectDataPublisher.send(.supportScreen)
        
        wait(for: [expectation], timeout: 2)
    }
    
}

// MARK: - MoreRootViewModelMock
fileprivate class MoreRootViewModelMock: MoreRootViewModelProtocol {

    let internalEventPublisher = PassthroughSubject<MoreRootViewModelInternalEvent, Never>()
    
    var dataPublisher: AnyPublisher<MoreRootViewData, Never> {
        internalDataPublisher.eraseToAnyPublisher()
    }
    
    private let internalDataPublisher = PassthroughSubject<MoreRootViewData, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    private func internalEventHandler(_ event: MoreRootViewModelInternalEvent) {
        switch event {
            case .dataRequest:
                let layout = MoreRootViewLayout()
                let data = MoreRootViewData(layout: layout, items: [])
                internalDataPublisher.send(data)

            default:
                break
        }
    }
    
}

// MARK: - MoreRootCollectionViewMock
fileprivate class MoreRootCollectionViewMock: MoreRootCollectionView {
    
    init(_ dataSource: MoreRootCollectionViewDataSourceProtocol) {
        let layout = UICollectionViewLayout()
        super.init(dataSource: dataSource, delegate: nil, layout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - MoreRootCollectionViewDataSourceMock
final class MoreRootCollectionViewDataSourceMock: NSObject, MoreRootCollectionViewDataSourceProtocol {
    
    let dataPublisher = PassthroughSubject<[MoreRootCellData], Never>()
    
    var selectPublisher: AnyPublisher<MoreRootViewModelSelectEvent, Never> {
        selectDataPublisher.eraseToAnyPublisher()
    }
    
    let selectDataPublisher = PassthroughSubject<MoreRootViewModelSelectEvent, Never>()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        defaultCell(collectionView, indexPath)
    }

}
