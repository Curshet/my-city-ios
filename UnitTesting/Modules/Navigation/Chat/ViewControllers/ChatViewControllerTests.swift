import XCTest
import Combine
@testable import my_isp

final class ChatViewControllerTests: XCTestCase {

    private var viewModel: ChatViewModelProtocol!
    private var view: ChatWebViewProtocol!
    private var viewController: ChatViewController!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = ChatViewModelMock()
        view = ChatWebViewMock()
        viewController = ChatViewController(viewModel: viewModel, view: view)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        viewModel = nil
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
        
        viewController.loadViewIfNeeded()
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testSetupNavigationBar() {
        let expectation = XCTestExpectation()
        
        viewModel.internalEventPublisher.sink { [weak expectation] in
            XCTAssertEqual($0, .setupNavigationBar)
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        viewController.viewWillAppear(false)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testRequestError() {
        let expectation = XCTestExpectation()
        let layout = ChatViewLayout()
        let data = ChatData(layout: layout, request: nil, script: "Test")
        
        viewModel.internalEventPublisher.sink { [weak expectation] in
            XCTAssertEqual($0, .requestError)
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        view.dataPublisher.send(data)
        
        wait(for: [expectation], timeout: 2)
    }

}

// MARK: - ChatViewModelMock
fileprivate class ChatViewModelMock: ChatViewModelProtocol {
    
    let internalEventPublisher = PassthroughSubject<ChatViewModelInternalEvent, Never>()
    
    var dataPublisher: AnyPublisher<ChatData, Never> {
        internalDataPublisher.eraseToAnyPublisher()
    }
    
    private let internalDataPublisher = PassthroughSubject<ChatData, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    private func internalEventHandler(_ event: ChatViewModelInternalEvent) {
        switch event {
            case .dataRequest:
                let layout = ChatViewLayout()
                let data = ChatData(layout: layout, request: nil, script: "Test")
                internalDataPublisher.send(data)

            default:
                break
        }
    }
    
}

// MARK: - ChatWebViewMock
fileprivate class ChatWebViewMock: UIView, ChatWebViewProtocol {
    
    let dataPublisher = PassthroughSubject<ChatData, Never>()
    
    var externalEventPublisher: AnyPublisher<ChatViewModelInternalEvent, Never> {
        externalEventDataPublisher.eraseToAnyPublisher()
    }
    
    private let externalEventDataPublisher = PassthroughSubject<ChatViewModelInternalEvent, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        super.init(frame: .zero)
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupObservers() {
        dataPublisher.sink { [weak self] in
            guard $0.request != nil else {
                self?.externalEventDataPublisher.send(.requestError)
                return
            }
            
            guard !$0.script.isEmpty else {
                self?.externalEventDataPublisher.send(.requestError)
                return
            }
        }.store(in: &subscriptions)
    }
    
}
