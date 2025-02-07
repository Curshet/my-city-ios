import UIKit

class MoreBuilder: Builder {

    override init(injector: InjectorProtocol) {
        super.init(injector: injector)
        register()
    }
    
}

// MARK: Private
private extension MoreBuilder {
    
    func register() {
        router()
        dataCache()
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
        
        injector.register(in: .navigation, type: MoreRouterProtocol.self) { _ in
            router
        }
    }
    
    func dataCache() {
        let dataCache = MoreRootDataCache()
        
        injector.register(in: .navigation, type: MoreRootDataCache.self) { _ in
            dataCache
        }
    }
    
    func navigationController() {
        guard let bundle = injector.resolve(from: .application, type: BundleProtocol.self) else {
            return error(of: BundleProtocol.self)
        }
        
        guard let device = injector.resolve(from: .application, type: DeviceProtocol.self) else {
            return error(of: DeviceProtocol.self)
        }
        
        guard let screen = injector.resolve(from: .application, type: ScreenProtocol.self) else {
            return error(of: ScreenProtocol.self)
        }
        
        guard let userManager = injector.resolve(from: .application, type: AppUserManager.self) else {
            return error(of: AppUserManager.self)
        }
        
        guard let dataCache = injector.resolve(from: .navigation, type: MoreRootDataCache.self) else {
            return error(of: MoreRootDataCache.self)
        }
        
        guard let pasteboard = injector.resolve(from: .application, type: PasteboardProtocol.self) else {
            return error(of: PasteboardProtocol.self)
        }
        
        guard let interfaceManager = injector.resolve(from: .application, type: InterfaceManager.self) else {
            return error(of: InterfaceManager.self)
        }
        
        guard let router = injector.resolve(from: .navigation, type: MoreRouterProtocol.self) else {
            return error(of: MoreRouterProtocol.self)
        }
        
        let rootDataSource = rootDataSource(bundle, device, screen)
        let rootDataManager = rootDataManager(userManager, dataCache, rootDataSource, pasteboard)
        let rootDecoder = rootDecoder()
        let rootNetworkManager = rootNetworkManager(rootDecoder)
        let rootPresenter = presenter()
        let rootAppearanceManager = appearanceManager(rootPresenter, interfaceManager)
        let rootViewModel = rootViewModel(router, rootDataManager, rootNetworkManager, rootAppearanceManager)
        let rootCollectionViewDelegate = rootCollectionViewDelegate(dataCache)
        let rootCollectionViewDataSource = rootCollectionViewDataSource(dataCache)
        let rootCollectionViewFlowLayout = collectionViewFlowLayout()
        let rootCollectionView = rootCollectionView(rootCollectionViewDelegate, rootCollectionViewDataSource, rootCollectionViewFlowLayout)
        let rootViewController = rootViewController(rootViewModel, rootCollectionView)
        let presenter = presenter()
        let dataSource = navigationDataSource()
        let viewModel = navigationViewModel(presenter, dataSource)
        let delegate = navigationControllerDelegate()
        let navigationController = navigationController(viewModel, delegate, rootViewController)
        
        router.internalEventPublisher.send(.inject(navigationController: navigationController))
        rootPresenter.internalEvеntPublisher.send(.inject(viewController: rootViewController))
        presenter.internalEvеntPublisher.send(.inject(viewController: navigationController))

        injector.register(in: .navigation, type: MoreNavigationController.self) { _ in
            navigationController
        }
    }
    
}

// MARK: Public
extension MoreBuilder {
    
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
    
