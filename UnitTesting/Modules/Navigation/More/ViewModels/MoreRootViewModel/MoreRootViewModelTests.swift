import XCTest
import Combine
@testable import my_isp

final class MoreRootViewModelTests: XCTestCase {
    
    private var router: MoreRouterProtocol!
    private var dataSource: MoreRootDataSourceProtocol!
    private var presenter: AppearancePresenterProtocol!
    private var pasteboard: PasteboardProtocol!
    private var viewModel: MoreRootViewModel!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        router = MoreRouterMock()
        dataSource = MoreRootDataSourceMock()
        presenter = ApperancePresenterMock()
        pasteboard = UIPasteboard()
        viewModel = MoreRootViewModel(router: router, dataSource: dataSource, presenter: presenter, pasteboard: pasteboard)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        router = nil
        dataSource = nil
        presenter = nil
        pasteboard = nil
        viewModel = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
    
    func testDataRequest() {
        let expectation = XCTestExpectation()
        
        viewModel.dataPublisher.sink { [weak expectation] _ in
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        viewModel.internalEventPublisher.send(.dataRequest)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testSetupNavigationBar() {
        let expectation = XCTestExpectation()
        
        presenter.internalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .moreRootViewController:
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        viewModel.internalEventPublisher.send(.setupNavigationBar)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testTransitionEvent() {
        let expectation = XCTestExpectation()
        
        router.internalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .transition(_):
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        viewModel.internalEventPublisher.send(.select(.supportScreen))
        
        wait(for: [expectation], timeout: 2)
    }
    
}

// MARK: - MoreRootDataSourceMock
fileprivate class MoreRootDataSourceMock: MoreRootDataSourceProtocol {
    
    let internalEventPublisher = PassthroughSubject<MoreRootDataSourceInternalEvent, Never>()
    
    var externalEventPublisher: AnyPublisher<MoreRootDataSourceExternalEvent, Never> {
        externalEventDataPublisher.eraseToAnyPublisher()
    }
    
    private let externalEventDataPublisher = PassthroughSubject<MoreRootDataSourceExternalEvent, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    private func internalEventHandler(_ event: MoreRootDataSourceInternalEvent) {
        switch event {
            case .data:
                let layout = MoreRootViewLayout()
                let items = [MoreRootCellData]()
                let data = MoreRootViewData(layout: layout, items: items)
                externalEventDataPublisher.send(.data(data))
            
            case .systemInfo:
                let systemInfo = "Test"
                externalEventDataPublisher.send(.systemInfo(systemInfo))
        }
    }
    
}

// MARK: - MoreRouterMock
final class MoreRouterMock: MoreRouterProtocol {
    let internalEventPublisher = PassthroughSubject<MoreRouterInternalEvent, Never>()
}
