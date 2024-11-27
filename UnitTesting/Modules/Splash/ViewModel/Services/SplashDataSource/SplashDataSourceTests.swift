import XCTest
import Combine
@testable import my_isp

final class SplashDataSourceTests: XCTestCase {
    
    private var device: DeviceProtocol!
    private var notificationCenter: NotificationCenterProtocol!
    private var dataSource: SplashDataSource!
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        device = UIDevice()
        notificationCenter = NotificationCenter()
        dataSource = SplashDataSource(device: device, notificationCenter: notificationCenter)
        subscriptions = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        device = nil
        notificationCenter = nil
        dataSource = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
    
    func testDataSending() {
        let expectation = XCTestExpectation()
        
        dataSource.externalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .layout(_):
                    expectation?.fulfill()
                
            default:
                break
            }
        }.store(in: &subscriptions)
        
        dataSource.internalEventPublisher.send(.layout)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testAirplaneModeStatus() {
        let expectation = XCTestExpectation()
        
        dataSource.externalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .airplaneMode(_):
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        dataSource.internalEventPublisher.send(.airplaneMode)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testApplicationStateSending() {
        let expectation = XCTestExpectation()
        
        dataSource.externalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .applicationState(_):
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testAlertContentSending() {
        let expectation = XCTestExpectation()
        
        dataSource.externalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .alertContent(_):
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        dataSource.internalEventPublisher.send(.alertContent(type: .airplaneMode, leftAction: nil, rightAction: nil))
        
        wait(for: [expectation], timeout: 2)
    }
    
}
