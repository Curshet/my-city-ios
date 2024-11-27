import UIKit
import Combine

class MoreRootDataSource: MoreRootDataSourceProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreRootDataSourceInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MoreRootDataSourceExternalEvent, Never>
    
    private let bundle: BundleProtocol
    private let device: DeviceProtocol
    private let screen: ScreenProtocol
    private let externalPublisher: PassthroughSubject<MoreRootDataSourceExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(bundle: BundleProtocol, device: DeviceProtocol, screen: ScreenProtocol) {
        self.bundle = bundle
        self.device = device
        self.screen = screen
        self.internalEventPublisher = PassthroughSubject<MoreRootDataSourceInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MoreRootDataSourceExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension MoreRootDataSource {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MoreRootDataSourceInternalEvent) {
        switch event {
            case .view:
                let value = view()
                externalPublisher.send(.view(value))
            
            case .request(let userInfo):
                let value = request(userInfo)
                externalPublisher.send(.request(value))
            
            case .navigationBar(let frame):
                let value = navigationBar(frame)
                externalPublisher.send(.appearance(.navigationBar(value)))
            
            case .systemInfo:
                let value = systemInfo()
                let message = String.localized.moreInfoCopied
                let notify = AppUserNotificationType.action(.copy(message))
                externalPublisher.send(.systemInfo(value: value, notify: notify))
        }
    }

    func view() -> MoreRootViewData {
        let layout = MoreRootViewLayout()
        let items = items()
        let data = MoreRootViewData(layout: layout, items: items)
        return data
    }
    
    func items() -> MoreRootViewItems {
        let supportItem = supportItem()
        let settingsItem = settingsItem()
        let shareItem = shareItem()
        let systemInfoItem = systemInfoItem()
        let values: [Any] = [supportItem, settingsItem, shareItem, systemInfoItem]
        let sizes = sizes()
        let items = MoreRootViewItems(values: values, sizes: sizes)
        return items
    }
    
    func supportItem() -> MoreRootNavigationCellData {
        let layout = MoreRootNavigationCellLayout()
        let event = MoreRootViewModelSelectEvent.support
        let title = String.localized.moreSupport
        let image = UIImage.system(.arrowRight)
        let icon = MoreRootNavigationCellActionIcon.arrow(image)
        let item = MoreRootNavigationCellData(layout: layout, event: event, title: title, icon: icon)
        return item
    }
    
    func settingsItem() -> MoreRootNavigationCellData {
        let layout = MoreRootNavigationCellLayout()
        let event = MoreRootViewModelSelectEvent.settings
        let title = String.localized.settings
        let image = UIImage.system(.arrowRight)
        let icon = MoreRootNavigationCellActionIcon.arrow(image)
        let item = MoreRootNavigationCellData(layout: layout, event: event, title: title, icon: icon)
        return item
    }
    
    func shareItem() -> MoreRootNavigationCellData {
        let layout = MoreRootNavigationCellLayout()
        let event = MoreRootViewModelSelectEvent.share
        let title = String.localized.moreAppSharing
        let image = UIImage.system(.share)
        let icon = MoreRootNavigationCellActionIcon.share(image)
        let item = MoreRootNavigationCellData(layout: layout, event: event, title: title, icon: icon)
        return item
    }
    
    func systemInfoItem() -> MoreRootSystemInfoCellData {
        let layout = MoreRootSystemInfoCellLayout()
        let title = String.localized.moreAppVersion + ": \(bundle.version)"
        let subtitle = String.localized.moreDevice + ": \(device.modelName)"
        let icon = UIImage.system(.copy)
        let item = MoreRootSystemInfoCellData(layout: layout, title: title, subtitle: subtitle, icon: icon)
        return item
    }
    
    func sizes() -> [CGSize] {
        let divider = screen.isLegacyPhone ? nil : 0.9
        let first = CGSize(width: screen.bounds.width - 40, height: 57.fitToSize(.width, with: divider))
        let last = CGSize(width: first.width, height: 87.fitToSize(.width, with: divider))
        var sizes = Array(repeating: first, count: 3)
        sizes.append(last)
        return sizes
    }
    
    func request(_ userInfo: AppUserInfo?) -> NetworkManagerRequest {
        let jwt = String(userInfo?.jsonWebToken)
        let path = URL.Server.supportContacts
        let headers = ["JWT" : jwt]
        let request = NetworkManagerRequest(type: .get, path: path, headers: .additional(headers), parameters: .empty)
        return request
    }
    
    func navigationBar(_ frame: CGRect) -> NavigationBarAppearance {
        let title = String.localized.menuMore
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.tintColor = .interfaceManager.white()
        let model = NavigationBarAppearanceModel(title: title, backBarButtonItem: backBarButtonItem)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.titleTextAttributes = [.font : UIFont.boldSystemFont(ofSize: 14.fitWidth), .foregroundColor : UIColor.interfaceManager.white()]
        navigationBarAppearance.backgroundImage = UIImage.interfaceManager.themeNavigationBar(frame: frame)
        navigationBarAppearance.backgroundImageContentMode = .scaleAspectFill
        navigationBarAppearance.shadowColor = .clear
        let appearance = NavigationBarAppearance(model: model, standard: navigationBarAppearance, compact: navigationBarAppearance, scrollEdge: navigationBarAppearance)
        return appearance
    }
    
    func systemInfo() -> String {
        "\(String.localized.moreApplication): " + "\"\(bundle.displayName)\", " + "\(String.localized.moreVersion.lowercased()): " + "\(bundle.version), " + "\(String.localized.moreDevice.lowercased()): " + "\(device.modelName), " + "\(device.systemName) " + device.systemVersion
    }
    
}

// MARK: - MoreRootDataSourceInternalEvent
enum MoreRootDataSourceInternalEvent {
    case view
    case request(AppUserInfo?)
    case navigationBar(CGRect)
    case systemInfo
}

// MARK: - MoreRootDataSourceExternalEvent
enum MoreRootDataSourceExternalEvent {
    case view(MoreRootViewData)
    case request(NetworkManagerRequest)
    case appearance(AppearanceTarget)
    case systemInfo(value: String, notify: AppUserNotificationType)
}
