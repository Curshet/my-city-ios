import UIKit

class AuthorizationBuilder: Builder {
    
    override init(injector: InjectorProtocol) {
        super.init(injector: injector)
        injector.remove(container: .navigation)
        register()
    }
    
}

// MARK: Private
private extension AuthorizationBuilder {
    
    func register() {
        router()
        viewController()
        timer()
        dataCache()
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
        
        injector.register(in: .authorization, type: AuthorizationRouterProtocol.self) { _ in
            router
        }
    }
    
    func viewController() {
        guard let screen = injector.resolve(from: .application, type: ScreenProtocol.self) else {
            return error(of: ScreenProtocol.self)
        }
        
        guard let userManager = injector.resolve(from: .application, type: AppUserManager.self) else {
            return error(of: AppUserManager.self)
        }
        
        guard let router = injector.resolve(from: .authorization, type: AuthorizationRouterProtocol.self) else {
            return error(of: AuthorizationRouterProtocol.self)
        }
        
        guard let interfaceManager = injector.resolve(from: .application, type: InterfaceManager.self) else {
            return error(of: InterfaceManager.self)
        }
        
        let imageView = imageView()
        let textLabel = label()
        let headerView = headerView(imageView, textLabel)
        let telegramButton = overlayButton()
        let separatingLabel = label()
        let phoneButton = button()
        let centerView = centerView(telegramButton, separatingLabel, phoneButton)
        let view = view(headerView, centerView)
        let dataSource = dataSource(screen)
        let dataManager = dataManager(userManager, dataSource)
        let decoder = decoder()
        let networkManager = networkManager(decoder)
        let viewModel = viewModel(router, dataManager, networkManager, interfaceManager)
        let viewController = viewController(viewModel, view)
        
        router.internalEventPublisher.send(.inject(viewController: viewController))
        
        injector.register(in: .authorization, type: AuthorizationViewController.self) { _ in
            viewController
        }
    }
    
    func timer() {
        guard let notificationsManager = injector.resolve(from: .application, type: AppNotificationsManager.self) else {
            return error(of: AppNotificationsManager.self)
        }
        
        let timer = AppTimer(notificationsManager: notificationsManager)
        
        injector.register(in: .authorization, type: AppTimerProtocol.self) { _ in
            timer
        }
    }
    
    func dataCache() {
        let dataCache = AuthorizationPhoneRootDataCache()
        
        injector.register(in: .authorization, type: AuthorizationPhoneRootDataCache.self) { _ in
            dataCache
        }
    }
    
}

// MARK: Public
extension AuthorizationBuilder {
    
    func label() -> UILabel {
        UILabel()
    }
    
    func imageView() -> UIImageView {
        UIImageView()
    }
    
    func button() -> AppButtonProtocol {
        let actionTarget = ActionTarget()
        return AppButton(actionTarget: actionTarget, overlay: nil)
    }
    
    func overlayButton() -> AppButtonProtocol {
        let actionTarget = ActionTarget()
        let activityIndicator = UIActivityIndicatorView()
        let overlay = AppOverlayView(activityIndicator: activityIndicator)
        return AppButton(actionTarget: actionTarget, overlay: overlay)
    }
    