    func collectionViewFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }
    
    func appearanceManager(_ presenter: AppearancePresenterProtocol, _ interfaceManager: InterfaceManagerInfoProtocol) -> AppearanceManagerProtocol {
        AppearanceManager(presenter: presenter, interfaceManager: interfaceManager)
    }
    
    func presenter() -> AppearancePresenterProtocol {
        AppearancePresenter()
    }
    
    func router(_ notificationsManager: AppNotificationsManagerPresentProtocol, _ displaySpinner: DisplaySpinnerProtocol, _ application: ApplicationProtocol) -> MoreRouterProtocol {
        MoreRouter(builder: self, notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
    }
    
    func navigationController(_ viewModel: MoreNavigationViewModelProtocol, _ delegate: AppNavigationControllerDelegateProtocol, _ rootViewController: UIViewController) -> MoreNavigationController {
        MoreNavigationController(viewModel: viewModel, delegate: delegate, rootViewController: rootViewController)
    }
    
    func navigationControllerDelegate() -> AppNavigationControllerDelegateProtocol {
        AppNavigationControllerDelegate()
    }
    
    func navigationViewModel(_ presenter: AppearancePresenterProtocol, _ dataSource: MoreNavigationDataSourceProtocol) -> MoreNavigationViewModelProtocol {
        MoreNavigationViewModel(presenter: presenter, dataSource: dataSource)
    }
    
    func navigationDataSource() -> MoreNavigationDataSourceProtocol {
        MoreNavigationDataSource()
    }

    func rootViewController(_ viewModel: MoreRootViewModelProtocol, _ view: MoreRootCollectionViewProtocol) -> MoreRootViewController {
        MoreRootViewController(viewModel: viewModel, view: view)
    }
    
    func rootViewModel(_ router: MoreRouterProtocol, _ dataManager: MoreRootDataManagerProtocol, _ networkManager: MoreRootNetworkManagerProtocol, _ appearanceManager: AppearanceManagerProtocol) -> MoreRootViewModelProtocol {
        MoreRootViewModel(router: router, dataManager: dataManager, networkManager: networkManager, appearanceManager: appearanceManager)
    }
    
    func rootDataManager(_ userManager: AppUserManagerInfoProtocol, _ dataCache: MoreRootDataCacheControlProtocol, _ dataSource: MoreRootDataSourceProtocol, _ pasteboard: PasteboardProtocol) -> MoreRootDataManagerProtocol {
        MoreRootDataManager(userManager: userManager, dataCache: dataCache, dataSource: dataSource, pasteboard: pasteboard)
    }
    
    func rootDataSource(_ bundle: BundleProtocol, _ device: DeviceProtocol, _ screen: ScreenProtocol) -> MoreRootDataSourceProtocol {
        MoreRootDataSource(bundle: bundle, device: device, screen: screen)
    }
    
    func rootNetworkManager(_ decoder: JSONDecoderProtocol) -> MoreRootNetworkManagerProtocol {
        MoreRootNetworkManager(decoder: decoder)
    }
    
    func rootDecoder() -> JSONDecoderProtocol {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    func rootCollectionView(_ delegate: AppCollectionViewDelegateProtocol, _ dataSource: MoreRootCollectionViewDataSourceProtocol, _ layout: UICollectionViewFlowLayout) -> MoreRootCollectionViewProtocol {
        MoreRootCollectionView(delegate: delegate, dataSource: dataSource, layout: layout)
    }
    
    func rootCollectionViewDelegate(_ dataCache: MoreRootDataCacheSizesProtocol?) -> AppCollectionViewDelegateProtocol {
        MoreRootCollectionViewDelegate(dataCache: dataCache)
    }
    
    func rootCollectionViewDataSource(_ dataCache: MoreRootDataCacheItemsProtocol) -> MoreRootCollectionViewDataSourceProtocol {
        MoreRootCollectionViewDataSource(builder: self, dataCache: dataCache)
    }
    
    func rootNavigationCellView(_ titleLabel: UILabel, _ actionIcon: UIImageView) -> MoreRootNavigationCellView {
        MoreRootNavigationCellView(titleLabel: titleLabel, actionIcon: actionIcon)
    }
    
    func rootSystemInfoCellView(_ titleLabel: UILabel, _ subtitleLabel: UILabel, _ actionIcon: UIImageView) -> MoreRootSystemInfoCellView {
        MoreRootSystemInfoCellView(titleLabel: titleLabel, subtitleLabel: subtitleLabel, actionIcon: actionIcon)
    }
    
    func supportViewController(_ viewModel: MoreSupportViewModelProtocol, _ view: MoreSupportCollectionViewProtocol) -> MoreSupportViewController {
        let viewController = MoreSupportViewController(viewModel: viewModel, view: view)
        viewController.hidesBottomBarWhenPushed = false
        return viewController
    }
    
    func supportViewModel(_ router: MoreRouterProtocol, _ dataManager: MoreSupportDataManagerProtocol, _ appearanceManager: AppearanceManagerProtocol) -> MoreSupportViewModelProtocol {
        MoreSupportViewModel(router: router, dataManager: dataManager, appearanceManager: appearanceManager)
    }
    
    func supportDataManager(_ dataCache: MoreRootDataCacheInfoProtocol, _ dataSource: MoreSupportDataSourceProtocol) -> MoreSupportDataManagerProtocol {
        MoreSupportDataManager(dataCache: dataCache, dataSource: dataSource)
    }
    
    func supportDataSource(_ device: DeviceProtocol, _ screen: ScreenProtocol) -> MoreSupportDataSourceProtocol {
        MoreSupportDataSource(device: device, screen: screen)
    }
    
    func supportCollectionView(_ dataSource: MoreSupportCollectionViewDataSourceProtocol, _ layout: UICollectionViewFlowLayout) -> MoreSupportCollectionViewProtocol {
        MoreSupportCollectionView(dataSource: dataSource, layout: layout)
    }
    
    func supportCollectionViewDataSource() -> MoreSupportCollectionViewDataSourceProtocol {
        MoreSupportCollectionViewDataSource(builder: self)
    }

    func supportPhoneCellView(_ titleLabel: UILabel, _ phoneLabel: UILabel, _ phoneIcon: UIImageView) -> MoreSupportPhoneCellView {
        MoreSupportPhoneCellView(titleLabel: titleLabel, phoneLabel: phoneLabel, phoneIcon: phoneIcon)
    }
    
    func supportMessengersCellView(_ titleLabel: UILabel, _ stackView: UIStackView, _ telegramButton: AppButtonProtocol, _ whatsAppButton: AppButtonProtocol, _ viberButton: AppButtonProtocol) -> MoreSupportMessengersCellView {
        MoreSupportMessengersCellView(titleLabel: titleLabel, stackView: stackView, telegramButton: telegramButton, whatsAppButton: whatsAppButton, viberButton: viberButton)
    }
    
    func supportMessengersCellStackView() -> UIStackView {
        UIStackView()
    }
    
    func settingsViewController(_ viewModel: MoreSettingsViewModelProtocol, _ view: MoreSettingsCollectionViewProtocol) -> MoreSettingsViewController {
        let viewController = MoreSettingsViewController(viewModel: viewModel, view: view)
        viewController.hidesBottomBarWhenPushed = false
        return viewController
    }
    
    func settingsViewModel(_ router: MoreRouterProtocol, _ dataManager: MoreSettingsDataManagerProtocol, _ appearanceManager: AppearanceManagerProtocol) -> MoreSettingsViewModelProtocol {
        MoreSettingsViewModel(router: router, dataManager: dataManager, appearanceManager: appearanceManager)
    }
    
    func settingsDataManager(_ userManager: AppUserManagerInfoProtocol, _ dataSource: MoreSettingsDataSourceProtocol) -> MoreSettingsDataManagerProtocol {
        MoreSettingsDataManager(userManager: userManager, dataSource: dataSource)
    }
    
    func settingsDataSource(_ screen: ScreenProtocol, _ device: DeviceProtocol) -> MoreSettingsDataSourceProtocol {
        MoreSettingsDataSource(screen: screen, device: device)
    }
    
    func settingsCollectionView(_ dataSource: MoreSettingsCollectionViewDataSourceProtocol, _ layout: UICollectionViewFlowLayout) -> MoreSettingsCollectionViewProtocol {
        MoreSettingsCollectionView(dataSource: dataSource, layout: layout)
    }
    
    func settingsCollectionViewDataSource() -> MoreSettingsCollectionViewDataSourceProtocol {
        MoreSettingsCollectionViewDataSource(builder: self)
    }
    
    func settingsSecurityCellView(_ headerLabel: UILabel, _ biometricsView: MoreSettingsSecuritySectionViewProtocol, _ passwordView: MoreSettingsSecuritySectionViewProtocol, _ separator: UIView) -> MoreSettingsSecurityCellView {
        MoreSettingsSecurityCellView(headerLabel: headerLabel, biometricsView: biometricsView, passwordView: passwordView, separator: separator)
    }
    
    func settingsSecurityCellSeparator() -> UIView {
        UIView()
    }
    
    func settingsSecuritySectionView(_ titleLabel: UILabel, _ subtitleLabel: UILabel, _ switсh: AppSwitchProtocol) -> MoreSettingsSecuritySectionViewProtocol {
        MoreSettingsSecuritySectionView(titleLabel: titleLabel, subtitleLabel: subtitleLabel, switсh: switсh)
    }
    
    func settingsSecuritySectionSwitch() -> AppSwitchProtocol {
        let actionTarget = ActionTarget()
        return AppSwitch(actionTarget: actionTarget, overlay: nil)
    }
    
    func shareViewModel(_ dataSource: MoreShareDataSourceProtocol) -> MoreShareViewModelProtocol {
        MoreShareViewModel(dataSource: dataSource)
    }
    
    func shareDataSource(_ bundle: BundleProtocol) -> MoreShareDataSourceProtocol {
        MoreShareDataSource(bundle: bundle)
    }

}

// MARK: MoreBuilderProtocol
extension MoreBuilder: MoreBuilderProtocol {
    
    var coordinator: MoreCoordinatorProtocol? {
        guard let router = injector.resolve(from: .navigation, type: MoreRouterProtocol.self) else {
            return error(of: MoreRouterProtocol.self)
        }
        
        return MoreCoordinator(router: router)
    }

}

// MARK: MoreBuilderRoutingProtocol
extension MoreBuilder: MoreBuilderRoutingProtocol {
    
    var supportViewController: MoreSupportViewController? {
        guard let device = injector.resolve(from: .application, type: DeviceProtocol.self) else {
            return error(of: DeviceProtocol.self)
        }
        
        guard let screen = injector.resolve(from: .application, type: ScreenProtocol.self) else {
            return error(of: ScreenProtocol.self)
        }
        
        guard let dataCache = injector.resolve(from: .navigation, type: MoreRootDataCache.self) else {
            return error(of: MoreRootDataCache.self)
        }
        
        guard let interfaceManager = injector.resolve(from: .application, type: InterfaceManager.self) else {
            return error(of: InterfaceManager.self)
        }
        
        guard let router = injector.resolve(from: .navigation, type: MoreRouterProtocol.self) else {
            return error(of: MoreRouterProtocol.self)
        }

        let dataSource = supportDataSource(device, screen)
        let dataManager = supportDataManager(dataCache, dataSource)
        let presenter = presenter()
        let appearanceManager = appearanceManager(presenter, interfaceManager)
        let viewModel = supportViewModel(router, dataManager, appearanceManager)
        let collectionViewDataSource = supportCollectionViewDataSource()
        let collectionViewFlowLayout = collectionViewFlowLayout()
        let collectionView = supportCollectionView(collectionViewDataSource, collectionViewFlowLayout)
        let viewController = supportViewController(viewModel, collectionView)
        
        presenter.internalEvеntPublisher.send(.inject(viewController: viewController))
        collectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return viewController
    }
    
    var settingsViewController: MoreSettingsViewController? {
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
        
        guard let router = injector.resolve(from: .navigation, type: MoreRouterProtocol.self) else {
            return error(of: MoreRouterProtocol.self)
        }
        
        let dataSource = settingsDataSource(screen, device)
        let dataManager = settingsDataManager(userManager, dataSource)
        let presenter = presenter()
        let appearanceManager = appearanceManager(presenter, interfaceManager)
        let viewModel = settingsViewModel(router, dataManager, appearanceManager)
        let collectionViewDataSource = settingsCollectionViewDataSource()
        let collectionViewFlowLayout = collectionViewFlowLayout()
        let collectionView = settingsCollectionView(collectionViewDataSource, collectionViewFlowLayout)
        let viewController = settingsViewController(viewModel, collectionView)
        
        presenter.internalEvеntPublisher.send(.inject(viewController: viewController))
        collectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return viewController
    }
    
    var shareViewController: MoreShareViewController? {
        guard let bundle = injector.resolve(from: .application, type: BundleProtocol.self) else {
            return error(of: BundleProtocol.self)
        }
        
        let dataSource = shareDataSource(bundle)
        let viewModel = shareViewModel(dataSource)
        return MoreShareViewController(viewModel: viewModel)
    }
    
}

// MARK: MoreBuilderRootCellProtocol
extension MoreBuilder: MoreBuilderRootCellProtocol {
    
    func rootNavigationCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ data: Any?, _ action: ((MoreRootViewModelSelectEvent) -> Void)?) -> MoreRootNavigationCell? {
        guard let data else {
            return error(of: MoreRootNavigationCellData.self)
        }
        
        let titleLabel = label()
        let actionIcon = imageView()
        let view = rootNavigationCellView(titleLabel, actionIcon)
        let content = MoreRootNavigationCellContent(data: data, action: action)
        let cell = UICollectionViewCell.create(type: MoreRootNavigationCell.self, collectionView, indexPath)
        
        cell.internalEventPublisher.send(.inject(view))
        cell.internalEventPublisher.send(.data(content))
        return cell
    }
    
    func rootSystemInfoCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ data: Any?, _ action: ((MoreRootViewModelSelectEvent) -> Void)?) -> MoreRootSystemInfoCell? {
        guard let data else {
            return error(of: MoreRootSystemInfoCellData.self)
        }
        
        let titleLabel = label()
        let subtitleLabel = label()
        let actionIcon = imageView()
        let view = rootSystemInfoCellView(titleLabel, subtitleLabel, actionIcon)
        let content = MoreRootSystemInfoCellContent(data: data, action: action)
        let cell = UICollectionViewCell.create(type: MoreRootSystemInfoCell.self, collectionView, indexPath)
        
        cell.internalEventPublisher.send(.inject(view))
        cell.internalEventPublisher.send(.data(content))
        return cell
    }
    
}

