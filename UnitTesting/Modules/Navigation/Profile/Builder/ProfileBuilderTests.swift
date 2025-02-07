import XCTest
@testable import my_isp

final class ProfileBuilderTests: XCTestCase {
    
    private var injector: InjectorProtocol!
    private var builder: ProfileBuilder!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        injector = Injector()
        builder = ProfileBuilder(injector: injector)
    }
    
    override func tearDownWithError() throws {
        injector = nil
        builder = nil
        try super.tearDownWithError()
    }
    
    func testBuildingProcess() {
        let label = builder.label()
        let switсh = builder.switсh()
        let imageView = builder.imageView()
        let collectionCellUserInfoView = builder.collectionCellUserInfoView(label, label, label, label, imageView)
        let collectionCellSettingsMenu = builder.collectionCellSettingsMenu(label, label, switсh)
        let collectionCellSettingsView = builder.collectionCellSettingsView(collectionCellSettingsMenu, collectionCellSettingsMenu)
        let collectionCellLogoutView = builder.collectionCellLogoutView(label, label)
        let navigationBarAppearance = builder.navigationBarAppearance()
        let customNavigationBarAppearance = builder.customNavigationBarAppearance(navigationBarAppearance)
        let interfaceManager = InterfaceManagerMock()
        let presenter = builder.presenter(interfaceManager)
        let userStorage = UserStorageMock()
        let device = UIDevice()
        let dataSource = builder.dataSource(userStorage, device)
        let networkManager = builder.networkManager()
        let router = builder.router(builder)
        let coordinator = builder.coordinator(router)
        let userManager = AppUserManagerMock()
        let viewModel = builder.viewModel(router, userManager, presenter, dataSource, networkManager)
        let collectionViewDataSource = builder.collectionViewDataSource(builder)
        let collectionViewDelegate = builder.collectionViewDelegate()
        let collectionViewLayout = builder.collectionViewLayout()
        let collectionView = builder.collectionView(collectionViewDataSource, collectionViewDelegate, collectionViewLayout)
        let viewController = builder.viewController(viewModel, collectionView)
        let navigationViewModel = builder.navigationViewModel()
        let navigationController = builder.navigationController(navigationViewModel, viewController)
        let indexPath = IndexPath()
        let data = "Test"
        let settingsCell = builder.settingsCell(collectionView, indexPath, data, nil)
        let logoutCell = builder.logoutCell(collectionView, indexPath, data, nil)
        
        XCTAssertNotNil(label)
        XCTAssertNotNil(switсh)
        XCTAssertNotNil(imageView)
        XCTAssertNotNil(collectionCellUserInfoView)
        XCTAssertNotNil(collectionCellSettingsMenu)
        XCTAssertNotNil(collectionCellSettingsView)
        XCTAssertNotNil(collectionCellLogoutView)
        XCTAssertNotNil(navigationBarAppearance)
        XCTAssertNotNil(customNavigationBarAppearance)
        XCTAssertNotNil(presenter)
        XCTAssertNotNil(dataSource)
        XCTAssertNotNil(networkManager)
        XCTAssertNotNil(router)
        XCTAssertNotNil(coordinator)
        XCTAssertNotNil(viewModel)
        XCTAssertNotNil(collectionViewDataSource)
        XCTAssertNotNil(collectionViewDelegate)
        XCTAssertNotNil(collectionViewLayout)
        XCTAssertNotNil(collectionView)
        XCTAssertNotNil(viewController)
        XCTAssertNotNil(navigationViewModel)
        XCTAssertNotNil(navigationController)
        XCTAssertNotNil(settingsCell)
        XCTAssertNotNil(logoutCell)
    }
    
    func testBuildingTypes() {
        let interfaceManager = InterfaceManagerMock()
        let presenter = builder.presenter(interfaceManager)
        let userStorage = UserStorageMock()
        let device = UIDevice()
        let dataSource = builder.dataSource(userStorage, device)
        let networkManager = builder.networkManager()
        let router = builder.router(builder)
        let coordinator = builder.coordinator(router)
        let userManager = AppUserManagerMock()
        let viewModel = builder.viewModel(router, userManager, presenter, dataSource, networkManager)
        let collectionViewDataSource = builder.collectionViewDataSource(builder)
        let collectionViewDelegate = builder.collectionViewDelegate()
        let collectionViewLayout = UICollectionViewFlowLayout()
        let collectionView = builder.collectionView(collectionViewDataSource, collectionViewDelegate, collectionViewLayout)
        let navigationViewModel = builder.navigationViewModel()
        
        XCTAssertNotNil(presenter is ProfileRootPresenter)
        XCTAssertNotNil(dataSource is ProfileRootDataSource)
        XCTAssertNotNil(networkManager is ProfileRootNetworkManager)
        XCTAssertNotNil(router is ProfileRouter)
        XCTAssertNotNil(coordinator is ProfileCoordinator)
        XCTAssertNotNil(viewModel is ProfileRootViewModel)
        XCTAssertNotNil(collectionViewDataSource is ProfileRootCenterViewDataSource)
        XCTAssertNotNil(collectionViewDelegate is ProfileCollectionViewDelegate)
        XCTAssertNotNil(collectionView is ProfileRootCenterView)
        XCTAssertNotNil(navigationViewModel is ProfileNavigationViewModel)
    }
    
}
