import XCTest
import Combine
@testable import my_isp

final class MoreBuilderTests: XCTestCase {
    
    private var injector: InjectorProtocol!
    private var builder: MoreBuilder!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        injector = Injector()
        builder = MoreBuilder(injector: injector)
    }
    
    override func tearDownWithError() throws {
        injector = nil
        builder = nil
        try super.tearDownWithError()
    }
    
    func testContainerResolving() {
        let router = injector.resolve(from: .navigation, type: MoreRouterProtocol.self)
        XCTAssertNotNil(router)
    }
    
    func testContainerTypes() {
        let router = injector.resolve(from: .navigation, type: MoreRouterProtocol.self)
        XCTAssertTrue(router is MoreRouter)
    }
    
    func testRootBuildingProcess() {
        let label = builder.label()
        let imageView = builder.imageView()
        let rootCollectionCellView = builder.rootCollectionCellView(label, label, imageView)
        let rootCollectionViewDataSource = builder.rootCollectionViewDataSource()
        let rootCollectionViewDelegate = builder.rootCollectionViewDelegate()
        let collectionViewLayout = builder.collectionViewLayout()
        let rootCollectionView = builder.rootCollectionView(rootCollectionViewDataSource, rootCollectionViewDelegate, collectionViewLayout)
        let indexPath = IndexPath(row: 0, section: 0)
        let layout = MoreRootNavigationCellLayout()
        let data = MoreRootCellData(layout: layout, title: "", subtitle: nil, icon: .arrow(nil))
        let rootCell = builder.rootCell(rootCollectionView, indexPath, data, nil)
        let router = builder.router(builder)
        let bundle = Bundle()
        let device = UIDevice()
        let rootDataSource = builder.rootDataSource(bundle, device)
        let interfaceManager = InterfaceManagerMock()
        let rootPresenter = builder.rootPresenter(interfaceManager)
        let pasteboard = UIPasteboard()
        let rootViewModel = builder.rootViewModel(router: router, rootDataSource, rootPresenter, pasteboard)
        let rootViewController = builder.rootViewController(rootViewModel, rootCollectionView)
        let navigationViewModel = builder.navigationViewModel()
        let navigationController = builder.navigationController(navigationViewModel, rootViewController)
        let coordinator = builder.coordinator
        
        XCTAssertNotNil(label)
        XCTAssertNotNil(imageView)
        XCTAssertNotNil(rootCollectionCellView)
        XCTAssertNotNil(rootCollectionViewDataSource)
        XCTAssertNotNil(rootCollectionViewDelegate)
        XCTAssertNotNil(collectionViewLayout)
        XCTAssertNotNil(rootCollectionView)
        XCTAssertNotNil(rootCell)
        XCTAssertNotNil(router)
        XCTAssertNotNil(rootDataSource)
        XCTAssertNotNil(rootPresenter)
        XCTAssertNotNil(pasteboard)
        XCTAssertNotNil(rootViewModel)
        XCTAssertNotNil(rootViewController)
        XCTAssertNotNil(navigationViewModel)
        XCTAssertNotNil(navigationController)
        XCTAssertNotNil(coordinator)
    }
    
    func testRootBuildingTypes() {
        let rootCollectionViewDataSource = builder.rootCollectionViewDataSource()
        let rootCollectionViewDelegate = builder.rootCollectionViewDelegate()
        let collectionViewLayout = builder.collectionViewLayout()
        let rootCollectionView = builder.rootCollectionView(rootCollectionViewDataSource, rootCollectionViewDelegate, collectionViewLayout)
        let router = builder.router(builder)
        let bundle = Bundle()
        let device = UIDevice()
        let rootDataSource = builder.rootDataSource(bundle, device)
        let interfaceManager = InterfaceManagerMock()
        let rootPresenter = builder.rootPresenter(interfaceManager)
        let pasteboard = UIPasteboard()
        let rootViewModel = builder.rootViewModel(router: router, rootDataSource, rootPresenter, pasteboard)
        let navigationViewModel = builder.navigationViewModel()
        let coordinator = builder.coordinator
        
        XCTAssertTrue(rootCollectionViewDataSource is MoreRootCollectionViewDataSource)
        XCTAssertTrue(rootCollectionViewDelegate is MoreRootCollectionViewDelegate)
        XCTAssertTrue(rootCollectionView is MoreRootCollectionView)
        XCTAssertTrue(router is MoreRouter)
        XCTAssertTrue(rootDataSource is MoreRootDataSource)
        XCTAssertTrue(rootPresenter is MoreRootPresenter)
        XCTAssertTrue(rootViewModel is MoreRootViewModel)
        XCTAssertTrue(navigationViewModel is MoreNavigationViewModel)
        XCTAssertTrue(coordinator is MoreCoordinator)
    }
    
    func testSupportBuildingProcess() {
        let label = builder.label()
        let imageView = builder.imageView()
        let supportMessengersCollectionCellStackView = builder.supportMessengersCollectionCellStackView()
        let supportMessengersCollectionCellView = builder.supportMessengersCollectionCellView(label, imageView, imageView, imageView, supportMessengersCollectionCellStackView)
        let supportPhoneCollectionCellView = builder.supportPhoneCollectionCellView(label, imageView, label)
        let supportCollectionViewDataSource = builder.supportCollectionViewDataSource()
        let supportCollectionViewDelegate = builder.supportCollectionViewDelegate()
        let collectionViewLayout = builder.collectionViewLayout()
        let supportCollectionView = builder.supportCollectionView(supportCollectionViewDataSource, supportCollectionViewDelegate, collectionViewLayout)
        let indexPath = IndexPath(row: 0, section: 0)
        let layout = MoreRootNavigationCellLayout()
        let data = MoreRootCellData(layout: layout, title: "", subtitle: nil, icon: .arrow(nil))
        let supportPhoneCell = builder.supportPhoneCell(supportCollectionView, indexPath, data, nil)
        let supportMessengersCell = builder.supportMessengersCell(supportCollectionView, indexPath, data, nil)
        let interfaceManager = InterfaceManagerMock()
        let supportPresenter = builder.supportPresenter(interfaceManager)
        let device = UIDevice()
        let supportDataSource = builder.supportDataSource(device)
        let supportViewModel = builder.supportViewModel()
        let router = builder.router(builder)
        let supportViewController = builder.supportViewController(supportViewModel, supportCollectionView)

        XCTAssertNotNil(label)
        XCTAssertNotNil(imageView)
        XCTAssertNotNil(supportMessengersCollectionCellStackView)
        XCTAssertNotNil(supportMessengersCollectionCellView)
        XCTAssertNotNil(supportPhoneCollectionCellView)
        XCTAssertNotNil(supportCollectionViewDataSource)
        XCTAssertNotNil(supportCollectionViewDelegate)
        XCTAssertNotNil(collectionViewLayout)
        XCTAssertNotNil(supportCollectionView)
        XCTAssertNotNil(supportPhoneCell)
        XCTAssertNotNil(supportMessengersCell)
        XCTAssertNotNil(supportPresenter)
        XCTAssertNotNil(supportDataSource)
        XCTAssertNotNil(supportViewModel)
        XCTAssertNotNil(router)
        XCTAssertNotNil(supportViewController)
    }
    
    func testSupportBuildingTypes() {
        let supportCollectionViewDataSource = builder.supportCollectionViewDataSource()
        let supportCollectionViewDelegate = builder.supportCollectionViewDelegate()
        let collectionViewLayout = builder.collectionViewLayout()
        let supportCollectionView = builder.supportCollectionView(supportCollectionViewDataSource, supportCollectionViewDelegate, collectionViewLayout)
        let interfaceManager = InterfaceManagerMock()
        let supportPresenter = builder.supportPresenter(interfaceManager)
        let device = UIDevice()
        let supportDataSource = builder.supportDataSource(device)
        let supportViewModel = builder.supportViewModel()

        XCTAssertTrue(supportCollectionViewDataSource is MoreSupportCollectionViewDataSource)
        XCTAssertTrue(supportCollectionViewDelegate is MoreSupportCollectionViewDelegate)
        XCTAssertTrue(supportCollectionView is MoreSupportCollectionView)
        XCTAssertTrue(supportPresenter is MoreSupportPresenter)
        XCTAssertTrue(supportDataSource is MoreSupportDataSource)
        XCTAssertTrue(supportViewModel is MoreSupportViewModel)
    }
    
    func testShareApplicationBuildingProcess() {
        let shareApplicationViewModel = builder.shareApplicationViewModel()
        let shareApplicationViewController = builder.shareApplicationViewController
        
        XCTAssertNotNil(shareApplicationViewModel)
        XCTAssertNotNil(shareApplicationViewController)
    }
    
    func testShareApplicationBuildingTypes() {
        let shareApplicationViewModel = builder.shareApplicationViewModel()
        XCTAssertTrue(shareApplicationViewModel is MoreShareApplicationViewModel)
    }

}
