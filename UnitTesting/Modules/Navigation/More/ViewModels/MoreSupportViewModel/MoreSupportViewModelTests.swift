import XCTest
import Combine
@testable import my_isp

final class MoreSupportViewModelTests: XCTestCase {
    
    private var router: MoreRouterProtocol!
    private var dataSource: MoreSupportDataSourceProtocol!
    private var pasteboard: PasteboardProtocol!
    private var presenter: AppearancePresenterProtocol!
    private var viewModel: MoreSupportViewModel!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        router = MoreRouterMock()
        presenter = ApperancePresenterMock()
        dataSource = MoreSupportDataSourceMock()
        pasteboard = UIPasteboard()
        viewModel = MoreSupportViewModel()
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        router = nil
        presenter = nil
        dataSource = nil
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

        viewModel.internalEventPublisher.send(.inject(router: router, dataSource: dataSource, pasteboard: pasteboard, presenter: presenter))
        viewModel.internalEventPublisher.send(.dataRequest)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testSetupNavigationBar() {
        let expectation = XCTestExpectation()
        
        presenter.internalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .moreSupportViewController:
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        viewModel.internalEventPublisher.send(.inject(router: router, dataSource: dataSource, pasteboard: pasteboard, presenter: presenter))
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
        
        viewModel.internalEventPublisher.send(.inject(router: router, dataSource: dataSource, pasteboard: pasteboard, presenter: presenter))
        viewModel.internalEventPublisher.send(.transition(.phone))
        
        wait(for: [expectation], timeout: 2)
    }
    
}

// MARK: - MoreSupportDataSourceMock
fileprivate class MoreSupportDataSourceMock: MoreSupportDataSourceProtocol {
    
    let internalEventPublisher = PassthroughSubject<MoreSupportDataSourceInternalEvent, Never>()
    
    var externalEventPublisher: AnyPublisher<MoreSupportDataSourceExternalEvent, Never> {
        externalEventDataPublisher.eraseToAnyPublisher()
    }
    
    private let externalEventDataPublisher = PassthroughSubject<MoreSupportDataSourceExternalEvent, Never>()
    private var subscription = Set<AnyCancellable>()
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscription)
    }
    
    private func internalEventHandler(_ event: MoreSupportDataSourceInternalEvent) {
        switch event {
            case .data:
                let layout = MoreSupportViewLayout()
                let data = MoreSupportViewData(layout: layout, items: [])
                externalEventDataPublisher.send(.data(data))
        
            case .path(_):
                externalEventDataPublisher.send(.path(value: ""))
        }
    }
}
