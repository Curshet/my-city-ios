import XCTest
@testable import my_isp

final class CatalogBuilderTests: XCTestCase {
    
    private var injector: InjectorProtocol!
    private var builder: CatalogBuilder!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        injector = Injector()
        builder = CatalogBuilder(injector: injector)
    }
    
    override func tearDownWithError() throws {
        injector = nil
        builder = nil
        try super.tearDownWithError()
    }
    
    func testContainerResolving() {
        let navigationController = injector.resolve(from: .navigation, type: CatalogNavigationController.self)
        XCTAssertNotNil(navigationController)
    }
    
    func testBuildingProcess() {
        let rootViewModel = builder.rootViewModel()
        let rootViewController = builder.rootViewController(rootViewModel)
        let navigationViewModel = builder.navigationViewModel()
        let navigationController = builder.navigationController(navigationViewModel, rootViewController)
        let router = builder.router(navigationController)
        let coordinator = builder.coordinator(router)
        
        XCTAssertNotNil(rootViewModel)
        XCTAssertNotNil(rootViewController)
        XCTAssertNotNil(navigationViewModel)
        XCTAssertNotNil(navigationController)
        XCTAssertNotNil(router)
        XCTAssertNotNil(coordinator)
    }
    
    func testBuildingTypes() {
        let rootViewModel = builder.rootViewModel()
        let rootViewController = builder.rootViewController(rootViewModel)
        let navigationViewModel = builder.navigationViewModel()
        let navigationController = builder.navigationController(navigationViewModel, rootViewController)
        let router = builder.router(navigationController)
        let coordinator = builder.coordinator(router)
        
        XCTAssertNotNil(rootViewModel is CatalogRootViewModel)
        XCTAssertNotNil(navigationViewModel is CatalogNavigationViewModel)
        XCTAssertNotNil(router is CatalogRouter)
        XCTAssertNotNil(coordinator is CatalogCoordinator)
    }
    
}
