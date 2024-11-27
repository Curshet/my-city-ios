import UIKit
import Combine

class AuthorizationPhoneRootDataSource: AuthorizationPhoneRootDataSourceProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootDataSourceInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AuthorizationPhoneRootDataSourceExternalEvent, Never>
    
    private let externalPublisher: PassthroughSubject<AuthorizationPhoneRootDataSourceExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init() {
        self.internalEventPublisher = PassthroughSubject<AuthorizationPhoneRootDataSourceInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AuthorizationPhoneRootDataSourceExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }

}

// MARK: Private
private extension AuthorizationPhoneRootDataSource {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AuthorizationPhoneRootDataSourceInternalEvent) {
        switch event {
            case .view:
                let data = data()
                externalPublisher.send(.view(data))
            
            case .navigationBarAppearance(let frame):
                let appearance = navigationBarAppearance(frame)
                externalPublisher.send(.navigationBarAppearance(appearance))
            
            case .enter(let text, let phone):
                let state = state(enter: true, text)
                let request = request(text, phone, triggerred: false)
                externalPublisher.send(.textField(state))
                externalPublisher.send(.notify(state.notify))
                externalPublisher.send(.request(request))
            
            case .input(let text):
                let state = state(enter: false, text)
                externalPublisher.send(.textField(state))
            
            case .paste:
                let message = String.localized.authorizationPhoneManual
                let notify = AppUserNotificationType.message(message)
                externalPublisher.send(.notify(notify))
            
            case .trigger(var phone):
                phone?.removeFirst()
                let text = phone?.phoneMask(withCode: false)
                let request = request(text, nil, triggerred: true)
                externalPublisher.send(.request(request))
            
            case .notify(let type):
                let notify = notify(type)
                externalPublisher.send(.notify(notify))
        }
    }
    
    func data() -> AuthorizationPhoneRootViewData {
        let layout = AuthorizationPhoneRootViewLayout()
        let header = headerSection()
        let center = centerSection()
        let data = AuthorizationPhoneRootViewData(layout: layout, header: header, center: center)
        return data
    }
    
    func headerSection() -> AuthorizationPhoneRootHeaderData {
        let layout = AuthorizationPhoneRootHeaderViewLayout()
        let title = String.localized.authorizationPhoneInput
        let subtitle = "\(String.localized.authorizationPhoneEntry)."
        let data = AuthorizationPhoneRootHeaderData(layout: layout, title: title, subtitle: subtitle)
        return data
    }
    
    func centerSection() -> AuthorizationPhoneRootCenterData {
        let layout = centerLayout()
        let textView = centerTextView()
        let enterTitle = String.localized.enter
        let returnTitle = String.localized.goBack
        let data = AuthorizationPhoneRootCenterData(layout: layout, textView: textView, enterTitle: enterTitle, returnTitle: returnTitle)
        return data
    }
    
    func centerLayout() -> AuthorizationPhoneRootCenterViewLayout {
        let activitySize = CGSize(width: 40, height: 40)
        let activityColor = UIColor.interfaceManager.white()
        let activityIndicator = AppOverlayActivityIndicatorLayout(type: .medium, backgroundColor: .clear, color: activityColor, size: activitySize, cornerRadius: .zero)
        let overlay = AppOverlayViewLayout(activityIndicator: activityIndicator, effect: nil, backgroundColor: .clear, cornerRadius: .zero, startDelay: .zero, stopDelay: .zero)
        let enterButton = AuthorizationPhoneRootCenterEnterButtonLayout(overlay: overlay)
        let layout = AuthorizationPhoneRootCenterViewLayout(enterButton: enterButton)
        return layout
    }
    
    func centerTextView() -> AuthorizationPhoneRootCenterTextViewData {
        let layout = AuthorizationPhoneRootCenterTextViewLayout()
        let textField = centerTextField()
        let data = AuthorizationPhoneRootCenterTextViewData(layout: layout, country: "🇷🇺 +7", textField: textField)
        return data
    }
    
    func centerTextField() -> AuthorizationPhoneRootCenterTextFieldData {
        let layout = AuthorizationPhoneRootCenterTextFieldLayout()
        let rightViewLayout = AuthorizationPhoneRootCenterTextRightViewLayout()
        let rightViewImage = UIImage.system(.xmarkFill)
        let rightView = AuthorizationPhoneRootCenterTextRightViewData(layout: rightViewLayout, image: rightViewImage)
        let data = AuthorizationPhoneRootCenterTextFieldData(layout: layout, placeholder: "000 000-00-00", rightView: rightView)
        return data
    }
    
    func navigationBarAppearance(_ frame: CGRect?) -> NavigationBarAppearance {
        let title = String.localized.entry
        let model = NavigationBarAppearanceModel(title: title)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.titleTextAttributes = [.font :  UIFont.boldSystemFont(ofSize: 14.fitWidth), .foregroundColor : UIColor.interfaceManager.white()]
        navigationBarAppearance.backgroundImage = UIImage.interfaceManager.themeNavigationBar(frame: frame ?? .zero)
        navigationBarAppearance.backgroundImageContentMode = .scaleAspectFill
        navigationBarAppearance.shadowColor = .clear
        let appearance = NavigationBarAppearance(model: model, standard: navigationBarAppearance, compact: navigationBarAppearance, scrollEdge: navigationBarAppearance)
        return appearance
    }
    
    func state(enter: Bool, _ text: String?) -> AuthorizationPhoneRootCenterTextFieldState {
        let layout = AuthorizationPhoneRootCenterTextFieldLayout()
        let count = text?.count ?? .zero
        let inputColor = count == 13 ? layout.enterColor : layout.borderColor
        let enterColor = count == 13 ? layout.enterColor : layout.messageColor
        let borderColor = enter ? enterColor : inputColor
        let message = count == 13 ? .clear : (count == .zero ? String.localized.authorizationPhoneEmpty : String.localized.authorizationPhoneIncorrect)
        let notify: AppUserNotificationType? = message.isEmpty() ? nil : .error(message)
        let state = AuthorizationPhoneRootCenterTextFieldState(borderColor: borderColor, notify: notify)
        return state
    }
    
    func request(_ text: String?, _ number: String?, triggerred: Bool) -> AuthorizationPhoneRootNetworkRequest? {
        guard let text, text.count == 13 else { return nil }
        
        let firstPаth = URL.Server.firstAuthorization
        let firstRequest = NetworkManagerRequest(type: .get, path: firstPаth, headers: .required, parameters: .empty)
        let phone = "7" + text.removeSymbols(" ", "-")
        let phonePath = URL.Server.phoneAuthorization
        let phoneParameters = ["phone" : phone]
        let phoneRequest = NetworkManagerRequest(type: .post, path: phonePath, headers: .required, parameters: .value(phoneParameters))
        let output = AuthorizationPhoneRootResponseData(phone: phone, timeInterval: 180, triggerred: triggerred)
        let request = AuthorizationPhoneRootNetworkRequest(unique: phone != number, triggerred: triggerred, getFirst: firstRequest, postPhone: phoneRequest, output: output)
        return request
    }
    
    func notify(_ type: NetworkManagerErrorType) -> AppUserNotificationType {
        switch type {
            case .request(let error):
                let description = error.localizedDescription.isEmpty() ? String.localized.authorizationError : error.localizedDescription
                let message = description + " (\(error.code))"
                return .error(message)
                
            case .system:
                let message = String.localized.authorizationError + " (\(NSError.system.code))"
                return .error(message)
        }
    }
    
}

// MARK: - AuthorizationPhoneRootDataSourceInternalEvent
enum AuthorizationPhoneRootDataSourceInternalEvent {
    case view
    case navigationBarAppearance(CGRect)
    case enter(text: String?, phone: String?)
    case input(String?)
    case paste
    case trigger(String?)
    case notify(NetworkManagerErrorType)
}

// MARK: - AuthorizationPhoneRootDataSourceExternalEvent
enum AuthorizationPhoneRootDataSourceExternalEvent {
    case view(AuthorizationPhoneRootViewData)
    case navigationBarAppearance(NavigationBarAppearance)
    case textField(AuthorizationPhoneRootCenterTextFieldState)
    case request(AuthorizationPhoneRootNetworkRequest?)
    case notify(AppUserNotificationType?)
}
