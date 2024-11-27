import UIKit
import Photos
import Firebase

final class AppBuilder: Builder, AppBuilderProtocol {

    override init(injector: InjectorProtocol) {
        super.init(injector: injector)
        register()
    }
    
}

// MARK: Private
private extension AppBuilder {
    
    func register() {
        application()
        screen()
        device()
        bundle()
        pasteboard()
        fileManager()
        dataStorage()
        photoLibrary()
        notificationCenter()
        connectionManager()
        localizationManager()
        interfaceManager()
        keyboardManager()
        metricManager()
        permissionManager()
        keyWindow()
        displaySpinner()
    }
    
    func application() {
        injector.register(in: .application, type: ApplicationProtocol.self) { _ in
            UIApplication.shared
        }
    }
    
    func screen() {
        injector.register(in: .application, type: ScreenProtocol.self) { _ in
            UIScreen.main
        }
    }
    
    func device() {
        injector.register(in: .application, type: DeviceProtocol.self) { _ in
            UIDevice.current
        }
    }
    
    func bundle() {
        injector.register(in: .application, type: BundleProtocol.self) { _ in
            Bundle.main
        }
    }
    
    func pasteboard() {
        injector.register(in: .application, type: PasteboardProtocol.self) { _ in
            UIPasteboard.general
        }
    }
    
    func fileManager() {
        injector.register(in: .application, type: FileManagerProtocol.self) { _ in
            FileManager.default
        }
    }
    
    func dataStorage() {
        injector.register(in: .application, type: DataStorage.self) { _ in
            DataStorage.entry
        }
    }
    
    func photoLibrary() {
        injector.register(in: .application, type: PHPhotoLibraryProtocol.self) { _ in
            PHPhotoLibrary.shared()
        }
    }
    
    func notificationCenter() {
        injector.register(in: .application, type: NotificationCenterProtocol.self) { _ in
            NotificationCenter.default
        }
    }
    
    func connectionManager() {
        injector.register(in: .application, type: ConnectionManagerProtocol.self) { _ in
            ConnectionManager.entry
        }
    }
    
    func localizationManager() {
        injector.register(in: .application, type: LocalizationManager.self) { _ in
            LocalizationManager.entry
        }
    }
    
    func interfaceManager() {
        injector.register(in: .application, type: InterfaceManager.self) { _ in
            InterfaceManager.entry
        }
    }
    
    func keyboardManager() {
        injector.register(in: .application, type: KeyboardManagerProtocol.self) { _ in
            KeyboardManager.entry
        }
    }
    
    func metricManager() {
        injector.register(in: .application, type: MetricManagerProtocol.self) { _ in
            MetricManager.entry
        }
    }
    
    func permissionManager() {
        let permissionManager = PermissionManager()
        
        injector.register(in: .application, type: PermissionManagerProtocol.self) { _ in
            permissionManager
        }
    }

    func keyWindow() {
        guard let interfaceManager = injector.resolve(from: .application, type: InterfaceManager.self) else {
            return error(of: InterfaceManager.self)
        }
        
        guard let screen = injector.resolve(from: .application, type: ScreenProtocol.self) else {
            return error(of: ScreenProtocol.self)
        }
        
        let window = keyWindow(interfaceManager, screen)
        
        injector.register(in: .application, type: AppWindow.self) { _ in
            window
        }
    }
    
    func displaySpinner() {
        guard let screen = injector.resolve(from: .application, type: ScreenProtocol.self) else {
            return error(of: ScreenProtocol.self)
        }
        
        guard let keyWindow = injector.resolve(from: .application, type: AppWindow.self) else {
            return error(of: AppWindow.self)
        }
        
        let dataSource = displayDataSource()
        let viewModel = displayViewModel(dataSource)
        let activityIndicator = displayActivityIndicator()
        let view = displayView(activityIndicator)
        let viewController = displayViewController(viewModel, view)
        let presenter = displayPresenter(dataSource)
        let window = displayWindow(presenter, viewController, screen)
        let displaySpinner = displaySpinner(keyWindow, window)
        
        presenter.internalEventPublisher.send(.inject(window: window))
        
        injector.register(in: .application, type: DisplaySpinnerProtocol.self) { _ in
            displaySpinner
        }
    }
    
}

