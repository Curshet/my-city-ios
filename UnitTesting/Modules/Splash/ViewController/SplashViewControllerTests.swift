import XCTest
import Combine
@testable import my_isp

final class SplashViewControllerTests: XCTestCase {
    
    private var router: SplashRouterProtocol!
    private var connectionManagerInfo: ConnectionManagerInfoMock!
    private var viewModel: SplashViewModelMock!
    private var view: SplashViewProtocol!
    private var viewController: SplashViewController!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        router = SplashRouterMock()
        connectionManagerInfo = ConnectionManagerInfoMock()
        viewModel = SplashViewModelMock(router, connectionManagerInfo)
        view = SplashViewMock()
        viewController = SplashViewController(viewModel: viewModel, view: view)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        router = nil
        connectionManagerInfo = nil
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
    
    func testNormalConnectionStart() {
        let expectation = XCTestExpectation()
        connectionManagerInfo.isConnected = true
        
        router.externalEventPublisher.sink { [weak expectation] _ in
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        router.internalEventPublisher.send(.start)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testNormalConnectionInfoSending() {
        let expectation = XCTestExpectation()
        
        router.externalEventPublisher.sink { [weak expectation] _ in
            expectation?.fulfill()
        }.store(in: &subscriptions)
        
        router.internalEventPublisher.send(.start)
        connectionManagerInfo.internalPublisher.send((isConnected: true, connectionType: nil))
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testLostConnectionStart() {
        let expectation = XCTestExpectation()
        connectionManagerInfo.isConnected = false
        
        router.internalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .transition(_):
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        router.internalEventPublisher.send(.start)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testLostConnectionInfoSending() {
        let expectation = XCTestExpectation()
        
        router.internalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .transition(_):
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        router.internalEventPublisher.send(.start)
        connectionManagerInfo.internalPublisher.send((isConnected: false, connectionType: nil))
        
        wait(for: [expectation], timeout: 2)
    }
    
}

// MARK: - SplashViewModelMock
fileprivate class SplashViewModelMock: SplashViewModel {
    
    init(_ router: SplashRouterProtocol?, _ connectionInfo: ConnectionManagerInfoProtocol) {
        let dataSource = SplashDataSourceMock()
        let connectionManager = ConnectionManagerMock(connectionInfo)
        let connectionTimer = AppTimerMock()
        let presenter = SplashPresenterMock()
        super.init(router: router, dataSource: dataSource, connectionManager: connectionManager, connectionTimer: connectionTimer, presenter: presenter)
    }
    
}

// MARK: - SplashViewMock
fileprivate class SplashViewMock: UIView, SplashViewProtocol {
    let dataPublisher = PassthroughSubject<SplashViewLayout, Never>()
}
