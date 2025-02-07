import UIKit

class ProfileBuilder: Builder {
    
    override init(injector: InjectorProtocol) {
        super.init(injector: injector)
        register()
    }
    
}

// MARK: Private
private extension ProfileBuilder {
    
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
        
        injector.register(in: .navigation, type: ProfileRouterProtocol.self) { _ in
            router
        }
    }
    
    func navigationController() {
        guard let screen = injector.resolve(from: .application, type: ScreenProtocol.self) else {
            return error(of: ScreenProtocol.self)
        }
        
        guard let device = injector.resolve(from: .application, type: DeviceProtocol.self) else {
            return error(of: DeviceProtocol.self)
        }
        
        guard let userManager = injector.resolve(from: .application, type: AppUserManager.self) else {
            return error(of: AppUserManager.self)
        }
        
        guard let pasteboard = injector.resolve(from: .application, type: PasteboardProtocol.self) else {
            return error(of: PasteboardProtocol.self)
        }
        
        guard let interfaceManager = injector.resolve(from: .application, type: InterfaceManager.self) else {
            return error(of: InterfaceManager.self)
        }
        
        guard let router = injector.resolve(from: .navigation, type: ProfileRouterProtocol.self) else {
            return error(of: ProfileRouterProtocol.self)
        }
        
        let rootDataSource = rootDataSource(screen, device)
        let rootDataManager = rootDataManager(userManager, rootDataSource, pasteboard)
        let rootDecoder = rootDecoder()
        let rootNetworkManager = rootNetworkManager(rootDecoder)
        let rootPresenter = presenter()
        let rootApperanceManager = appearanceManager(rootPresenter, interfaceManager)
        let rootViewModel = rootViewModel(router, rootDataManager, rootNetworkManager, rootApperanceManager)
        let rootImageView = imageView()
        let rootButton = button()
        let rootHeaderView = rootHeaderView(rootImageView, rootButton)
        let rootCenterViewDataSource = rootCenterViewDataSource()
        let rootCenterViewFlowLayout = rootCenterViewFlowLayout()
        let rootCenterView = rootCenterView(rootCenterViewDataSource, rootCenterViewFlowLayout)
        let rootView = rootView(rootHeaderView: rootHeaderView, rootCenterView: rootCenterView)
        let rootViewController = rootViewController(rootViewModel, rootView)
        let presenter = presenter()
        let dataSource = navigationDataSource()
        let viewModel = navigationViewModel(presenter, dataSource)
        let delegate = navigationControllerDelegate()
        let navigationController = navigationController(viewModel, delegate, rootViewController)
        
        router.internalEventPublisher.send(.inject(navigationController: navigationController))
        rootPresenter.internalEvеntPublisher.send(.inject(viewController: rootViewController))
        presenter.internalEvеntPublisher.send(.inject(viewController: navigationController))
        
        injector.register(in: .navigation, type: ProfileNavigationController.self) { _ in
            navigationController
        }
    }
    
}

// MARK: Public
extension ProfileBuilder {
    
    func imageView() -> UIImageView {
        UIImageView()
    }
    
    func label() -> UILabel {
        UILabel()
    }
    
    func view() -> UIView {
        UIView()
    }
    
    func button() -> AppButtonProtocol {
        let actionTarget = ActionTarget()
        return AppButton(actionTarget: actionTarget, overlay: nil)
    }
    
    func appearanceManager(_ presenter: AppearancePresenterProtocol, _ interfaceManager: InterfaceManagerInfoProtocol) -> AppearanceManagerProtocol {
        AppearanceManager(presenter: presenter, interfaceManager: interfaceManager)
    }

    func presenter() -> AppearancePresenterProtocol {
        AppearancePresenter()
    }
    
