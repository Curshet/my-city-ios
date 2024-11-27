import XCTest
@testable import my_isp

final class ChatBuilderTests: XCTestCase {
    
    private var injector: InjectorProtocol!
    private var builder: ChatBuilder!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        injector = Injector()
        builder = ChatBuilder(injector: injector)
    }
    
    override func tearDownWithError() throws {
        injector = nil
        builder = nil
        try super.tearDownWithError()
    }
    
    func testContainerResolving() {
        let router = injector.resolve(from: .navigation, type: ChatRouterProtocol.self)
        XCTAssertNotNil(router)
    }
    
    func testContainerTypes() {
        let router = injector.resolve(from: .navigation, type: ChatRouterProtocol.self)
        XCTAssertTrue(router is ChatRouter)
    }
    
    func testBuildingProcess() {
        let navigationBarAppearance = builder.navigationBarAppearance()
        let customNavigationBarAppearance =  builder.customNavigationBarAppearance(navigationBarAppearance)
        let refreshControl = builder.refreshControl()
        let configuration = builder.webViewConfiguration()
        let view = builder.webView(refreshControl, configuration)
        let router = builder.router(builder)
        let bundle = Bundle()
        let device = UIDevice()
        let dataSource = builder.dataSource(bundle, device)
        let interfaceManager = InterfaceManagerMock()
        let presenter = builder.presenter(interfaceManager)
        let viewModel = builder.viewModel(router, dataSource, presenter)
        let viewController = builder.viewController(viewModel, view)
        let navigationViewModel = builder.navigationViewModel()
        let navigationController = builder.navigationController(navigationViewModel, viewController)
        let coordinator = builder.coordinator(router)
        
        XCTAssertNotNil(navigationBarAppearance)
        XCTAssertNotNil(customNavigationBarAppearance)
        XCTAssertNotNil(refreshControl)
        XCTAssertNotNil(configuration)
        XCTAssertNotNil(view)
        XCTAssertNotNil(router)
        XCTAssertNotNil(dataSource)
        XCTAssertNotNil(presenter)
        XCTAssertNotNil(viewModel)
        XCTAssertNotNil(viewController)
        XCTAssertNotNil(navigationViewModel)
        XCTAssertNotNil(navigationController)
        XCTAssertNotNil(coordinator)
    }
    
    func testBuildingTypes() {
        let refreshControl = builder.refreshControl()
        let configuration = builder.webViewConfiguration()
        let view = builder.webView(refreshControl, configuration)
        let router = builder.router(builder)
        let bundle = Bundle()
        let device = UIDevice()
        let dataSource = builder.dataSource(bundle, device)
        let interfaceManager = InterfaceManagerMock()
        let presenter = builder.presenter(interfaceManager)
        let viewModel = builder.viewModel(router, dataSource, presenter)
        let navigationViewModel = builder.navigationViewModel()
        let coordinator = builder.coordinator(router)

        XCTAssertTrue(view is ChatWebView)
        XCTAssertTrue(router is ChatRouter)
        XCTAssertTrue(dataSource is ChatDataSource)
        XCTAssertTrue(presenter is ChatPresenter)
        XCTAssertTrue(viewModel is ChatViewModel)
        XCTAssertTrue(navigationViewModel is ChatNavigationViewModel)
        XCTAssertTrue(coordinator is ChatCoordinator)
    }
    
}
