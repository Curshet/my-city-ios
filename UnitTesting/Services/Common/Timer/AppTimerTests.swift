import XCTest
import Combine
@testable import my_isp

final class AppTimerTests: XCTestCase {
   
    private var timer: AppTimer!
    private var subscriptions: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        timer = AppTimer()
        subscriptions = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        timer = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
    
    func testStart() {
        let expectation = XCTestExpectation()
        
        timer.publisher.sink { [weak expectation, timer] in
            switch $0 {
                case .start:
                    timer?.stop()
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        timer.start(seconds: 1, repeats: false, action: nil)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testCountdown() {
        let expectation = XCTestExpectation()
        
        timer.publisher.sink { [weak expectation, timer] in
            switch $0 {
                case .countdown(_):
                    timer?.stop()
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        timer.start(seconds: 2, repeats: false, action: nil)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testStop() {
        let expectation = XCTestExpectation()
        
        timer.publisher.sink { [weak expectation] in
            switch $0 {
                case .stop:
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        timer.start(seconds: 1, repeats: false, action: nil)
        
        wait(for: [expectation], timeout: 2)
    }
    
}
