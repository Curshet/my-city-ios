import Foundation

class IntercomBuilder: Builder {
    
    override init(injector: InjectorProtocol) {
        super.init(injector: injector)
        register()
    }
    
}

// MARK: Private
private extension IntercomBuilder {
    
    func register() {
        router()
        viewModel()
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
        
        injector.register(in: .navigation, type: IntercomRouterProtocol.self) { _ in
            router
        }
    }
    
    func viewModel() {
        guard let userManager = injector.resolve(from: .application, type: AppUserManager.self) else {
            return error(of: AppUserManager.self)
        }
        
        guard let router = injector.resolve(from: .navigation, type: IntercomRouterProtocol.self) else {
            return error(of: IntercomRouterProtocol.self)
        }
        
        let pushRegistryDelegate = pushRegistryDelegate()
        let pushRegistry = pushRegistry(pushRegistryDelegate)
        let dataManager = dataManager(userManager, pushRegistry)
        let viewModel = viewModel(router, dataManager)
        
        injector.register(in: .navigation, type: IntercomViewModelProtocol.self) { _ in
            viewModel
        }
    }
    
}

// MARK: Public
extension IntercomBuilder {
    
    func router(_ notificationsManager: AppNotificationsManagerPresentProtocol, _ displaySpinner: DisplaySpinnerProtocol, _ application: ApplicationProtocol) -> IntercomRouterProtocol {
        IntercomRouter(builder: self, notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
    }
    
    func viewModel(_ router: IntercomRouterProtocol, _ dataManager: IntercomDataManagerProtocol) -> IntercomViewModelProtocol {
        IntercomViewModel(router: router, dataManager: dataManager)
    }
    
    func dataManager(_ userManager: AppUserManagerControlProtocol, _ pushRegistry: IntercomVoipPushRegistryProtocol) -> IntercomDataManagerProtocol {
        IntercomDataManager(userManager: userManager, pushRegistry: pushRegistry)
    }
    
    func pushRegistry(_ delegate: IntercomPushRegistryDelegateProtocol) -> IntercomVoipPushRegistryProtocol {
        IntercomVoipPushRegistry(delegate: delegate)
    }
    
    func pushRegistryDelegate() -> IntercomPushRegistryDelegateProtocol {
        IntercomPushRegistryDelegate()
    }
    
    func view() -> IntercomViewProtocol {
        IntercomView()
    }
    
}

// MARK: IntercomBuilderProtocol
extension IntercomBuilder: IntercomBuilderProtocol {
    
    var coordinator: IntercomCoordinatorProtocol? {
        guard let router = injector.resolve(from: .navigation, type: IntercomRouterProtocol.self) else {
            return error(of: IntercomRouterProtocol.self)
        }
        
        return IntercomCoordinator(router: router)
    }
    
}

// MARK: IntercomBuilderRoutingProtocol
extension IntercomBuilder: IntercomBuilderRoutingProtocol {
    
    var viewController: IntercomViewController? {
        guard let viewModel = injector.resolve(from: .navigation, type: IntercomViewModelProtocol.self) else {
            return error(of: IntercomViewModelProtocol.self)
        }
        
        let view = view()
        return IntercomViewController(viewModel: viewModel, view: view)
    }
    
}
