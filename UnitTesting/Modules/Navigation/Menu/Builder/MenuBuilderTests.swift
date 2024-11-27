import XCTest
@testable import my_isp

final class MenuBuilderTests: XCTestCase {

    private var injector: InjectorProtocol!
    private var builder: MenuBuilder!

    override func setUpWithError() throws {
        try super.setUpWithError()
        injector = Injector()
        builder = MenuBuilder(injector: injector)
    }

    override func tearDownWithError() throws {
        injector = nil
        builder = nil
        try super.tearDownWithError()
    }
    
    func testContainerResolving() {
        let tabBarController = injector.resolve(from: .navigation, type: MenuTabBarController.self)
        let catalogBuilder = injector.resolve(from: .navigation, type: CatalogBuilderProtocol.self)
        let profileBuilder = injector.resolve(from: .navigation, type: ProfileBuilderProtocol.self)
        let chatBuilder = injector.resolve(from: .navigation, type: ChatBuilderProtocol.self)
        let moreBuilder = injector.resolve(from: .navigation, type: MoreBuilderProtocol.self)
        
        XCTAssertNotNil(tabBarController)
        XCTAssertNotNil(catalogBuilder)
        XCTAssertNotNil(profileBuilder)
        XCTAssertNotNil(chatBuilder)
        XCTAssertNotNil(moreBuilder)
    }
    
    func testContainerTypes() {
        let catalogBuilder = injector.resolve(from: .navigation, type: CatalogBuilderProtocol.self)
        let profileBuilder = injector.resolve(from: .navigation, type: ProfileBuilderProtocol.self)
        let chatBuilder = injector.resolve(from: .navigation, type: ChatBuilderProtocol.self)
        let moreBuilder = injector.resolve(from: .navigation, type: MoreBuilderProtocol.self)
        
        XCTAssertTrue(catalogBuilder is CatalogBuilder)
        XCTAssertTrue(profileBuilder is ProfileBuilder)
        XCTAssertTrue(chatBuilder is ChatBuilder)
        XCTAssertTrue(moreBuilder is MoreBuilder)
    }

    func testBuildingProcess() {
        let viewModel = builder.viewModel()
        let tabBarController = builder.tabBarController(viewModel)
        let router = builder.router(tabBarController)
        let coordinator = builder.coordinator(router)

        XCTAssertNotNil(viewModel)
        XCTAssertNotNil(tabBarController)
        XCTAssertNotNil(router)
        XCTAssertNotNil(coordinator)
    }

    func testBuildingTypes() {
        let viewModel = builder.viewModel()
        let tabBarController = builder.tabBarController(viewModel)
        let router = builder.router(tabBarController)
        let coordinator = builder.coordinator(router)

        XCTAssertTrue(viewModel is MenuViewModel)
        XCTAssertTrue(router is MenuRouter)
        XCTAssertTrue(coordinator is MenuCoordinator)
    }

}