// MARK: Public
extension AppBuilder {
    
    func coordinator(_ interactor: AppInteractorProtocol) -> AppCoordinatorProtocol {
         AppCoordinator(interactor: interactor, builder: self)
    }
    
    func interactor(_ presenter: AppPresenterProtocol, _ userManager: AppUserManagerControlProtocol, _ routeManager: AppRouteManagerProtocol, _ connectionManager: ConnectionManagerProtocol, _ notificationManager: AppNotificationsManagerControlProtocol) -> AppInteractorProtocol {
        AppInteractor(presenter: presenter, userManager: userManager, routeManager: routeManager, connectionManager: connectionManager, notificationManager: notificationManager)
    }
    
    func keyWindow(_ interfaceManager: InterfaceManagerControlProtocol, _ screen: ScreenProtocol) -> AppWindow {
        let window = AppWindow(interfaceManager: interfaceManager, screen: screen)
        window.makeKeyAndVisible()
        return window
    }
    
    func presenter(_ keyWindow: UIWindow, _ effectView: UIVisualEffectView, _ interfaceManager: InterfaceManagerInfoProtocol) -> AppPresenterProtocol {
        AppPresenter(keyWindow: keyWindow, effectView: effectView, interfaceManager: interfaceManager)
    }
    
    func effectView() -> UIVisualEffectView {
        UIVisualEffectView()
    }
    
    func routeManager() -> AppRouteManagerProtocol {
        AppRouteManager()
    }
    
    func userManager(_ storage: DataStorageControlProtocol) -> AppUserManager? {
        let userManager = AppUserManager(storage: storage)
        
        injector.register(in: .application, type: AppUserManager.self) { _ in
            userManager
        }
        
        return injector.resolve(from: .application, type: AppUserManager.self)
    }
    
    func notificationsManager(_ keyWindow: UIWindow, _ firebase: Messaging, _ application: ApplicationProtocol, _ notificationCenter: NotificationCenterProtocol,_ userNotificationCenter: UserNotificationCenterProtocol) -> AppNotificationsManager? {
        let notificationManager = AppNotificationsManager(keyWindow: keyWindow, firebase: firebase, application: application, notificationCenter: notificationCenter, userNotificationCenter: userNotificationCenter)
        
        injector.register(in: .application, type: AppNotificationsManager.self) { _ in
            notificationManager
        }
        
        return injector.resolve(from: .application, type: AppNotificationsManager.self)
    }

    func userNotificationCenter(_ delegate: UIApplicationDelegate) -> UserNotificationCenterProtocol? {
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.delegate = delegate as? UNUserNotificationCenterDelegate
        
        injector.register(in: .application, type: UserNotificationCenterProtocol.self) { _ in
            userNotificationCenter
        }

        return injector.resolve(from: .application, type: UserNotificationCenterProtocol.self)
    }
    
    func applicationDelegate(_ application: ApplicationProtocol) -> UIApplicationDelegate? {
        guard let applicationDelegate = application.delegate as? AppDelegate else { return nil }
        
        injector.register(in: .application, type: UIApplicationDelegate.self) { _ in
            applicationDelegate
        }
        
        return injector.resolve(from: .application, type: UIApplicationDelegate.self)
    }
    
    func firebaseMessaging(_ delegate: UIApplicationDelegate) -> Messaging? {
        let messaging = Messaging.messaging()
        messaging.delegate = delegate as? MessagingDelegate
        return messaging
    }
    
    func displaySpinner(_ keyWindow: UIWindow, _ topWindow: DisplayWindowProtocol) -> DisplaySpinnerProtocol {
        DisplaySpinner(keyWindow: keyWindow, topWindow: topWindow)
    }
    
