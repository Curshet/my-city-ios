import UIKit
import Combine

class ProfileRootDataSource: ProfileRootDataSourceProtocol {

    let internalEventPublisher: PassthroughSubject<ProfileRootDataSourceInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<ProfileRootDataSourceExternalEvent, Never>
    
    private let screen: ScreenProtocol
    private let device: DeviceProtocol
    private let externalPublisher: PassthroughSubject<ProfileRootDataSourceExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(screen: ScreenProtocol, device: DeviceProtocol) {
        self.screen = screen
        self.device = device
        self.internalEventPublisher = PassthroughSubject<ProfileRootDataSourceInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<ProfileRootDataSourceExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension ProfileRootDataSource {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: ProfileRootDataSourceInternalEvent) {
        switch event {
            case .view(let userInfo):
                let value = view(userInfo)
                externalPublisher.send(.view(value))
        
            case .userImage(let userInfo):
                let value = UIImage.create(data: userInfo?.userImage)
                externalPublisher.send(.userImage(value))

            case .userInfo(let userInfo):
                let indexPath = IndexPath(row: 0, section: 0)
                let value = centerSection(userInfo, indexPath)
                externalPublisher.send(.userInfo(value))

            case .navigationBar(let frame):
                let value = navigationBar(frame)
                externalPublisher.send(.appearance(.navigationBar(value)))
            
            case .alert:
                externalPublisher.send(.alert(nil))
            
            case .notify(let type):
                let message = type == .copy ? String.localized.profilePhoneCopied : String.localized.authorizationCaution
                let value = AppUserNotificationType.action(.copy(message))
                externalPublisher.send(.notify(value))
        }
    }
    
    func view(_ userInfo: AppUserInfo?) -> ProfileRootViewData {
        let header = headerSection(userInfo?.userImage)
        let center = centerSection(userInfo, nil)
        let data = ProfileRootViewData(header: header, center: center)
        return data
    }
    
    func headerSection(_ data: Data?) -> ProfileRootHeaderData {
        let layout = ProfileRootHeaderViewLayout()
        let image = UIImage.create(data: data)
        let userImage = image == .clear ? editImageCamera() : image
        let icon = UIImage.system(.slider).withSize(width: 16.fitWidth, height: 13.fitWidth).setColor(.white)
        let background = editImageBackground()
        let data = ProfileRootHeaderData(layout: layout, image: userImage, icon: icon, background: background)
        return data
    }
    
    func centerSection(_ userInfo: AppUserInfo?, _ indexPath: IndexPath?) -> ProfileRootCenterData {
        let layout = ProfileRootCenterViewLayout()
        let infoItem = userInfoItem(userInfo?.userPhone, userInfo?.userName)
        let logoutItem = logoutItem()
        let items: [Any] = [infoItem, logoutItem]
        let data = ProfileRootCenterData(layout: layout, indexPath: indexPath, items: items)
        return data
    }
    
    func userInfoItem(_ phone: String?, _ name: String?) -> ProfileRootCenterUserInfoCellData {
        let size = CGSize(width: screen.bounds.width - 40, height: 0)
        let layout = ProfileRootCenterUserInfoCellLayout(size: size)
        let phone = userPhone(String(phone))
        let name = userName(String(name))
        let item = ProfileRootCenterUserInfoCellData(layout: layout, phone: phone, name: name)
        return item
    }
    
    func logoutItem() -> ProfileRootCenterLogoutCellData {
        let size = CGSize(width: screen.bounds.width - 40, height: 0)
        let layout = ProfileRootCenterLogoutCellLayout(size: size)
        let exitTitle = String.localized.profileLogout
        let deleteTitle = String.localized.profileDeleteProfile
        let item = ProfileRootCenterLogoutCellData(layout: layout, exitTitle: exitTitle, deleteTitle: deleteTitle)
        return item
    }
    
    func userPhone(_ phone: String) -> ProfileRootCenterUserInfoSectionData {
        let cornerMask = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        let layout = ProfileRootCenterUserInfoSectionLayout(cornerMask: cornerMask)
        let title = String.localized.profilePhone
        let text = phone.isEmptyContent ? String.localized.emptyContent : phone.phoneMask(withCode: true)
        let icon = UIImage.system(.copy)
        let data = ProfileRootCenterUserInfoSectionData(layout: layout, title: title, subtitle: text, icon: icon)
        return data
    }
    
    func userName(_ name: String) -> ProfileRootCenterUserInfoSectionData {
        let cornerMask = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
        let layout = ProfileRootCenterUserInfoSectionLayout(cornerMask: cornerMask)
        let title = String.localized.profileName
        let text = name.isEmptyContent ? .localized.profileEnterName : name
        let icon = UIImage.system(.pencil)
        let data = ProfileRootCenterUserInfoSectionData(layout: layout, title: title, subtitle: text, icon: icon)
        return data
    }
    
    func editImageCamera() -> UIImage? {
        let backgroundFrame = CGRect(x: 0, y: 0, width: 90.fitWidth, height: 90.fitWidth)
        let background = CAGradientLayer.interfaceManager.themeViolet(frame: backgroundFrame, corner: 0).image
        let width = 28.fitWidth
        let height = 21.fitWidth
        let centerX = (backgroundFrame.width - width) / 2
        let centerY = (backgroundFrame.height - height) / 2
        let iconFrame = CGRect(x: centerX, y: centerY, width: width, height: height)
        let configuration = UIImage.SymbolConfiguration(pointSize: 100.fitWidth, weight: .regular, scale: .large)
        let icon = UIImage.system(.camera, configuration: configuration).setColor(.white)
        let image = background?.addImage(icon, rectangle: iconFrame)
        return image
    }
    
    func editImageBackground() -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: screen.bounds.width, height: screen.bounds.height / 4)
        let background = CAGradientLayer.interfaceManager.themeViolet(frame: frame, corner: 0).image
        let image = background?.addImage(UIImage.profileRootHeaderUserImageBackground)
        return image
    }
    
    func navigationBar(_ frame: CGRect) -> NavigationBarAppearance {
        let model = NavigationBarAppearanceModel(interactive: false)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        let appearance = NavigationBarAppearance(model: model, standard: navigationBarAppearance, compact: navigationBarAppearance, scrollEdge: navigationBarAppearance)
        return appearance
    }

}

// MARK: - ProfileRootDataSourceInternalEvent
enum ProfileRootDataSourceInternalEvent {
    case view(AppUserInfo?)
    case navigationBar(CGRect)
    case userImage(AppUserInfo?)
    case userInfo(AppUserInfo?)
    case alert(ProfileRootDataSourceAlert)
    case notify(ProfileRootDataSourceNotify)
}

// MARK: - ProfileRootDataSourceAlert
enum ProfileRootDataSourceAlert {
    case logout
    case delete
}

// MARK: - ProfileRootDataSourceNotify
enum ProfileRootDataSourceNotify {
    case copy
    case authorization
}

// MARK: - ProfileRootDataSourceExternalEvent
enum ProfileRootDataSourceExternalEvent {
    case view(ProfileRootViewData)
    case appearance(AppearanceTarget)
    case userImage(UIImage?)
    case userInfo(ProfileRootCenterData)
    case alert(Any?)
    case notify(AppUserNotificationType)
}
