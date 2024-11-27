import XCTest
import Combine
import Network
@testable import my_isp

final class SplashViewModelTests: XCTestCase {

    private var router: SplashRouterProtocol!
    private var dataSource: SplashDataSourceMock!
    private var connectionManagerInfo: ConnectionManagerInfoMock!
    private var connectionManager: ConnectionManagerMock!
    private var connectionTimer: AppTimerProtocol!
    private var presenter: SplashPresenterProtocol!
    private var viewModel: SplashViewModel!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        router = SplashRouterMock()
        dataSource = SplashDataSourceMock()
        connectionManagerInfo = ConnectionManagerInfoMock()
        connectionManager = ConnectionManagerMock(connectionManagerInfo)
        connectionTimer = AppTimerMock()
        presenter = SplashPresenterMock()
        viewModel = SplashViewModel(router: router, dataSource: dataSource, connectionManager: connectionManager, connectionTimer: connectionTimer, presenter: presenter)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        router = nil
        dataSource = nil
        connectionManagerInfo = nil
        connectionManager = nil
        connectionTimer = nil
        presenter = nil
        viewModel = nil
        subscriptions = nil
        try super.tearDownWithError()
    }

    func testDataRequest() {
        let expectation = XCTestExpectation()

        viewModel.dataPublisher.sink { [weak expectation] _ in
            expectation?.fulfill()
        }.store(in: &subscriptions)

        viewModel.dataRequest()
        
        wait(for: [expectation], timeout: 2)
    }

    func testAlertPresenting() {
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

    func testExitEvent() {
        let expectation = XCTestExpectation()

        router.externalEventPublisher.sink { [weak expectation] in
            XCTAssertEqual($0, .exit)
            expectation?.fulfill()
        }.store(in: &subscriptions)

        presenter.internalEventPublisher.send(.force)
        
        wait(for: [expectation], timeout: 2)
    }

}

// MARK: - SplashDataSourceMock
final class SplashDataSourceMock: SplashDataSourceProtocol {

    let internalEventPublisher = PassthroughSubject<SplashDataSourceInternalEvent, Never>()
    
    var isAirplaneMode = false

    var externalEventPublisher: AnyPublisher<SplashDataSourceExternalEvent, Never> {
        externalEvenDataPublisher.eraseToAnyPublisher()
    }

    private let externalEvenDataPublisher = PassthroughSubject<SplashDataSourceExternalEvent, Never>()
    private var subscriptions = Set<AnyCancellable>()

    init() {
        setupObservers()
    }

    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    private func internalEventHandler(_ event: SplashDataSourceInternalEvent) {
        switch event {
            case .layout:
                let value = SplashViewLayout()
                externalEvenDataPublisher.send(.layout(value))
            
            case .airplaneMode:
                externalEvenDataPublisher.send(.airplaneMode(isEnabled: isAirplaneMode))

            case .alertContent(_, _, _):
                let value = SplashAlertData(title: "", message: "", leftTitle: "", rightTitle: "", leftAction: nil, rightAction: nil)
                externalEvenDataPublisher.send(.alertContent(value))
        }
    }

}

// MARK: - SplashPresenterMock
final class SplashPresenterMock: SplashPresenterProtocol {

    let internalEventPublisher = PassthroughSubject<SplashPresenterInternalEvent, Never>()

    var exitPublisher: AnyPublisher<Void, Never> {
        exitDataPublisher.eraseToAnyPublisher()
    }

    private let exitDataPublisher = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>()

    init() {
        setupObservers()
    }

    private func setupObservers() {
        internalEventPublisher.sink { [weak self] _ in
            self?.exitDataPublisher.send()
        }.store(in: &subscriptions)
    }

}

// MARK: - AppTimerMock
final class AppTimerMock: AppTimerProtocol {

    var publisher: AnyPublisher<AppTimerEvent, Never> {
        internalPublisher.eraseToAnyPublisher()
    }

    private let internalPublisher = PassthroughSubject<AppTimerEvent, Never>()

    func start(seconds: Int, repeats: Bool, action: (() -> Void)?) {
        internalPublisher.send(.start)
        stop()
    }

    func stop() {
        internalPublisher.send(.stop)
    }

}
