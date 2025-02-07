import XCTest
import Combine
@testable import my_isp

final class AppUserManagerTests: XCTestCase {
   
    private var storage: UserStorageProtocol!
    private var userManager: AppUserManager!
    private var subscriptions: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        storage = UserStorageMock()
        userManager = AppUserManager(storage: storage)
        subscriptions = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        storage = nil
        userManager = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
    
    func testCorrectToken() {
        let expectation = XCTestExpectation()
        let token = "Test"
        
        userManager.externalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .authorizationStatus(let status):
                    XCTAssertEqual(status, .avaliable)
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        userManager.internalEventPublisher.send(.saveInfo(.accessToken(token)))
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testIncorrectToken() {
        let expectation = XCTestExpectation()
        let emptyToken = ""
        
        userManager.externalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .tokenError(_):
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        userManager.internalEventPublisher.send(.saveInfo(.accessToken(emptyToken)))
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testUserLogout() {
        let expectation = XCTestExpectation()
        
        userManager.externalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .logout:
                    expectation?.fulfill()
            
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        userManager.internalEventPublisher.send(.logout)
        
        wait(for: [expectation], timeout: 2)
    }
    
}