    func displayWindow(_ presenter: DisplayPresenterProtocol, _ viewController: DisplayViewControllerProtocol, _ screen: ScreenProtocol) -> DisplayWindowProtocol {
        DisplayWindow(presenter: presenter, viewController: viewController, screen: screen)
    }
    
    func displayPresenter(_ dataSource: DisplayDataSourceWindowProtocol) -> DisplayPresenterProtocol {
        DisplayPresenter(dataSource: dataSource)
    }
    
    func displayViewController(_ viewModel: DisplayViewModelProtocol, _ view: AppOverlayViewProtocol) -> DisplayViewControllerProtocol {
        DisplayViewController(viewModel: viewModel, view: view)
    }
    
    func displayView(_ activityIndicator: UIActivityIndicatorView) -> AppOverlayViewProtocol {
        AppOverlayView(activityIndicator: activityIndicator)
    }
    
    func displayActivityIndicator() -> UIActivityIndicatorView {
        UIActivityIndicatorView()
    }
    
    func displayViewModel(_ dataSource: DisplayDataSourceViewProtocol) -> DisplayViewModelProtocol {
        DisplayViewModel(dataSource: dataSource)
    }
    
    func displayDataSource() -> DisplayDataSource {
        DisplayDataSource()
    }
    
}

// MARK: Protocol
extension AppBuilder {
    
    var module: AppBuilderModule? {
        guard let keyWindow = injector.resolve(from: .application, type: AppWindow.self) else {
            return error(of: AppWindow.self)
        }

        guard let application = injector.resolve(from: .application, type: ApplicationProtocol.self) else {
            return error(of: ApplicationProtocol.self)
        }
        
        guard let applicationDelegate = applicationDelegate(application) else {
            return error(of: UIApplicationDelegate.self)
        }
        
        guard let firebase = firebaseMessaging(applicationDelegate) else {
            return error(of: Messaging.self)
        }
        
        guard let notificationCenter = injector.resolve(from: .application, type: NotificationCenterProtocol.self) else {
            return error(of: NotificationCenterProtocol.self)
        }
        
        guard let userNotificationCenter = userNotificationCenter(applicationDelegate) else {
            return error(of: UserNotificationCenterProtocol.self)
        }
        
        guard let interfaceManager = injector.resolve(from: .application, type: InterfaceManager.self) else {
            return error(of: InterfaceManager.self)
        }
        
        guard let storage = injector.resolve(from: .application, type: DataStorage.self) else {
            return error(of: DataStorage.self)
        }
        
        guard let userManager = userManager(storage) else {
            return error(of: AppUserManager.self)
        }
        
        guard let connectionManager = injector.resolve(from: .application, type: ConnectionManagerProtocol.self) else {
            return error(of: ConnectionManagerProtocol.self)
        }
        
        guard let notificationsManager = notificationsManager(keyWindow, firebase, application, notificationCenter, userNotificationCenter) else {
            return error(of: AppNotificationsManager.self)
        }
        
        let effectView = effectView()
        let presenter = presenter(keyWindow, effectView, interfaceManager)
        let routeManager = routeManager()
        let interactor = interactor(presenter, userManager, routeManager, connectionManager, notificationsManager)
        let coordinator = coordinator(interactor)
        
        injector.register(in: .application, type: AppCoordinatorProtocol.self) { _ in
            coordinator
        }
        
        return AppBuilderModule(interactor: interactor, coordinator: coordinator)
    }
    
    var splashCoordinator: SplashCoordinatorProtocol? {
        let builder = SplashBuilder(injector: injector)
        return builder.coordinator
    }
    
    var authorizationCoordinator: AuthorizationCoordinatorProtocol? {
        let builder = AuthorizationBuilder(injector: injector)
        return builder.coordinator
    }
    
    var navigationCoordinator: MenuCoordinatorProtocol? {
        let builder = MenuBuilder(injector: injector)
        return builder.coordinator
    }

}

// MARK: - AppBuilderModule
struct AppBuilderModule {
    let interactor: AppInteractorProtocol
    let coordinator: AppCoordinatorProtocol
}