// MARK: MoreBuilderSupportCellProtocol
extension MoreBuilder: MoreBuilderSupportCellProtocol {
    
    func supportPhoneCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ data: Any?, _ action: ((MoreSupportViewModelSelectEvent) -> Void)?) -> MoreSupportPhoneCell? {
        guard let data else {
            return error(of: MoreSupportPhoneCellData.self)
        }
        
        let titleLabel = label()
        let phoneLabel = label()
        let phoneIcon = imageView()
        let view = supportPhoneCellView(titleLabel, phoneLabel, phoneIcon)
        let content = MoreSupportPhoneCellContent(data: data, action: action)
        let cell = UICollectionViewCell.create(type: MoreSupportPhoneCell.self, collectionView, indexPath)
        
        cell.internalEventPublisher.send(.inject(view))
        cell.internalEventPublisher.send(.data(content))
        return cell
    }
    
    func supportMessengersCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ data: Any?, _ action: ((MoreSupportViewModelSelectEvent) -> Void)?) -> MoreSupportMessengersCell? {
        guard let data else {
            return error(of: MoreSupportMessengersCellData.self)
        }

        let titleLabel = label()
        let stackView = supportMessengersCellStackView()
        let telegramButton = button()
        let whatsAppButton = button()
        let viberButton = button()
        let view = supportMessengersCellView(titleLabel, stackView, telegramButton, whatsAppButton, viberButton)
        let content = MoreSupportMessengersCellContent(data: data, action: action)
        let cell = UICollectionViewCell.create(type: MoreSupportMessengersCell.self, collectionView, indexPath)
        
        cell.internalEventPublisher.send(.inject(view))
        cell.internalEventPublisher.send(.data(content))
        return cell
    }
    
}

