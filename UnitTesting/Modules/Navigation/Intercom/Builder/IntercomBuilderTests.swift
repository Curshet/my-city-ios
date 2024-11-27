import XCTest
@testable import my_isp

final class IntercomBuilderTests: XCTestCase {
    
    private var injector: InjectorProtocol!
    private var builder: IntercomBuilder!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        injector = Injector()
        builder = IntercomBuilder(injector: injector)
    }
    
    override func tearDownWithError() throws {
        injector = nil
        builder = nil
        try super.tearDownWithError()
    }
    
    func testBuildingProcess() {
        let view = builder.view()
        let viewModel = builder.viewModel()
        let router = builder.router()
        let viewController = builder.controller
        let coordinator = builder.coordinator
        
        XCTAssertNotNil(view)
        XCTAssertNotNil(viewModel)
        XCTAssertNotNil(router)
        XCTAssertNotNil(viewController)
        XCTAssertNotNil(coordinator)
    }
    
    func testBuildingTypes() {
        let view = builder.view()
        let viewModel = builder.viewModel()
        let router = builder.router()
        let coordinator = builder.coordinator
        
        XCTAssertTrue(view is IntercomView)
        XCTAssertTrue(viewModel is IntercomViewModel)
        XCTAssertTrue(router is IntercomRouter)
        XCTAssertTrue(coordinator is IntercomCoordinator)
    }
    
}

