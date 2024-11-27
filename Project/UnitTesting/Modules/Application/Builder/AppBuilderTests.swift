import XCTest
import Combine
@testable import my_isp

final class AppBuilderTests: XCTestCase {
   
    private var injector: InjectorProtocol!
    private var builder: AppBuilder!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        injector = Injector()
        builder = AppBuilder(injector: injector)
    }
    
    override func tearDownWithError() throws {
        injector = nil
        builder = nil
        try super.tearDownWithError()
    }
    
    func testContainerResolving() {
        let application = injector.resolve(from: .application, type: ApplicationProtocol.self)
        let screen = injector.resolve(from: .application, type: ScreenProtocol.self)
        let device = injector.resolve(from: .application, type: DeviceProtocol.self)
        let bundle = injector.resolve(from: .application, type: BundleProtocol.self)
        let pasteboard = injector.resolve(from: .application, type: PasteboardProtocol.self)
        let notificationCenter = injector.resolve(from: .application, type: NotificationCenterProtocol.self)
        let userStorage = injector.resolve(from: .application, type: UserStorageProtocol.self)
        let connectionManager = injector.resolve(from: .application, type: ConnectionManagerProtocol.self)
        let keyboardManager = injector.resolve(from: .application, type: KeyboardManagerProtocol.self)
        let metricManager = injector.resolve(from: .application, type: MetricManagerProtocol.self)
        let interfaceManagerOne = injector.resolve(from: .application, type: InterfaceManagerEventProtocol.self)
        let interfaceManagerTwo = injector.resolve(from: .application, type: InterfaceManagerUpdateProtocol.self)
        let keyWindow = injector.resolve(from: .application, type: AppWindow.self)
        
        XCTAssertNotNil(application)
        XCTAssertNotNil(screen)
        XCTAssertNotNil(device)
        XCTAssertNotNil(bundle)
        XCTAssertNotNil(pasteboard)
        XCTAssertNotNil(notificationCenter)
        XCTAssertNotNil(userStorage)
        XCTAssertNotNil(connectionManager)
        XCTAssertNotNil(keyboardManager)
        XCTAssertNotNil(metricManager)
        XCTAssertNotNil(interfaceManagerOne)
        XCTAssertNotNil(interfaceManagerTwo)
        XCTAssertNotNil(keyWindow)
    }
    
    func testContainerTypes() {
        let userStorage = injector.resolve(from: .application, type: UserStorageProtocol.self)
        let connectionManager = injector.resolve(from: .application, type: ConnectionManagerProtocol.self)
        let keyboardManager = injector.resolve(from: .application, type: KeyboardManagerProtocol.self)
        let metricManager = injector.resolve(from: .application, type: MetricManagerProtocol.self)
        let interfaceManagerOne = injector.resolve(from: .application, type: InterfaceManagerEventProtocol.self)
        let interfaceManagerTwo = injector.resolve(from: .application, type: InterfaceManagerUpdateProtocol.self)
    
        XCTAssertTrue(userStorage is UserStorage)
        XCTAssertTrue(connectionManager is ConnectionManager)
        XCTAssertTrue(keyboardManager is KeyboardManager)
        XCTAssertTrue(metricManager is MetricManager)
        XCTAssertTrue(interfaceManagerOne is InterfaceManager)
        XCTAssertTrue(interfaceManagerTwo is InterfaceManager)
    }
    
    func testBuildingProcess() {
        let application = injector.resolve(from: .application, type: ApplicationProtocol.self)
        let applicationDelegate = builder.applicationDelegate(application)
        let userNotificationCenter = builder.userNotificationCenter(applicationDelegate)
        let notificationManager = builder.notificationManager(application, userNotificationCenter)
        let userStorage = injector.resolve(from: .application, type: UserStorageProtocol.self)
        let userManager = builder.userManager(userStorage)
        let effectWindow = builder.effectWindow()
        let presenter = builder.presenter(effectWindow)
        let interactor = builder.interactor(presenter, userManager, notificationManager)
        let coordinator = builder.coordinator(interactor)
        let splashBuilder = builder.splashBuilder
        let authorizationBuilder = builder.authorizationBuilder
        let menuBuilder = builder.menuBuilder
        
        XCTAssertNotNil(applicationDelegate)
        XCTAssertNotNil(userNotificationCenter)
        XCTAssertNotNil(notificationManager)
        XCTAssertNotNil(userManager)
        XCTAssertNotNil(effectWindow)
        XCTAssertNotNil(presenter)
        XCTAssertNotNil(interactor)
        XCTAssertNotNil(coordinator)
        XCTAssertNotNil(splashBuilder)
        XCTAssertNotNil(authorizationBuilder)
        XCTAssertNotNil(menuBuilder)
    }
    
    func testBuildingTypes() {
        let application = injector.resolve(from: .application, type: ApplicationProtocol.self)
        let applicationDelegate = builder.applicationDelegate(application)
        let userNotificationCenter = builder.userNotificationCenter(applicationDelegate)
        let notificationManager = builder.notificationManager(application, userNotificationCenter)
        let userStorage = injector.resolve(from: .application, type: UserStorageProtocol.self)
        let userManager = builder.userManager(userStorage)
        let effectWindow = builder.effectWindow()
        let presenter = builder.presenter(effectWindow)
        let interactor = builder.interactor(presenter, userManager, notificationManager)
        let coordinator = builder.coordinator(interactor)
        let splashBuilder = builder.splashBuilder
        let authorizationBuilder = builder.authorizationBuilder
        let menuBuilder = builder.menuBuilder
        
        XCTAssertTrue(applicationDelegate is AppDelegate)
        XCTAssertTrue(notificationManager is AppNotificationManager)
        XCTAssertTrue(userManager is AppUserManager)
        XCTAssertTrue(presenter is AppPresenter)
        XCTAssertTrue(interactor is AppInteractor)
        XCTAssertTrue(coordinator is AppCoordinator)
        XCTAssertTrue(splashBuilder is SplashBuilder)
        XCTAssertTrue(authorizationBuilder is AuthorizationBuilder)
        XCTAssertTrue(menuBuilder is MenuBuilder)
    }

}