    func decoder() -> JSONDecoderProtocol {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    func router(_ notificationsManager: AppNotificationsManagerPresentProtocol, _ displaySpinner: DisplaySpinnerProtocol, _ application: ApplicationProtocol) -> AuthorizationRouterProtocol {
        AuthorizationRouter(builder: self, notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
    }
    
    func viewController(_ viewModel: AuthorizationViewModelProtocol, _ view: AuthorizationViewProtocol) -> AuthorizationViewController {
        AuthorizationViewController(viewModel: viewModel, view: view)
    }
    
    func viewModel(_ router: AuthorizationRouterProtocol, _ dataManager: AuthorizationDataManagerProtocol, _ networkManager: AuthorizationNetworkManagerProtocol, _ interfaceManager: InterfaceManagerControlProtocol) -> AuthorizationViewModelProtocol {
        AuthorizationViewModel(router: router, dataManager: dataManager, networkManager: networkManager, interfaceManager: interfaceManager)
    }
    
    func dataManager(_ userManager: AppUserManagerControlProtocol, _ dataSource: AuthorizationDataSourceProtocol) -> AuthorizationDataManagerProtocol {
        AuthorizationDataManager(userManager: userManager, dataSource: dataSource)
    }
    
    func dataSource(_ screen: ScreenProtocol) -> AuthorizationDataSourceProtocol {
        AuthorizationDataSource(screen: screen)
    }
    
    func networkManager(_ decoder: JSONDecoderProtocol) -> AuthorizationNetworkManagerProtocol {
        AuthorizationNetworkManager(decoder: decoder)
    }
    
    func view(_ headerView: AuthorizationHeaderViewProtocol, _ centerView: AuthorizationCenterViewProtocol) -> AuthorizationViewProtocol {
        AuthorizationView(headerView: headerView, centerView: centerView)
    }
    
    func headerView(_ imageView: UIImageView, _ textLabel: UILabel) -> AuthorizationHeaderViewProtocol {
        AuthorizationHeaderView(imageView: imageView, textLabel: textLabel)
    }
    
    func centerView(_ telegramButton: AppButtonProtocol, _ separatingLabel: UILabel, _ phoneButton: AppButtonProtocol) -> AuthorizationCenterViewProtocol {
        AuthorizationCenterView(telegramButton: telegramButton, separatingLabel: separatingLabel, phoneButton: phoneButton)
    }
    
    func phoneNavigationController(_ delegate: AppNavigationControllerDelegateProtocol, _ rootViewController: UIViewController) -> AppNavigationControllerProtocol {
        let navigationController = AppNavigationController(delegate: delegate, transitioningDelegate: nil, rootViewController: rootViewController)
        navigationController.modalTransitionStyle = .coverVertical
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
    
    func phoneNavigationControllerDelegate() -> AppNavigationControllerDelegateProtocol {
        AppNavigationControllerDelegate()
    }
    
    func phoneRootViewController(_ viewModel: AuthorizationPhoneRootViewModelProtocol, _ view: AuthorizationPhoneRootViewProtocol) -> AuthorizationPhoneRootViewController {
        AuthorizationPhoneRootViewController(viewModel: viewModel, view: view)
    }
    
    func phoneRootViewModel(_ dependencies: AuthorizationPhoneRootViewModelDependencies) -> AuthorizationPhoneRootViewModelProtocol {
        AuthorizationPhoneRootViewModel(dependencies : dependencies)
    }
    
    func phoneRootDataSource() -> AuthorizationPhoneRootDataSourceProtocol {
        AuthorizationPhoneRootDataSource()
    }
    
    func phoneRootPresenter() -> AppearancePresenterProtocol {
        AppearancePresenter()
    }
    
    func phoneRootNetworkManager(_ decoder: JSONDecoderProtocol) -> AuthorizationPhoneRootNetworkManagerProtocol {
        AuthorizationPhoneRootNetworkManager(decoder: decoder)
    }
    
    func phoneRootView(_ headerView: AuthorizationPhoneRootHeaderViewProtocol, _ centerView: AuthorizationPhoneRootCenterViewProtocol) -> AuthorizationPhoneRootViewProtocol {
        AuthorizationPhoneRootView(headerView: headerView, centerView: centerView)
    }
    
    func phoneRootHeaderView(_ titleLabel: UILabel, _ subtitleLabel: UILabel) -> AuthorizationPhoneRootHeaderViewProtocol {
        AuthorizationPhoneRootHeaderView(titleLabel: titleLabel, subtitleLabel: subtitleLabel)
    }
    
    func phoneRootCenterView(_ textView: AuthorizationPhoneRootCenterTextViewProtocol, _ enterButton: AppButtonProtocol, _ returnButton: AppButtonProtocol) -> AuthorizationPhoneRootCenterViewProtocol {
        AuthorizationPhoneRootCenterView(textView: textView, enterButton: enterButton, returnButton: returnButton)
    }
    
    func phoneRootCenterTextView(_ countryLabel: UILabel, _ textField: AuthorizationPhoneRootCenterTextFieldProtocol, _ messageLabel: UILabel) -> AuthorizationPhoneRootCenterTextViewProtocol {
        AuthorizationPhoneRootCenterTextView(countryLabel: countryLabel, textField: textField, messageLabel: messageLabel)
    }
    
    func phoneRootCenterTextField(_ rightView: AuthorizationPhoneRootCenterTextRightViewProtocol, _ delegate: AuthorizationPhoneRootCenterTextFieldDelegateProtocol) -> AuthorizationPhoneRootCenterTextFieldProtocol {
        let actionTarget = ActionTarget()
        return AuthorizationPhoneRootCenterTextField(rightView: rightView, delegate: delegate, actionTarget: actionTarget)
    }
    
    func phoneRootCenterTextFieldRightView(_ button: AppButtonProtocol) -> AuthorizationPhoneRootCenterTextRightViewProtocol {
        AuthorizationPhoneRootCenterTextRightView(button: button)
    }
    
    func phoneRootCenterTextFieldDelegate() -> AuthorizationPhoneRootCenterTextFieldDelegateProtocol {
        AuthorizationPhoneRootCenterTextFieldDelegate()
    }
    
    func phoneCodeViewController(_ viewModel: AuthorizationPhoneCodeViewModelProtocol, _ view: AppPhoneCodeViewProtocol, _ background: UIVisualEffectView) -> AuthorizationPhoneCodeViewController {
        AuthorizationPhoneCodeViewController(viewModel: viewModel, view: view, background: background)
    }
    
    func phoneCodeViewModel(_ dependencies: AuthorizationPhoneCodeViewModelDependencies) -> AuthorizationPhoneCodeViewModelProtocol {
        AuthorizationPhoneCodeViewModel(dependencies: dependencies)
    }
    
    func phoneCodeDataSource() -> AuthorizationPhoneCodeDataSourceProtocol {
        AuthorizationPhoneCodeDataSource()
    }
    
    func phoneCodeNetworkManager(_ decoder: JSONDecoderProtocol) -> AuthorizationPhoneCodeNetworkManagerProtocol {
        AuthorizationPhoneCodeNetworkManager(decoder: decoder)
    }
    
    func phoneCodeBackground() -> UIVisualEffectView {
        UIVisualEffectView()
    }
    
    func phoneCodeView(_ alertView: AppPhoneCodeAlertViewProtocol) -> AppPhoneCodeViewProtocol {
        AppPhoneCodeView(alertView: alertView)
    }
    
    func phoneCodeAlertView(_ headerView: AppPhoneCodeHeaderViewProtocol, _ centerView: AppPhoneCodeCenterViewProtocol) -> AppPhoneCodeAlertViewProtocol {
        AppPhoneCodeAlertView(headerView: headerView, centerView: centerView)
    }
    
    func phoneCodeHeaderView(_ titleLabel: UILabel, _ subtitleLabel: UILabel, _ exitButton: AppButtonProtocol) -> AppPhoneCodeHeaderViewProtocol {
        AppPhoneCodeHeaderView(titleLabel: titleLabel, subtitleLabel: subtitleLabel, exitButton: exitButton)
    }
    
    func phoneCodeCenterView(_ stackView: AppPhoneCodeCenterStackViewProtocol, _ repeatButton: AppButtonProtocol) -> AppPhoneCodeCenterViewProtocol {
        AppPhoneCodeCenterView(stackView: stackView, repeatButton: repeatButton)
    }
    
    func phoneCodeCenterStackView(_ textField: AppPhoneCodeCenterTextFieldProtocol) -> AppPhoneCodeCenterStackViewProtocol {
        AppPhoneCodeCenterStackView(builder: self, textField: textField)
    }
    
    func phoneCodeCenterTextField(_ delegate: AppPhoneCodeCenterTextFieldDelegateProtocol) -> AppPhoneCodeCenterTextFieldProtocol {
        let actionTarget = ActionTarget()
        return AppPhoneCodeCenterTextField(delegate: delegate, actionTarget: actionTarget)
    }
    
    func phoneCodeCenterTextFieldDelegate() -> AppPhoneCodeCenterTextFieldDelegateProtocol {
        AppPhoneCodeCenterTextFieldDelegate()
    }
    
}

// MARK: AuthorizationBuilderProtocol
extension AuthorizationBuilder: AuthorizationBuilderProtocol {
    
    var coordinator: AuthorizationCoordinatorProtocol? {
        guard let router = injector.resolve(from: .authorization, type: AuthorizationRouterProtocol.self) else {
            return error(of: AuthorizationRouterProtocol.self)
        }
        
        return AuthorizationCoordinator(router: router)
    }
    
}

// MARK: AuthorizationBuilderRoutingProtocol
extension AuthorizationBuilder: AuthorizationBuilderRoutingProtocol {
    
    var window: UIWindow? {
        injector.resolve(from: .application, type: AppWindow.self)
    }
    
    var phoneNavigationController: AppNavigationControllerProtocol? {
        guard let router = injector.resolve(from: .authorization, type: AuthorizationRouterProtocol.self) else {
            return error(of: AuthorizationRouterProtocol.self)
        }
        
        guard let timer = injector.resolve(from: .authorization, type: AppTimerProtocol.self) else {
            return error(of: AppTimerProtocol.self)
        }
        
        guard let dataCache = injector.resolve(from: .authorization, type: AuthorizationPhoneRootDataCache.self) else {
            return error(of: AuthorizationPhoneRootDataCache.self)
        }
        
        guard let interfaceManager = injector.resolve(from: .application, type: InterfaceManager.self) else {
            return error(of: InterfaceManager.self)
        }
        
        let rootDataSource = phoneRootDataSource()
        let rootPresenter = phoneRootPresenter()
        let rootDecoder = decoder()
        let rootNetworkManager = phoneRootNetworkManager(rootDecoder)
        let rootDependencies = AuthorizationPhoneRootViewModelDependencies(router: router, timer: timer, dataCache: dataCache, dataSource: rootDataSource, presenter: rootPresenter, networkManager: rootNetworkManager, interfaceManager: interfaceManager)
        let rootViewModel = phoneRootViewModel(rootDependencies)
        let rootHeaderTitleLabel = label()
        let rootHeaderSubtitleLabel = label()
        let rootHeaderView = phoneRootHeaderView(rootHeaderTitleLabel, rootHeaderSubtitleLabel)
        let rootCenterCountryLabel = label()
        let rootCenterTextFieldRightButton = button()
        let rootCenterTextFieldRightView = phoneRootCenterTextFieldRightView(rootCenterTextFieldRightButton)
        let rootCenterTextFieldDelegate = phoneRootCenterTextFieldDelegate()
        let rootCenterTextField = phoneRootCenterTextField(rootCenterTextFieldRightView, rootCenterTextFieldDelegate)
        let rootCenterMessageLabel = label()
        let rootCenterTextView = phoneRootCenterTextView(rootCenterCountryLabel, rootCenterTextField, rootCenterMessageLabel)
        let rootCenterEnterButton = overlayButton()
        let rootCenterReturnButton = button()
        let rootCenterView = phoneRootCenterView(rootCenterTextView, rootCenterEnterButton, rootCenterReturnButton)
        let rootView = phoneRootView(rootHeaderView, rootCenterView)
        let rootViewController = phoneRootViewController(rootViewModel, rootView)
        let delegate = phoneNavigationControllerDelegate()
        let navigationController = phoneNavigationController(delegate, rootViewController)
        
        rootPresenter.internalEvеntPublisher.send(.inject(viewController: rootViewController))
        return navigationController
    }
    
    var phoneCodeViewController: AuthorizationPhoneCodeViewController? {
        guard let router = injector.resolve(from: .authorization, type: AuthorizationRouterProtocol.self) else {
            return error(of: AuthorizationRouterProtocol.self)
        }
        
        guard let timer = injector.resolve(from: .authorization, type: AppTimerProtocol.self) else {
            return error(of: AppTimerProtocol.self)
        }
        
        guard let userManager = injector.resolve(from: .application, type: AppUserManager.self) else {
            return error(of: AppUserManager.self)
        }
        
        guard let dataCache = injector.resolve(from: .authorization, type: AuthorizationPhoneRootDataCache.self) else {
            return error(of: AuthorizationPhoneRootDataCache.self)
        }
        
        guard let interfaceManager = injector.resolve(from: .application, type: InterfaceManager.self) else {
            return error(of: InterfaceManager.self)
        }
        
        let dataSource = phoneCodeDataSource()
        let decoder = decoder()
        let networkManager = phoneCodeNetworkManager(decoder)
        let dependencies = AuthorizationPhoneCodeViewModelDependencies(router: router, timer: timer, userManager: userManager, dataCache: dataCache, dataSource: dataSource, networkManager: networkManager, interfaceManager: interfaceManager)
        let viewModel = phoneCodeViewModel(dependencies)
        let headerTitleLabel = label()
        let headerSubitleLabel = label()
        let headerExitButton = button()
        let headerView = phoneCodeHeaderView(headerTitleLabel, headerSubitleLabel, headerExitButton)
        let centerTextFieldDelegate = phoneCodeCenterTextFieldDelegate()
        let centerTextField = phoneCodeCenterTextField(centerTextFieldDelegate)
        let centerStackView = phoneCodeCenterStackView(centerTextField)
        let centerRepeatButton = overlayButton()
        let centerView = phoneCodeCenterView(centerStackView, centerRepeatButton)
        let alertView = phoneCodeAlertView(headerView, centerView)
        let view = phoneCodeView(alertView)
        let background = phoneCodeBackground()
        let viewController = phoneCodeViewController(viewModel, view, background)
        return viewController
    }
    
}

// MARK: AppPhoneCodeBuilderProtocol
extension AuthorizationBuilder: AppPhoneCodeBuilderProtocol {
    
    var phoneCodeCenterLabel: AppPhoneCodeCenterLabelProtocol? {
        AppPhoneCodeCenterLabel()
    }
    
}
