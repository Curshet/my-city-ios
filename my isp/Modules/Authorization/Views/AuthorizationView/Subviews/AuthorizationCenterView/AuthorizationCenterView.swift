import UIKit
import Combine
import SnapKit

class AuthorizationCenterView: UIView, AuthorizationCenterViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationViewModelExternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AuthorizationViewModelSelectEvent, Never>
    
    private let telegramButton: AppButtonProtocol
    private let separatingLabel: UILabel
    private let phoneButton: AppButtonProtocol
    private let externalPublisher: PassthroughSubject<AuthorizationViewModelSelectEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(telegramButton: AppButtonProtocol, separatingLabel: UILabel, phoneButton: AppButtonProtocol) {
        self.telegramButton = telegramButton
        self.separatingLabel = separatingLabel
        self.phoneButton = phoneButton
        self.internalEventPublisher = PassthroughSubject<AuthorizationViewModelExternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AuthorizationViewModelSelectEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: .zero)
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension AuthorizationCenterView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        telegramButton.publisher.sink { [weak self] _ in
            self?.externalPublisher.send(.telegram)
        }.store(in: &subscriptions)
        
        phoneButton.publisher.sink { [weak self] _ in
            self?.externalPublisher.send(.phone)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        separatingLabel.textAlignment = .center
        separatingLabel.lineBreakMode = .byClipping
        addSubviews(telegramButton, separatingLabel, phoneButton)
    }
    
    func internalEventHandler(_ event: AuthorizationViewModelExternalEvent) {
        switch event {
            case .data(let value):
                setupConstraints(value.center)
                setupSubviews(value.center)
            
            case .animation(let state):
                state == .active ? telegramButton.startOverlay() : telegramButton.stopOverlay()
        }
    }
    
    func setupConstraints(_ data: AuthorizationCenterData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.top.equalTo(data.layout.topConstraint).offset(data.layout.constraints.top)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().inset(data.layout.size.width)
            $0.bottom.equalTo(phoneButton.snp.bottom)
        }
        
        telegramButton.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(data.layout.telegramButton.size.height)
        }
        
        separatingLabel.snp.makeConstraints {
            $0.top.equalTo(telegramButton.snp.bottom).offset(data.layout.separatingLabel.constraints.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        phoneButton.snp.makeConstraints {
            $0.top.equalTo(separatingLabel.snp.bottom).offset(data.layout.phoneButton.constraints.top)
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupSubviews(_ data: AuthorizationCenterData) {
        telegramButton.setImage(data.telegramIcon, for: .normal)
        telegramButton.setImage(data.telegramIcon, for: .highlighted)
        telegramButton.setImage(data.telegramIcon, for: .disabled)
        telegramButton.setTitle(data.telegramTitle, for: .normal)
        telegramButton.imageEdgeInsets = data.layout.telegramButton.imageEdgeInsets
        telegramButton.setTitleColor(data.layout.telegramButton.titleColor, for: .normal)
        telegramButton.titleLabel?.font = data.layout.telegramButton.titleFont
        telegramButton.backgroundColor = data.layout.telegramButton.backgroundColor
        telegramButton.layer.cornerRadius = data.layout.telegramButton.cornerRadius
        telegramButton.configureOverlay(data.layout.telegramButton.overlay)
        
        separatingLabel.text = data.separatingText
        separatingLabel.font = data.layout.separatingLabel.font
        separatingLabel.textColor = data.layout.separatingLabel.textColor
        
        phoneButton.setTitle(data.phoneTitle, for: .normal)
        phoneButton.setTitleColor(data.layout.phoneButton.titleColor, for: .normal)
        phoneButton.setTitleColor(data.layout.phoneButton.highlightedTitleColor, for: .highlighted)
        phoneButton.titleLabel?.font = data.layout.phoneButton.font
    }
    
}

// MARK: - AuthorizationCenterViewLayout
struct AuthorizationCenterViewLayout {
    let telegramButton: AuthorizationCenterTelegramButtonLayout
    let separatingLabel = AuthorizationCenterSeparatingLabelLayout()
    let phoneButton = AuthorizationCenterPhoneButtonLayout()
    let constraints = UIEdgeInsets(top: 100.fitHeight, left: 0, bottom: 0, right: 0)
    let size = CGSize(width: 25.fitWidth, height: 0)
    var topConstraint: ConstraintItem!
}

// MARK: - AuthorizationCenterTelegramButtonLayout
struct AuthorizationCenterTelegramButtonLayout {
    let overlay: AppOverlayViewLayout
    let size = CGSize(width: 0, height: 42.fitWidth)
    let imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    let titleColor = UIColor.interfaceManager.white()
    let titleFont = UIFont.systemFont(ofSize: 13.fitWidth)
    let backgroundColor = UIColor.interfaceManager.lightPurple()
    let cornerRadius = 10.fitWidth
}

// MARK: - AuthorizationCenterSeparatingLabelLayout
struct AuthorizationCenterSeparatingLabelLayout {
    let constraints = UIEdgeInsets(top: 40.fitWidth, left: 0, bottom: 0, right: 0)
    let font = UIFont.systemFont(ofSize: 13.fitWidth)
    let textColor = UIColor.interfaceManager.themeAuthorizationRootCenterSeparatingText()
}

// MARK: - AuthorizationCenterPhoneButtonLayout
struct AuthorizationCenterPhoneButtonLayout {
    let constraints = UIEdgeInsets(top: 35.fitWidth, left: 0, bottom: 0, right: 0)
    let titleColor = UIColor.interfaceManager.lightPurple()
    let highlightedTitleColor = UIColor.interfaceManager.themeAuthorizationRootCenterPhoneHighlitedTitle()
    let font = UIFont.systemFont(ofSize: 13.fitWidth)
}
