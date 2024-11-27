import XCTest
import Combine
@testable import my_isp

final class AuthorizationBuilderTests: XCTestCase {
   
    private var injector: InjectorProtocol!
    private var builder: AuthorizationBuilder!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        injector = Injector()
        builder = AuthorizationBuilder(injector: injector)
    }
    
    override func tearDownWithError() throws {
        injector = nil
        builder = nil
        try super.tearDownWithError()
    }
    
    func testContainerResolving() {
        let navigationController = injector.resolve(from: .authorization, type: AuthorizationNavigationController.self)
        XCTAssertNotNil(navigationController)
    }
    
    func testBuildingProcess() {
        let rootScrollViewDelegate = builder.rootScrollViewDelegate()
        let rootScrollView = builder.rootScrollView(rootScrollViewDelegate)
        let rootViewModel = builder.rootViewModel()
        let rootViewController = builder.rootViewController(rootViewModel, rootScrollView)
        let navigationViewModel = builder.navigationViewModel()
        let navigationController = builder.navigationController(navigationViewModel, rootViewController)
        let router = builder.router(navigationController)
        let coordinator = builder.coordinator(router)
        
        XCTAssertNotNil(rootScrollViewDelegate)
        XCTAssertNotNil(rootScrollView)
        XCTAssertNotNil(rootViewModel)
        XCTAssertNotNil(rootViewController)
        XCTAssertNotNil(navigationViewModel)
        XCTAssertNotNil(navigationController)
        XCTAssertNotNil(router)
        XCTAssertNotNil(coordinator)
    }
    
    func testBuildingTypes() {
        let rootScrollViewDelegate = builder.rootScrollViewDelegate()
        let rootScrollView = builder.rootScrollView(rootScrollViewDelegate)
        let rootViewModel = builder.rootViewModel()
        let rootViewController = builder.rootViewController(rootViewModel, rootScrollView)
        let navigationViewModel = builder.navigationViewModel()
        let navigationController = builder.navigationController(navigationViewModel, rootViewController)
        let router = builder.router(navigationController)
        let coordinator = builder.coordinator(router)
        
        XCTAssertTrue(rootScrollViewDelegate is AppScrollViewDelegate)
        XCTAssertTrue(rootViewModel is AuthorizationViewModel)
        XCTAssertTrue(navigationViewModel is AuthorizationNavigationViewModel)
        XCTAssertTrue(router is AuthorizationRouter)
        XCTAssertTrue(coordinator is AuthorizationCoordinator)
    }

}