// MARK: MoreBuilderSettingsCellProtocol
extension MoreBuilder: MoreBuilderSettingsCellProtocol {
    
    func securityCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ data: Any?, _ action: ((MoreSettingsViewModelSelectEvent) -> Void)?) -> MoreSettingsSecurityCell? {
        guard let data else {
            return error(of: MoreSettingsSecurityCellData.self)
        }

        let headerLabel = label()
        let biometricsTitle = label()
        let biometricsSubtitle = label()
        let biometricsSwitсh = settingsSecuritySectionSwitch()
        let biometricsView = settingsSecuritySectionView(biometricsTitle, biometricsSubtitle, biometricsSwitсh)
        let passwordTitle = label()
        let passwordSubtitle = label()
        let passwordSwitсh = settingsSecuritySectionSwitch()
        let passwordView = settingsSecuritySectionView(passwordTitle, passwordSubtitle, passwordSwitсh)
        let separator = settingsSecurityCellSeparator()
        let view = settingsSecurityCellView(headerLabel, biometricsView, passwordView, separator)
        let content = MoreSettingsSecurityCellContent(data: data, action: action)
        let cell = UICollectionViewCell.create(type: MoreSettingsSecurityCell.self, collectionView, indexPath)
        
        cell.internalEventPublisher.send(.inject(view))
        cell.internalEventPublisher.send(.data(content))
        return cell
    }
    
}
