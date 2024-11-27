import XCTest
import Combine
@testable import my_isp

final class ChatViewModelTests: XCTestCase {
    
    private var dataSource: ChatDataSourceProtocol!
    private var presenter: AppearancePresenterProtocol!
    private var viewModel: ChatViewModel!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        dataSource = ChatDataSourceMock()
        presenter = ApperancePresenterMock()
        viewModel = ChatViewModel(router: nil, dataSource: dataSource, presenter: presenter)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        dataSource = nil
        presenter = nil
        viewModel = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
    
    func testSetupNavigationBar() {
        let expectation = XCTestExpectation()
        
        presenter.internalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .chatViewController:
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        viewModel.internalEventPublisher.send(.setupNavigationBar)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testDataSending() {
        let expectation = XCTestExpectation()
        
        viewModel.dataPublisher.sink { [weak expectation] _ in
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        viewModel.internalEventPublisher.send(.dataRequest)
        
        wait(for: [expectation], timeout: 2)
    }

}

// MARK: - ChatDataSourceMock
fileprivate class ChatDataSourceMock: ChatDataSourceProtocol {
    
    var publisher: AnyPublisher<ChatData, Never> {
        internalDataPublisher.eraseToAnyPublisher()
    }
    
    private let internalDataPublisher = PassthroughSubject<ChatData, Never>()
    
    func request() {
        let layout = ChatViewLayout()
        let data = ChatData(layout: layout, request: nil, script: "Test")
        internalDataPublisher.send(data)
    }
    
}

// MARK: - ApperancePresenterMock
final class ApperancePresenterMock: AppearancePresenterProtocol {
    let internalEventPublisher = PassthroughSubject<AppearancePresenterInternalEvent, Never>()
}
