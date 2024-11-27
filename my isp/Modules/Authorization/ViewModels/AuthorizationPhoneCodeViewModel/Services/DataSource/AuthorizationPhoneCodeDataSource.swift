import UIKit
import Combine

class AuthorizationPhoneCodeDataSource: AuthorizationPhoneCodeDataSourceProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationPhoneCodeDataSourceInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AuthorizationPhoneCodeDataSourceExternalEvent, Never>
    
    private let externalPublisher: PassthroughSubject<AuthorizationPhoneCodeDataSourceExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init() {
        self.internalEventPublisher = PassthroughSubject<AuthorizationPhoneCodeDataSourceInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AuthorizationPhoneCodeDataSourceExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension AuthorizationPhoneCodeDataSource {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AuthorizationPhoneCodeDataSourceInternalEvent) {
        switch event {
            case .view:
                let data = data()
                externalPublisher.send(.view(data))
            
            case .timer(let seconds):
                let title = .localized.phoneCodeRepeat + "\n\(String.create(seconds: seconds))"
                let data = repeаt(timer: true, title)
                externalPublisher.send(.timer(data))
            
            case .repeаt:
                let title = String.localized.phoneCodeSend
                let data = repeаt(timer: false, title)
                externalPublisher.send(.timer(data))
            
            case .request(let phone, let code):
                let request = request(phone, code)
                externalPublisher.send(.request(request))
            
            case .notify(let type):
                let notify = notify(type)
                externalPublisher.send(.notify(notify))
        }
    }
    
    func data() -> AppPhoneCodeViewData {
        let effect = UIBlurEffect.interfaceManager.themeUltraThinMaterialBlur()
        let color = UIColor.interfaceManager.themePhoneCodeEffectBackground()
        let background = AppModalViewBackground(effect: effect, backgroundColor: color)
        let layout = AppPhoneCodeAlertViewLayout()
        let header = headerSection()
        let center = centerSection()
        let alert = AppPhoneCodeAlertViewData(layout: layout, header: header, center: center)
        let data = AppPhoneCodeViewData(background: background, alert: alert)
        return data
    }
    
    func headerSection() -> AppPhoneCodeHeaderData {
        let titleLabel = AppPhoneCodeHeaderTitleLabelLayout()
        let subtitleLabel = AppPhoneCodeHeaderSubtitleLabelLayout()
        let layout = AppPhoneCodeHeaderViewLayout(titleLabel: titleLabel, subtitleLabel: subtitleLabel)
        let title = String.localized.phoneCodeCheck
        let subtitle = String.localized.phoneCodeEnter
        let image = UIImage.system(.xmark, configuration: layout.exitButton.imageConfiguration)
        let data = AppPhoneCodeHeaderData(layout: layout, title: title, subtitle: subtitle, image: image)
        return data
    }
    
    func centerSection() -> AppPhoneCodeCenterData {
        let layout = centerLayout(timer: true)
        let stack = centerStackView()
        let center = AppPhoneCodeCenterData(layout: layout, stack: stack)
        return center
    }
    
    func centerLayout(timer: Bool) -> AppPhoneCodeCenterViewLayout {
        let titleColor = timer ? UIColor.interfaceManager.lightGray() : UIColor.interfaceManager.white()
        let backgroundColor = timer ? UIColor.clear : .interfaceManager.lightPurple()
        let activitySize = CGSize(width: 40, height: 40)
        let activityIndicator = AppOverlayActivityIndicatorLayout(type: .medium, backgroundColor: .clear, color: titleColor, size: activitySize, cornerRadius: .zero)
        let overlay = AppOverlayViewLayout(activityIndicator: activityIndicator, effect: nil, backgroundColor: backgroundColor, cornerRadius: 9.fitWidth, startDelay: .zero, stopDelay: .zero)
        let repeatButton = AppPhoneCodeCenterRepeatButtonLayout(overlay: overlay, titleColor: titleColor, backgroundColor: backgroundColor)
        let layout = AppPhoneCodeCenterViewLayout(repeatButton: repeatButton)
        return layout
    }
    
    func centerStackView() -> AppPhoneCodeCenterStackViewInternalEvent {
        let layout = AppPhoneCodeCenterStackViewLayout()
        let label = centerLabel()
        let data = AppPhoneCodeCenterStackData(layout: layout, target: .four, label: label)
        let event = AppPhoneCodeCenterStackViewInternalEvent.data(data)
        return event
    }
    
    func centerLabel() -> AppPhoneCodeCenterLabelInternalEvent {
        let layout = AppPhoneCodeCenterLabelLayout()
        let symbolColor = UIColor.interfaceManager.lightGray()
        let textColor = UIColor.interfaceManager.themeText()
        let style = AppPhoneCodeCenterLabelStyle(symbol: "·", symbolColor: symbolColor, textColor: textColor)
        let data = AppPhoneCodeCenterLabelData(layout: layout, style: style)
        let event = AppPhoneCodeCenterLabelInternalEvent.data(data)
        return event
    }
    
    func repeаt(timer: Bool, _ title: String) -> AppPhoneCodeCenterRepeat {
        let layout = centerLayout(timer: timer)
        let value = AppPhoneCodeCenterRepeat(layout: layout.repeatButton, title: title, isEnabled: !timer)
        return value
    }
    
    func request(_ number: String?, _ code: String) -> NetworkManagerRequest {
        let phone = String(number)
        let path = URL.Server.phoneCodeAuthorization
        let parameters = ["phone" : phone, "code" : code]
        let request = NetworkManagerRequest(type: .post, path: path, headers: .required, parameters: .value(parameters))
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

// MARK: - AuthorizationPhoneCodeDataSourceInternalEvent
enum AuthorizationPhoneCodeDataSourceInternalEvent {
    case view
    case timer(Double)
    case repeаt
    case request(phone: String?, code: String)
    case notify(NetworkManagerErrorType)
}

// MARK: - AuthorizationPhoneCodeDataSourceExternalEvent
enum AuthorizationPhoneCodeDataSourceExternalEvent {
    case view(AppPhoneCodeViewData)
    case timer(AppPhoneCodeCenterRepeat)
    case request(NetworkManagerRequest)
    case notify(AppUserNotificationType)
}
