import UIKit
import Combine

class ChatRootDataSource: ChatRootDataSourceProtocol {
    
    let internalEventPublisher: PassthroughSubject<ChatDataSourceInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<ChatDataSourceExternalEvent, Never>
    
    private let bundle: BundleProtocol
    private let device: DeviceProtocol
    private let externalPublisher: PassthroughSubject<ChatDataSourceExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(bundle: BundleProtocol, device: DeviceProtocol) {
        self.bundle = bundle
        self.device = device
        self.internalEventPublisher = PassthroughSubject<ChatDataSourceInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<ChatDataSourceExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }

}

// MARK: Private
private extension ChatRootDataSource {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: ChatDataSourceInternalEvent) {
        switch event {
            case .view(let safeArea, let localization):
                let value = view(safeArea, localization)
                externalPublisher.send(.view(value))
            
            case .layout:
                let value = layout(nil)
                externalPublisher.send(.layout(value))
            
            case .navigationBar(let frame):
                let value = navigationBar(frame)
                externalPublisher.send(.appearance(value))
            
            case .notify:
                let message = String.localized.chatLoadingError
                externalPublisher.send(.notify(.error(message)))
        }
    }
    
    func view(_ safeArea: UILayoutGuide?, _ localization: LocalizationManagerLanguage) -> ChatRootViewData {
        let layout = layout(safeArea)
        let request = request(localization)
        let script = script(localization)
        let webview = ChatRootWebViewData(request: request, script: script)
        let data = ChatRootViewData(layout: layout, webview: webview)
        return data
    }
    
    func layout(_ safeArea: UILayoutGuide?) -> ChatRootViewLayout {
        let bottom = device.isUsingFaceID ? 30.0 : 15.0
        let constraints = UIEdgeInsets(top: 0, left: 10, bottom: bottom, right: 14)
        let webview = ChatRootWebViewLayout(safeArea: safeArea, constraints: constraints)
        let layout = ChatRootViewLayout(webview: webview)
        return layout
    }

    func request(_ localization: LocalizationManagerLanguage) -> URLRequest? {
        let localized = localization == .russian ? "index_ru" : "index_en"
        guard let url = bundle.url(forResource: localized, withExtension: "html", subdirectory: "JivoChat") else { return nil }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        return request
    }
    
    func script(_ localization: LocalizationManagerLanguage) -> String {
        let localized = localization == .russian ? "'ru'" : "'en'"
        let script = "window.setData(\(localized), true)"
        return script
    }
    
    func navigationBar(_ frame: CGRect) -> NavigationBarAppearance {
        let title = String.localized.menuChat
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

// MARK: - ChatDataSourceInternalEvent
enum ChatDataSourceInternalEvent {
    case view(safeArea: UILayoutGuide?, localization: LocalizationManagerLanguage)
    case layout
    case navigationBar(CGRect)
    case notify
}

// MARK: - ChatDataSourceExternalEvent
enum ChatDataSourceExternalEvent {
    case view(ChatRootViewData)
    case layout(ChatRootViewLayout)
    case appearance(NavigationBarAppearance)
    case notify(AppUserNotificationType)
}
