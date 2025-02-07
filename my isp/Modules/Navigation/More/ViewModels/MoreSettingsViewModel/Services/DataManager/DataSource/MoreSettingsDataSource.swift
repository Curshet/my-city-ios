import UIKit
import Combine

class MoreSettingsDataSource: MoreSettingsDataSourceProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreSettingsDataSourceInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MoreSettingsDataSourceExternalEvent, Never>
    
    private let screen: ScreenProtocol
    private let device: DeviceProtocol
    private let externalPublisher: PassthroughSubject<MoreSettingsDataSourceExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(screen: ScreenProtocol, device: DeviceProtocol) {
        self.screen = screen
        self.device = device
        self.internalEventPublisher = PassthroughSubject<MoreSettingsDataSourceInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MoreSettingsDataSourceExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension MoreSettingsDataSource {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MoreSettingsDataSourceInternalEvent) {
        switch event {
            case .view(let userInfo):
                let value = view(userInfo)
                externalPublisher.send(.view(value))
            
            case .update(let userInfo):
                let value = update(userInfo)
                externalPublisher.send(.update(value))

            case .navigationBar(let frame):
                let value = navigationBar(frame)
                externalPublisher.send(.appearance(.navigationBar(value)))
        }
    }
    
    func view(_ userInfo: AppUserInfo?) -> MoreSettingsViewData {
        let layout = MoreSettingsViewLayout()
        let items: [Any] = [security(userInfo)]
        let data = MoreSettingsViewData(layout: layout, items: items)
        return data
    }
    
    func update(_ userInfo: AppUserInfo?) -> MoreSettingsViewUpdateData {
        let indexPath = IndexPath(row: 0, section: 0)
        let items: [Any] = [security(userInfo)]
        let data = MoreSettingsViewUpdateData(indexPath: indexPath, items: items)
        return data
    }
    
    func security(_ userInfo: AppUserInfo?) -> MoreSettingsSecurityCellData {
        let size = CGSize(width: screen.bounds.width - 40, height: 0)
        let layout = MoreSettingsSecurityCellLayout(size: size)
        let header = String.localized.entry
        let biometrics = biometrics(userInfo)
        let password = password(userInfo)
        let data = MoreSettingsSecurityCellData(layout: layout, header: header, biometrics: biometrics, password: password)
        return data
    }
    
    func biometrics(_ userInfo: AppUserInfo?) -> MoreSettingsSecuritySectionData {
        let layout = MoreSettingsSecuritySectionLayout()
        let title = String.localized.moreBiometrics
        let suffix = device.isUsingFaceID ? "Face ID" : "Touch ID"
        let subtitle = "\(String.localized.moreBiometricsSubtitle) " + suffix
        let isOn = userInfo?.biometrics != nil
        let data = MoreSettingsSecuritySectionData(layout: layout, title: title, subtitle: subtitle, isOn: isOn)
        return data
    }
    
    func password(_ userInfo: AppUserInfo?) -> MoreSettingsSecuritySectionData {
        let layout = MoreSettingsSecuritySectionLayout()
        let title = String.localized.morePassword
        let subtitle = String.localized.morePasswordSubtitle
        let isOn = userInfo?.password != nil
        let data = MoreSettingsSecuritySectionData(layout: layout, title: title, subtitle: subtitle, isOn: isOn)
        return data
    }
    
    func navigationBar(_ frame: CGRect) -> NavigationBarAppearance {
        let title = String.localized.settings
        let model = NavigationBarAppearanceModel(title: title)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.titleTextAttributes = [.font : UIFont.boldSystemFont(ofSize: 14.fitWidth), .foregroundColor : UIColor.interfaceManager.white()]
        navigationBarAppearance.backgroundImage = UIImage.interfaceManager.themeNavigationBar(frame: frame)
        navigationBarAppearance.backgroundImageContentMode = .scaleAspectFill
        navigationBarAppearance.shadowColor = .clear
        let appearance = NavigationBarAppearance(model: model, standard: navigationBarAppearance, compact: navigationBarAppearance, scrollEdge: navigationBarAppearance)
        return appearance
    }
    
}

// MARK: - MoreSettingsDataSourceInternalEvent
enum MoreSettingsDataSourceInternalEvent {
    case view(AppUserInfo?)
    case update(AppUserInfo?)
    case navigationBar(CGRect)
}

// MARK: - MoreSettingsDataSourceExternalEvent
enum MoreSettingsDataSourceExternalEvent {
    case view(MoreSettingsViewData)
    case update(MoreSettingsViewUpdateData)
    case appearance(AppearanceTarget)
}
