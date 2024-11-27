import UIKit
import WebKit

class ChatBuilder: Builder {
    
    override init(injector: InjectorProtocol) {
        super.init(injector: injector)
        register()
    }
    
}

// MARK: Private
private extension ChatBuilder {
    
    func register() {
        router()
        navigationController()
    }
    
    func router() {
        guard let notificationsManager = injector.resolve(from: .application, type: AppNotificationsManager.self) else {
            return error(of: AppNotificationsManager.self)
        }
        
        guard let displaySpinner = injector.resolve(from: .application, type: DisplaySpinnerProtocol.self) else {
            return error(of: DisplaySpinnerProtocol.self)
        }
        
        guard let application = injector.resolve(from: .application, type: ApplicationProtocol.self) else {
            return error(of: ApplicationProtocol.self)
        }
        
        let router = router(notificationsManager, displaySpinner, application)
        
        injector.register(in: .navigation, type: ChatRouterProtocol.self) { _ in
            router
        }
    }
    
    func navigationController() {
        guard let bundle = injector.resolve(from: .application, type: BundleProtocol.self) else {
            return error(of: BundleProtocol.self)
        }
        
        guard let device = injector.resolve(from: .application, type: DeviceProtocol.self) else {
            return error(of: DeviceProtocol.self)
        }
        
        guard let localizationManager = injector.resolve(from: .application, type: LocalizationManager.self) else {
            return error(of: LocalizationManager.self)
        }
        
        guard let interfaceManager = injector.resolve(from: .application, type: InterfaceManager.self) else {
            return error(of: InterfaceManager.self)
        }
        
        guard let router = injector.resolve(from: .navigation, type: ChatRouterProtocol.self) else {
            return error(of: ChatRouterProtocol.self)
        }

        let rootDataSource = rootDataSource(bundle, device)
        let rootDataManager = rootDataManager(rootDataSource, localizationManager)
        let rootPresenter = presenter()
        let appearanceManager = rootAppearanceManager(rootPresenter, interfaceManager)
        let rootViewModel = rootViewModel(router, rootDataManager, appearanceManager)
        let rootWebViewRefreshControl = rootWebViewRefreshControl()
        let rootWebViewConfiguration = rootWebViewConfiguration()
        let rootWebView = rootWebView(rootWebViewRefreshControl, rootWebViewConfiguration)
        let rootView = rootView(rootWebView)
        let rootViewController = rootViewController(rootViewModel, rootView)
        let delegate = navigationControllerDelegate()
        let presenter = presenter()
        let dataSource = navigationDataSource()
        let viewModel = navigationViewModel(presenter, dataSource)
        let navigationController = navigationController(viewModel, delegate, rootViewController)
        
        router.internalEventPublisher.send(.inject(navigationController: navigationController))
        rootPresenter.internalEvеntPublisher.send(.inject(viewController: rootViewController))
        presenter.internalEvеntPublisher.send(.inject(viewController: navigationController))
        
        injector.register(in: .navigation, type: ChatNavigationController.self) { _ in
            navigationController
        }
    }
    
}

// MARK: Public
extension ChatBuilder {
    
    func presenter() -> AppearancePresenterProtocol {
        AppearancePresenter()
    }
    
    func router(_ notificationsManager: AppNotificationsManagerPresentProtocol, _ displaySpinner: DisplaySpinnerProtocol, _ application: ApplicationProtocol) -> ChatRouterProtocol {
        ChatRouter(builder: self, notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
    }
    
    func navigationController(_ viewModel: ChatNavigationViewModelProtocol, _ delegate: AppNavigationControllerDelegateProtocol, _ rootViewController: UIViewController) -> ChatNavigationController {
        ChatNavigationController(viewModel: viewModel, delegate: delegate, rootViewController: rootViewController)
    }
    
    func navigationControllerDelegate() -> AppNavigationControllerDelegateProtocol {
        AppNavigationControllerDelegate()
    }
    
    func navigationViewModel(_ presenter: AppearancePresenterProtocol, _ dataSource: ChatNavigationDataSourceProtocol) -> ChatNavigationViewModelProtocol {
        ChatNavigationViewModel(presenter: presenter, dataSource: dataSource)
    }
    
    func navigationDataSource() -> ChatNavigationDataSourceProtocol {
        ChatNavigationDataSource()
    }
    
    func rootViewController(_ viewModel: ChatRootViewModelProtocol, _ view: ChatRootViewProtocol) -> ChatRootViewController {
        ChatRootViewController(viewModel: viewModel, view: view)
    }
    
    func rootViewModel(_ router: ChatRouterProtocol, _ dataManager: ChatRootDataManagerProtocol, _ appearanceManager: AppearanceManagerProtocol) -> ChatRootViewModelProtocol {
        ChatRootViewModel(router: router, dataManager: dataManager, appearanceManager: appearanceManager)
    }
    
    func rootDataManager(_ dataSource: ChatRootDataSourceProtocol, _ localizationManager: LocalizationManagerInfoProtocol) -> ChatRootDataManagerProtocol {
        ChatRootDataManager(dataSource: dataSource, localizationManager: localizationManager)
    }
    
    func rootDataSource(_ bundle: BundleProtocol, _ device: DeviceProtocol) -> ChatRootDataSourceProtocol {
        ChatRootDataSource(bundle: bundle, device: device)
    }
    
    func rootAppearanceManager(_ presenter: AppearancePresenterProtocol, _ interfaceManager: InterfaceManagerInfoProtocol) -> AppearanceManagerProtocol {
        AppearanceManager(presenter: presenter, interfaceManager: interfaceManager)
    }
    
    func rootView(_ webview: ChatRootWebViewProtocol) -> ChatRootViewProtocol {
        ChatRootView(webview: webview)
    }
    
    func rootWebView(_ refreshControl: AppRefreshControlProtocol, _ configuration: WKWebViewConfiguration) -> ChatRootWebViewProtocol {
        ChatRootWebView(refreshControl: refreshControl, configuration: configuration)
    }
    
    func rootWebViewConfiguration() -> WKWebViewConfiguration {
        WKWebViewConfiguration()
    }
    
    func rootWebViewRefreshControl() -> AppRefreshControlProtocol {
        let actionTarget = ActionTarget()
        return AppRefreshControl(actionTarget: actionTarget)
    }
    
}

// MARK: ChatBuilderProtocol
extension ChatBuilder: ChatBuilderProtocol {
    
    var coordinator: ChatCoordinatorProtocol? {
        guard let router = injector.resolve(from: .navigation, type: ChatRouterProtocol.self) else {
            return error(of: ChatRouterProtocol.self)
        }
        
        return ChatCoordinator(router: router)
    }
    
}

// MARK: ChatBuilderRoutingProtocol
extension ChatBuilder: ChatBuilderRoutingProtocol {}
