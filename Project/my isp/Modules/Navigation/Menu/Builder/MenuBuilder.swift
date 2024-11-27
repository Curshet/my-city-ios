import UIKit

class MenuBuilder: Builder {

    override init(injector: InjectorProtocol) {
        super.init(injector: injector)
        injector.remove(container: .authorization)
        register()
    }
    
}

// MARK: Private
private extension MenuBuilder {
    
    func register() {
        catalogBuilder()
        profileBuilder()
        chatBuilder()
        moreBuilder()
        intercomBuilder()
        router()
        tabBarController()
    }
    
    func catalogBuilder() {
        let builder = CatalogBuilder(injector: injector)
        
        injector.register(in: .navigation, type: CatalogBuilder.self) { _ in
            builder
        }
    }
    
    func profileBuilder() {
        let builder = ProfileBuilder(injector: injector)
        
        injector.register(in: .navigation, type: ProfileBuilder.self) { _ in
            builder
        }
    }
    
    func chatBuilder() {
        let builder = ChatBuilder(injector: injector)
        
        injector.register(in: .navigation, type: ChatBuilder.self) { _ in
            builder
        }
    }
    
    func moreBuilder() {
        let builder = MoreBuilder(injector: injector)
        
        injector.register(in: .navigation, type: MoreBuilder.self) { _ in
            builder
        }
    }
    
    func intercomBuilder() {
        let builder = IntercomBuilder(injector: injector)
        
        injector.register(in: .navigation, type: IntercomBuilder.self) { _ in
            builder
        }
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
        
        injector.register(in: .navigation, type: MenuRouterProtocol.self) { _ in
            router
        }
    }
    
    func tabBarController() {
        guard let screen = injector.resolve(from: .application, type: ScreenProtocol.self) else {
            return error(of: ScreenProtocol.self)
        }
        
        guard let device = injector.resolve(from: .application, type: DeviceProtocol.self) else {
            return error(of: DeviceProtocol.self)
        }
        
        guard let userManager = injector.resolve(from: .application, type: AppUserManager.self) else {
            return error(of: AppUserManager.self)
        }
        
        guard let interfaceManager = injector.resolve(from: .application, type: InterfaceManager.self) else {
            return error(of: InterfaceManager.self)
        }
        
        guard let router = injector.resolve(from: .navigation, type: MenuRouterProtocol.self) else {
            return error(of: MenuRouterProtocol.self)
        }
        
        guard let catalogViewController = injector.resolve(from: .navigation, type: CatalogNavigationController.self) else {
            return error(of: CatalogNavigationController.self)
        }
        
        guard let profileViewController = injector.resolve(from: .navigation, type: ProfileNavigationController.self) else {
            return error(of: ProfileNavigationController.self)
        }
        
        guard let chatViewController = injector.resolve(from: .navigation, type: ChatNavigationController.self) else {
            return error(of: ChatNavigationController.self)
        }
        
        guard let moreViewController = injector.resolve(from: .navigation, type: MoreNavigationController.self) else {
            return error(of: MoreNavigationController.self)
        }

        let dataSource = dataSource(screen, device)
        let dataManager = dataManager(userManager, dataSource)
        let presenter = presenter()
        let appearanceManager = appearanceManager(presenter, interfaceManager)
        let viewModel = viewModel(router, dataManager, appearanceManager)
        let delegate = tabBarControllerDelegate()
        let viewControllers = [catalogViewController, profileViewController, chatViewController, moreViewController]
        let tabBarController = tabBarController(viewModel, delegate, viewControllers)
        
        router.internalEventPublisher.send(.inject(tabBarController: tabBarController))
        presenter.internalEventPublisher.send(.inject(tabBar: tabBarController.tabBar))
    
        injector.register(in: .navigation, type: MenuTabBarController.self) { _ in
            tabBarController
        }
    }
    
}

// MARK: Public
extension MenuBuilder {
    
    func router(_ notificationsManager: AppNotificationsManagerPresentProtocol, _ displaySpinner: DisplaySpinnerProtocol, _ application: ApplicationProtocol) -> MenuRouterProtocol {
        MenuRouter(builder: self, notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
    }
    
    func tabBarController(_ viewModel: MenuViewModelProtocol, _ delegate: AppTabBarControllerDelegateProtocol, _ viewControllers: [UIViewController]) -> MenuTabBarController {
        let tabBarController = MenuTabBarController(viewModel: viewModel, delegate: delegate)
        tabBarController.setViewControllers(viewControllers, animated: false)
        return tabBarController
    }
    
    func tabBarControllerDelegate() -> AppTabBarControllerDelegateProtocol {
        AppTabBarControllerDelegate()
    }
    
    func viewModel(_ router: MenuRouterProtocol, _ dataManager: MenuDataManagerProtocol, _ appearanceManager: MenuAppearanceManagerProtocol) -> MenuViewModelProtocol {
        MenuViewModel(router: router, dataManager: dataManager, appearanceManager: appearanceManager)
    }
    
    func dataManager(_ userManager: AppUserManagerControlProtocol, _ dataSource: MenuDataSourceProtocol) -> MenuDataManagerProtocol {
        MenuDataManager(userManager: userManager, dataSource: dataSource)
    }
    
    func dataSource(_ screen: ScreenProtocol, _ device: DeviceProtocol) -> MenuDataSourceProtocol {
        MenuDataSource(screen: screen, device: device)
    }
    
    func appearanceManager(_ presenter: MenuAppearancePresenterProtocol, _ interfaceManager: InterfaceManagerInfoProtocol) -> MenuAppearanceManagerProtocol {
        MenuAppearanceManager(presenter: presenter, interfaceManager: interfaceManager)
    }
    
    func presenter() -> MenuAppearancePresenterProtocol {
        MenuAppearancePresenter()
    }
    
}

// MARK: MenuBuilderProtocol
extension MenuBuilder: MenuBuilderProtocol {
    
    var coordinator: MenuCoordinatorProtocol? {
        guard let router = injector.resolve(from: .navigation, type: MenuRouterProtocol.self) else {
            return error(of: MenuRouterProtocol.self)
        }
        
        return MenuCoordinator(router: router, builder: self)
    }
    
    var catalogCoordinator: CatalogCoordinatorProtocol? {
        guard let builder = injector.resolve(from: .navigation, type: CatalogBuilder.self) else {
            return error(of: CatalogBuilder.self)
        }

        return builder.coordinator
    }
    
    var profileCoordinator: ProfileCoordinatorProtocol? {
        guard let builder = injector.resolve(from: .navigation, type: ProfileBuilder.self) else {
            return error(of: ProfileBuilder.self)
        }
        
        return builder.coordinator
    }
    
    var chatCoordinator: ChatCoordinatorProtocol? {
        guard let builder = injector.resolve(from: .navigation, type: ChatBuilder.self) else {
            return error(of: ChatBuilder.self)
        }
        
        return builder.coordinator
    }
    
    var moreCoordinator: MoreCoordinatorProtocol? {
        guard let builder = injector.resolve(from: .navigation, type: MoreBuilder.self) else {
            return error(of: MoreBuilder.self)
        }
        
        return builder.coordinator
    }
    
    var intercomCoordinator: IntercomCoordinatorProtocol? {
        guard let builder = injector.resolve(from: .navigation, type: IntercomBuilder.self) else {
            return error(of: IntercomBuilder.self)
        }
        
        return builder.coordinator
    }
    
}

// MARK: MenuBuilderRoutingProtocol
extension MenuBuilder: MenuBuilderRoutingProtocol {
    
    var window: UIWindow? {
        injector.resolve(from: .application, type: AppWindow.self)
    }
    
}
