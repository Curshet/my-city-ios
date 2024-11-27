import UIKit

class SplashBuilder: Builder {
    
    override init(injector: InjectorProtocol) {
        super.init(injector: injector)
        injector.remove(container: .authorization)
        injector.remove(container: .navigation)
    }
    
}

// MARK: Public
extension SplashBuilder {
    
    func router(_ notificationsManager: AppNotificationsManagerPresentProtocol, _ displaySpinner: DisplaySpinnerProtocol, _ application: ApplicationProtocol) -> SplashRouterProtocol {
        SplashRouter(builder: self, notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
    }
    
    func viewController(_ viewModel: SplashViewModelProtocol, _ view: SplashViewProtocol) -> SplashViewController {
        SplashViewController(viewModel: viewModel, view: view)
    }
    
    func viewModel(_ router: SplashRouterProtocol, _ dataSource: SplashDataSourceProtocol, _ connectionManager: ConnectionManagerProtocol, _ interfaceManager: InterfaceManagerInfoProtocol, _ timer: AppTimerProtocol) -> SplashViewModelProtocol {
        SplashViewModel(router: router, dataSource: dataSource, connectionManager: connectionManager, interfaceManager: interfaceManager, timer: timer)
    }
    
    func dataSource(_ device: DeviceProtocol, _ screen: ScreenProtocol) -> SplashDataSourceProtocol {
        SplashDataSource(device: device, screen: screen)
    }
    
    func timer() -> AppTimerProtocol {
        AppTimer(notificationsManager: nil)
    }
    
    func view(_ imageView: UIImageView) -> SplashViewProtocol {
        SplashView(imageView: imageView)
    }
    
    func imageView() -> UIImageView {
        UIImageView()
    }
    
}

// MARK: SplashBuilderProtocol
extension SplashBuilder: SplashBuilderProtocol {

    var coordinator: SplashCoordinatorProtocol? {
        guard let notificationsManager = injector.resolve(from: .application, type: AppNotificationsManager.self) else {
            return error(of: AppNotificationsManager.self)
        }
        
        guard let displaySpinner = injector.resolve(from: .application, type: DisplaySpinnerProtocol.self) else {
            return error(of: DisplaySpinnerProtocol.self)
        }
        
        guard let application = injector.resolve(from: .application, type: ApplicationProtocol.self) else {
            return error(of: ApplicationProtocol.self)
        }
        
        guard let device = injector.resolve(from: .application, type: DeviceProtocol.self) else {
            return error(of: DeviceProtocol.self)
        }
        
        guard let screen = injector.resolve(from: .application, type: ScreenProtocol.self) else {
            return error(of: ScreenProtocol.self)
        }
        
        guard let connectionManager = injector.resolve(from: .application, type: ConnectionManagerProtocol.self) else {
            return error(of: ConnectionManagerProtocol.self)
        }
        
        guard let interfaceManager = injector.resolve(from: .application, type: InterfaceManager.self) else {
            return error(of: InterfaceManager.self)
        }
        
        let router = router(notificationsManager, displaySpinner, application)
        let dataSource = dataSource(device, screen)
        let timer = timer()
        let viewModel = viewModel(router, dataSource, connectionManager, interfaceManager, timer)
        let imageView = imageView()
        let view = view(imageView)
        let viewController = viewController(viewModel, view)
        
        router.internalEventPublisher.send(.inject(viewController: viewController))
        return SplashCoordinator(router: router)
    }
    
}

// MARK: SplashBuilderRoutingProtocol
extension SplashBuilder: SplashBuilderRoutingProtocol {
    
    func window() -> UIWindow? {
        injector.resolve(from: .application, type: AppWindow.self)
    }
    
    func alertController(_ content: AlertContent) -> UIAlertController? {
        UIAlertController.create(content)
    }
    
}
