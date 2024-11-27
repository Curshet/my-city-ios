import UIKit
import Combine

class MoreSupportDataSource: MoreSupportDataSourceProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreSupportDataSourceInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MoreSupportDataSourceExternalEvent, Never>
    
    private let device: DeviceProtocol
    private let screen: ScreenProtocol
    private let externalPublisher: PassthroughSubject<MoreSupportDataSourceExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(device: DeviceProtocol, screen: ScreenProtocol) {
        self.device = device
        self.screen = screen
        self.internalEventPublisher = PassthroughSubject<MoreSupportDataSourceInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MoreSupportDataSourceExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension MoreSupportDataSource {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MoreSupportDataSourceInternalEvent) {
        switch event {
            case .view(let phone):
                let value = view(phone)
                externalPublisher.send(.view(value))
            
            case .navigationBar(let frame):
                let value = navigationBar(frame)
                externalPublisher.send(.appearance(.navigationBar(value)))
            
            case .path(let target, let contacts):
                let value = path(target, contacts)
                externalPublisher.send(.path(value))
        }
    }
    
    func view(_ phone: String?) -> MoreSupportViewData {
        let layout = MoreSupportViewLayout()
        let phoneItеm = phoneItem(phone ?? .clear)
        let messengersItem = messengersItem()
        let items: [Any] = [phoneItеm, messengersItem]
        let data = MoreSupportViewData(layout: layout, items: items)
        return data
    }
    
    func phoneItem(_ phone: String) -> MoreSupportPhoneCellData {
        let size = CGSize(width: screen.bounds.width - 40, height: 0)
        let layout = MoreSupportPhoneCellLayout(size: size)
        let title = String.localized.morePhoneQuestion
        let icon = UIImage.system(.phone)
        let phone = phone.isEmpty() ? "+7 978 899-00-00" : phone.phoneMask(withCode: true)
        let item = MoreSupportPhoneCellData(layout: layout, title: title, phone: phone, icon: icon)
        return item
    }
    
    func messengersItem() -> MoreSupportMessengersCellData {
        let size = CGSize(width: screen.bounds.width - 40, height: 0)
        let layout = MoreSupportMessengersCellLayout(size: size)
        let title = String.localized.moreMessengersQuestion
        let telegram = UIImage.moreSupportTelegram
        let whatsApp = UIImage.moreSupportWhatsApp
        let viber = UIImage.moreSupportViber
        let icons: [MoreSupportMessengerIcon] = [.telegram(telegram), .whatsApp(whatsApp), .viber(viber)]
        let item = MoreSupportMessengersCellData(layout: layout, title: title, icons: icons)
        return item
    }
    
    func navigationBar(_ frame: CGRect) -> NavigationBarAppearance {
        let title = String.localized.moreSupport
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
    
    func path(_ type: MoreSupportViewModelSelectEvent, _ contacts: MoreSupportContacts?) -> String {
        switch type {
            case .phone:
                let path = URL.System.tel
                let defaultNumber = path + "+79788990000"
                guard let phone = contacts?.tel, !phone.isEmpty() else { return defaultNumber }
                return path + phone
            
            case .telegram:
                let defaultURL = URL.Service.telegramSupport
                guard let telegram = contacts?.telegram, !telegram.isEmpty() else { return defaultURL }
                return telegram
            
            case .whatsApp:
                let defaultURL = URL.Service.whatsAppSupport
                guard let whatsApp = contacts?.whatsApp, !whatsApp.isEmpty() else { return defaultURL }
                return whatsApp
            
            case .viber:
                let defaultURL = URL.Service.viberSupport
                guard let viber = contacts?.viber, !viber.isEmpty() else { return defaultURL }
                return viber
        }
    }
    
}

// MARK: - MoreSupportDataSourceInternalEvent
enum MoreSupportDataSourceInternalEvent {
    case view(String?)
    case navigationBar(CGRect)
    case path(type: MoreSupportViewModelSelectEvent, contacts: MoreSupportContacts?)
}

// MARK: - MoreSupportDataSourceExternalEvent
enum MoreSupportDataSourceExternalEvent {
    case view(MoreSupportViewData)
    case appearance(AppearanceTarget)
    case path(String)
}
