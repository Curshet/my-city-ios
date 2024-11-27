import UIKit

class CatalogBuilder: Builder {

    override init(injector: InjectorProtocol) {
        super.init(injector: injector)
        register()
    }
    
}

// MARK: Private
private extension CatalogBuilder {
    
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
        
        injector.register(in: .navigation, type: CatalogRouterProtocol.self) { _ in
            router
        }
    }
    
    func navigationController() {
        guard let device = injector.resolve(from: .application, type: DeviceProtocol.self) else {
            return error(of: DeviceProtocol.self)
        }
        
        guard let userManager = injector.resolve(from: .application, type: AppUserManager.self) else {
            return error(of: AppUserManager.self)
        }
        
        guard let notificationsManager = injector.resolve(from: .application, type: AppNotificationsManager.self) else {
            return error(of: AppNotificationsManager.self)
        }
        
        guard let permissionManager = injector.resolve(from: .application, type: PermissionManagerProtocol.self) else {
            return error(of: PermissionManagerProtocol.self)
        }
        
        guard let interfaceManager = injector.resolve(from: .application, type: InterfaceManager.self) else {
            return error(of: InterfaceManager.self)
        }
        
        guard let router = injector.resolve(from: .navigation, type: CatalogRouterProtocol.self) else {
            return error(of: CatalogRouterProtocol.self)
        }
        
        let rootDataSource = rootDataSource(device)
        let rootDataManager = rootDataManager(userManager, rootDataSource, notificationsManager, permissionManager)
        let rootDecoder = decoder()
        let rootNetworkManager = rootNetworkManager(rootDecoder)
        let rootPresenter = presenter()
        let rootAppearanceManager = appearanceManager(rootPresenter, interfaceManager)
        let rootViewModel = rootViewModel(router, rootDataManager, rootNetworkManager, rootAppearanceManager)
        let rootCollectionViewDataSource = rootCollectionViewDataSource()
        let rootCollectionViewFlowLayout = rootCollectionViewFlowLayout()
        let rootCollectionView = rootCollectionView(rootCollectionViewDataSource, rootCollectionViewFlowLayout)
        let rootViewController = rootViewController(rootViewModel, rootCollectionView)
        let presenter = navigationPresenter()
        let dataSource = navigationDataSource()
        let viewModel = navigationViewModel(presenter, dataSource)
        let delegate = navigationControllerDelegate()
        let navigationController = navigationController(viewModel, delegate, rootViewController)
        
        rootPresenter.internalEvеntPublisher.send(.inject(viewController: rootViewController))
        presenter.internalEvеntPublisher.send(.inject(viewController: navigationController))
        router.internalEventPublisher.send(.inject(navigationController: navigationController))
        
        injector.register(in: .navigation, type: CatalogNavigationController.self) { _ in
            navigationController
        }
    }
    
}

// MARK: Public
extension CatalogBuilder {
    
    func appearanceManager(_ presenter: AppearancePresenterProtocol, _ interfaceManager: InterfaceManagerInfoProtocol) -> AppearanceManagerProtocol {
        AppearanceManager(presenter: presenter, interfaceManager: interfaceManager)
    }
    
    func presenter() -> AppearancePresenterProtocol {
        AppearancePresenter()
    }
    
    func decoder() -> JSONDecoderProtocol {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    func router(_ notificationsManager: AppNotificationsManagerPresentProtocol, _ displaySpinner: DisplaySpinnerProtocol, _ application: ApplicationProtocol) -> CatalogRouterProtocol {
        CatalogRouter(builder: self, notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
    }
    
    func navigationController(_ viewModel: CatalogNavigationViewModelProtocol, _ delegate: AppNavigationControllerDelegateProtocol, _ rootViewController: UIViewController) -> CatalogNavigationController {
        CatalogNavigationController(viewModel: viewModel, delegate: delegate, rootViewController: rootViewController)
    }
    
    func navigationControllerDelegate() -> AppNavigationControllerDelegateProtocol {
        AppNavigationControllerDelegate()
    }
    
    func navigationViewModel(_ presenter: AppearancePresenterProtocol, _ dataSource: CatalogNavigationDataSourceProtocol) -> CatalogNavigationViewModelProtocol {
        CatalogNavigationViewModel(presenter: presenter, dataSource: dataSource)
    }
    
    func navigationPresenter() -> AppearancePresenterProtocol {
        AppearancePresenter()
    }
    
    func navigationDataSource() -> CatalogNavigationDataSourceProtocol {
        CatalogNavigationDataSource()
    }
    
    func rootViewController(_ viewModel: CatalogRootViewModelProtocol, _ view: CatalogRootCollectionViewProtocol) -> CatalogRootViewController {
        CatalogRootViewController(viewModel: viewModel, view: view)
    }
    
    func rootViewModel(_ router: CatalogRouterProtocol, _ dataManager: CatalogRootDataManagerProtocol, _ networkManager: CatalogRootNetworkManagerProtocol, _ appearanceManager: AppearanceManagerProtocol) -> CatalogRootViewModelProtocol {
        CatalogRootViewModel(router: router, dataManager: dataManager, networkManager: networkManager, appearanceManager: appearanceManager)
    }
    
    func rootDataManager(_ userManager: AppUserManagerInfoProtocol, _ dataSource: CatalogRootDataSourceProtocol, _ notificationsManager: AppNotificationsManagerAuthorizationProtocol, _ permissionManager: PermissionManagerProtocol) -> CatalogRootDataManagerProtocol {
        CatalogRootDataManager(userManager: userManager, dataSource: dataSource, notificationsManager: notificationsManager, permissionManager: permissionManager)
    }
    
    func rootDataSource(_ device: DeviceProtocol) -> CatalogRootDataSourceProtocol {
        CatalogRootDataSource(device: device)
    }
    
    func rootNetworkManager(_ decoder: JSONDecoderProtocol) -> CatalogRootNetworkManagerProtocol {
        CatalogRootNetworkManager(decoder: decoder)
    }
    
    func rootCollectionView(_ dataSource: CatalogRootCollectionViewDataSourceProtocol, _ layout: UICollectionViewFlowLayout) -> CatalogRootCollectionViewProtocol {
        CatalogRootCollectionView(dataSource: dataSource, layout: layout)
    }
    
    func rootCollectionViewDataSource() -> CatalogRootCollectionViewDataSourceProtocol {
        CatalogRootCollectionViewDataSource()
    }
    
    func rootCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
        UICollectionViewFlowLayout()
    }
    
}

// MARK: CatalogBuilderProtocol
extension CatalogBuilder: CatalogBuilderProtocol {
    
    var coordinator: CatalogCoordinatorProtocol? {
        guard let router = injector.resolve(from: .navigation, type: CatalogRouterProtocol.self) else {
            return error(of: CatalogRouterProtocol.self)
        }
        
        return CatalogCoordinator(router: router)
    }
    
}

// MARK: CatalogBuilderRoutingProtocol
extension CatalogBuilder: CatalogBuilderRoutingProtocol {}
