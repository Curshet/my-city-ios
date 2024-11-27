import XCTest
import Combine
import Network
@testable import my_isp

final class SplashBuilderTests: XCTestCase {

    private var screen: ScreenProtocol!
    private var device: DeviceProtocol!
    private var notificationCenter: NotificationCenterProtocol!
    private var connectionManagerInfo: ConnectionManagerInfoMock!
    private var connectionManager: ConnectionManagerProtocol!
    private var injector: InjectorProtocol!
    private var builder: SplashBuilder!

    override func setUpWithError() throws {
        try super.setUpWithError()
        screen = UIScreen()
        device = UIDevice.current
        notificationCenter = NotificationCenter()
        connectionManagerInfo = ConnectionManagerInfoMock()
        connectionManager = ConnectionManagerMock(connectionManagerInfo)
        injector = Injector()
        builder = SplashBuilder(injector: injector)
    }

    override func tearDownWithError() throws {
        screen = nil
        device = nil
        notificationCenter = nil
        connectionManagerInfo = nil
        connectionManager = nil
        injector = nil
        builder = nil
        try super.tearDownWithError()
    }

    func testBuildingProcess() {
        let router = builder.router()
        let coordinator = builder.coordinator(router)
        let dataSource = builder.dataSource(device, notificationCenter)
        let connectionTimer = builder.connectionTimer()
        let logoView = builder.logoView()
        let view = builder.view(logoView)
        let presenter = builder.presenter(logoView, screen)
        let viewModel = builder.viewModel(router, dataSource, connectionManager, connectionTimer, presenter)
        let viewController = builder.viewController(viewModel, view)
        let alertContent = SplashAlertData(title: "", message: "", leftTitle: "", rightTitle: "", leftAction: nil, rightAction: nil)
        let alertController = builder.alertController(alertContent)

        XCTAssertNotNil(router)
        XCTAssertNotNil(coordinator)
        XCTAssertNotNil(dataSource)
        XCTAssertNotNil(connectionTimer)
        XCTAssertNotNil(logoView)
        XCTAssertNotNil(view)
        XCTAssertNotNil(presenter)
        XCTAssertNotNil(viewModel)
        XCTAssertNotNil(viewController)
        XCTAssertNotNil(alertController)
    }

    func testBuildingTypes() {
        let router = builder.router()
        let dataSource = builder.dataSource(device, notificationCenter)
        let connectionTimer = builder.connectionTimer()
        let logoView = builder.logoView()
        let view = builder.view(logoView)
        let presenter = builder.presenter(logoView, screen)
        let viewModel = builder.viewModel(router, dataSource, connectionManager, connectionTimer, presenter)
        let coordinator = builder.coordinator(router)

        XCTAssertTrue(router is SplashRouter)
        XCTAssertTrue(dataSource is SplashDataSource)
        XCTAssertTrue(connectionTimer is AppTimer)
        XCTAssertTrue(view is SplashView)
        XCTAssertTrue(presenter is SplashPresenter)
        XCTAssertTrue(viewModel is SplashViewModel)
        XCTAssertTrue(coordinator is SplashCoordinator)
    }

}

// MARK: - ConnectionManagerMock
final class ConnectionManagerMock: ConnectionManagerProtocol {

    let information: ConnectionManagerInfoProtocol

    init(_ information: ConnectionManagerInfoProtocol) {
        self.information = information
    }

}

// MARK: - ConnectionManagerInfoMock
final class ConnectionManagerInfoMock: ConnectionManagerInfoProtocol {
    
    var isConnected: Bool?
    
    var status: (isConnected: Bool?, connectionType: NWInterface.InterfaceType?) {
        (isConnected: isConnected, connectionType: nil)
    }
    
    var publisher: AnyPublisher<(isConnected: Bool, connectionType: NWInterface.InterfaceType?), Never> {
        internalPublisher.eraseToAnyPublisher()
    }
    
    let internalPublisher = PassthroughSubject<(isConnected: Bool, connectionType: NWInterface.InterfaceType?), Never>()
    
}