    func router(_ notificationsManager: AppNotificationsManagerPresentProtocol, _ displaySpinner: DisplaySpinnerProtocol, _ application: ApplicationProtocol) -> ProfileRouterProtocol {
        ProfileRouter(builder: self, notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
    }
    
    func navigationController(_ viewModel: ProfileNavigationViewModelProtocol, _ delegate: AppNavigationControllerDelegateProtocol, _ rootViewController: UIViewController) -> ProfileNavigationController {
        ProfileNavigationController(viewModel: viewModel, delegate: delegate, rootViewController: rootViewController)
    }
    
    func navigationControllerDelegate() -> AppNavigationControllerDelegateProtocol {
        AppNavigationControllerDelegate()
    }
    
    func navigationViewModel(_ presenter: AppearancePresenterProtocol, _ dataSource: ProfileNavigationDataSourceProtocol) -> ProfileNavigationViewModelProtocol {
        ProfileNavigationViewModel(presenter: presenter, dataSource: dataSource)
    }
    
    func navigationDataSource() -> ProfileNavigationDataSourceProtocol {
        ProfileNavigationDataSource()
    }
    
    func rootViewController(_ viewModel: ProfileRootViewModelProtocol, _ view: ProfileRootViewProtocol) -> ProfileRootViewController {
        ProfileRootViewController(viewModel: viewModel, view: view)
    }
    
    func rootViewModel(_ router: ProfileRouterProtocol, _ dataManager: ProfileRootDataManagerProtocol, _ networkManager: ProfileRootNetworkManagerProtocol, _ appearanceManager: AppearanceManagerProtocol) -> ProfileRootViewModelProtocol {
        ProfileRootViewModel(router: router, dataManager: dataManager, networkManager: networkManager, appearanceManager: appearanceManager)
    }
    
    func rootDataManager(_ userManager: AppUserManagerControlProtocol, _ dataSource: ProfileRootDataSourceProtocol, _ pasteboard: PasteboardProtocol) -> ProfileRootDataManagerProtocol {
        ProfileRootDataManager(userManager: userManager, dataSource: dataSource, pasteboard: pasteboard)
    }
    
    func rootDataSource(_ screen: ScreenProtocol, _ device: DeviceProtocol) -> ProfileRootDataSourceProtocol {
        ProfileRootDataSource(screen: screen, device: device)
    }

    func rootNetworkManager(_ decoder: JSONDecoderProtocol) -> ProfileRootNetworkManagerProtocol {
        ProfileRootNetworkManager(decoder: decoder)
    }
    
    func rootDecoder() -> JSONDecoderProtocol {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    func rootView(rootHeaderView: ProfileRootHeaderViewProtocol, rootCenterView: ProfileRootCenterViewProtocol) -> ProfileRootViewProtocol {
        ProfileRootView(headerView: rootHeaderView, centerView: rootCenterView)
    }
    
    func rootHeaderView(_ imageView: UIImageView, _ button: AppButtonProtocol) -> ProfileRootHeaderViewProtocol {
        ProfileRootHeaderView(imageView: imageView, button: button)
    }

    func rootCenterView(_ dataSource: ProfileRootCenterViewDataSourceProtocol, _ layout: UICollectionViewFlowLayout) -> ProfileRootCenterViewProtocol {
        ProfileRootCenterView(dataSource: dataSource, layout: layout)
    }
    
    func rootCenterViewDataSource() -> ProfileRootCenterViewDataSourceProtocol {
        ProfileRootCenterViewDataSource(builder: self)
    }
    
    func rootCenterViewFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }
    
    func rootCenterUserInfoCellView(_ phoneView: ProfileRootCenterUserInfoSectionViewProtocol, _ separator: UIView, _ nameView: ProfileRootCenterUserInfoSectionViewProtocol) -> ProfileRootCenterUserInfoCellView {
        ProfileRootCenterUserInfoCellView(phoneView: phoneView, nameView: nameView, separator: separator)
    }
    
    func rootCenterUserInfoSectionView(_ titleLabel: UILabel, _ textLabel: UILabel, _ copyIcon: UIImageView) -> ProfileRootCenterUserInfoSectionViewProtocol {
        ProfileRootCenterUserInfoSectionView(titleLabel: titleLabel, subtitleLabel: textLabel, actionIcon: copyIcon)
    }
    
    func rootCenterLogoutCellView(_ logoutLabel: UILabel, _ separator: UIView, _ deleteLabel: UILabel) -> ProfileRootCenterLogoutCellView {
        ProfileRootCenterLogoutCellView(logoutLabel: logoutLabel, deleteLabel: deleteLabel, separator: separator)
    }
    
}

// MARK: ProfileBuilderProtocol
extension ProfileBuilder: ProfileBuilderProtocol {
    
    var coordinator: ProfileCoordinatorProtocol? {
        guard let router = injector.resolve(from: .navigation, type: ProfileRouterProtocol.self) else {
            return error(of: ProfileRouterProtocol.self)
        }
        
        return ProfileCoordinator(router: router)
    }
    
}

// MARK: ProfileBuilderRoutingProtocol
extension ProfileBuilder: ProfileBuilderRoutingProtocol {}

// MARK: ProfileBuilderCenterCellProtocol
extension ProfileBuilder: ProfileBuilderCenterCellProtocol {
    
    func centerUserInfoCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ data: Any?, _ action: ((ProfileRootCenterViewExternalEvent) -> Void)?) -> ProfileRootCenterUserInfoCell? {
        guard let data else {
            return error(of: ProfileRootCenterUserInfoCellData.self)
        }
        
        let phoneTitleLabel = label()
        let phoneTextLabel = label()
        let phoneCopyIcon = imageView()
        let nameTitleLabel = label()
        let nameTextLabel = label()
        let nameEditIcon = imageView()
        let phoneView = rootCenterUserInfoSectionView(phoneTitleLabel, phoneTextLabel, phoneCopyIcon)
        let nameView = rootCenterUserInfoSectionView(nameTitleLabel, nameTextLabel, nameEditIcon)
        let separator = view()
        let view = rootCenterUserInfoCellView(phoneView, separator, nameView)
        let content = ProfileRootCenterUserInfoCellContent(data: data, action: action)
        let cell = UICollectionViewCell.create(type: ProfileRootCenterUserInfoCell.self, collectionView, indexPath)
        
        cell.internalEventPublisher.send(.inject(view))
        cell.internalEventPublisher.send(.data(content))
        return cell
    }
    
    func centerLogoutCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ data: Any?, _ action: ((ProfileRootCenterViewExternalEvent) -> Void)?) -> ProfileRootCenterLogoutCell? {
        guard let data else {
            return error(of: ProfileRootCenterLogoutCellData.self)
        }
        
        let logoutLabel = label()
        let deleteLabel = label()
        let separator = view()
        let view = rootCenterLogoutCellView(logoutLabel, separator, deleteLabel)
        let content = ProfileRootCenterLogoutCellContent(data: data, action: action)
        let cell = UICollectionViewCell.create(type: ProfileRootCenterLogoutCell.self, collectionView, indexPath)
        
        cell.internalEventPublisher.send(.inject(view))
        cell.internalEventPublisher.send(.data(content))
        return cell
    }
    
}
