import UIKit
import Combine
import SnapKit

class AuthorizationPhoneRootCenterView: UIView, AuthorizationPhoneRootCenterViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootViewModelExternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AuthorizationPhoneRootViewModelSelectEvent, Never>
    
    private let textView: AuthorizationPhoneRootCenterTextViewProtocol
    private let enterButton: AppButtonProtocol
    private let returnButton: AppButtonProtocol
    private let externalPublisher: PassthroughSubject<AuthorizationPhoneRootViewModelSelectEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(textView: AuthorizationPhoneRootCenterTextViewProtocol, enterButton: AppButtonProtocol, returnButton: AppButtonProtocol) {
        self.textView = textView
        self.enterButton = enterButton
        self.returnButton = returnButton
        self.internalEventPublisher = PassthroughSubject<AuthorizationPhoneRootViewModelExternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AuthorizationPhoneRootViewModelSelectEvent, Never>()
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
private extension AuthorizationPhoneRootCenterView {
    
    func startConfiguration() {
        setupObservers()
        addSubviews(textView, enterButton, returnButton)
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        textView.externalEventPublisher.sink { [weak self] in
            self?.externalPublisher.send(.activity($0))
        }.store(in: &subscriptions)
        
        enterButton.publisher.sink { [weak self] _ in
            self?.externalPublisher.send(.enter(self?.textView.text))
        }.store(in: &subscriptions)
        
        returnButton.publisher.sink { [weak self] _ in
            self?.externalPublisher.send(.rеturn)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AuthorizationPhoneRootViewModelExternalEvent) {
        switch event {
            case .data(let value):
                setupConstraints(value.center)
                setupSubviews(value.center)
                fallthrough
            
            case .textField:
                textView.internalEventPublisher.send(event)
            
            case .animation(let state):
                state == .active ? enterButton.startOverlay() : enterButton.stopOverlay()
        }
    }
    
    func setupConstraints(_ data: AuthorizationPhoneRootCenterData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.top.equalTo(data.layout.topConstraint).offset(data.layout.constraints.top)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().inset(data.layout.size.width)
            $0.bottom.equalTo(returnButton.snp.bottom)
        }

        enterButton.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(data.layout.enterButton.constraints.top)
            $0.leading.equalToSuperview().inset(data.layout.enterButton.constraints.left)
            $0.trailing.equalToSuperview().inset(data.layout.enterButton.constraints.right)
            $0.height.equalTo(data.layout.enterButton.size.height)
        }
        
        returnButton.snp.makeConstraints {
            $0.top.equalTo(enterButton.snp.bottom).offset(data.layout.returnButton.constraints.top)
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupSubviews(_ data: AuthorizationPhoneRootCenterData) {
        enterButton.setTitle(data.enterTitle, for: .normal)
        enterButton.setTitleColor(data.layout.enterButton.titleColor, for: .normal)
        enterButton.titleLabel?.font = data.layout.enterButton.font
        enterButton.backgroundColor = data.layout.enterButton.backgroundColor
        enterButton.layer.cornerRadius = data.layout.enterButton.cornerRadius
        enterButton.configureOverlay(data.layout.enterButton.overlay)
        
        returnButton.setTitle(data.returnTitle, for: .normal)
        returnButton.setTitleColor(data.layout.returnButton.titleColor, for: .normal)
        returnButton.setTitleColor(data.layout.returnButton.titleColor, for: .highlighted)
        returnButton.titleLabel?.font = data.layout.returnButton.font
        returnButton.configureTransform(.setup(.touchesBegan(data.layout.returnButton.touchesBegan)))
    }
    
}

// MARK: - AuthorizationPhoneRootCenterViewLayout
struct AuthorizationPhoneRootCenterViewLayout {
    let enterButton: AuthorizationPhoneRootCenterEnterButtonLayout
    let returnButton = AuthorizationPhoneRootCenterReturnButtonLayout()
    let constraints = UIEdgeInsets(top: 45.fitWidth, left: 0, bottom: 0, right: 0)
    let size = CGSize(width: 20, height: 0)
    var topConstraint: ConstraintItem!
}

// MARK: - AuthorizationPhoneRootCenterEnterButtonLayout
struct AuthorizationPhoneRootCenterEnterButtonLayout {
    let overlay: AppOverlayViewLayout
    let constraints = UIEdgeInsets(top: 24.fitWidth, left: 10, bottom: 0, right: 10)
    let size = CGSize(width: 0, height: 42.fitWidth)
    let titleColor = UIColor.interfaceManager.white()
    let font = UIFont.systemFont(ofSize: 13.fitWidth)
    let backgroundColor = UIColor.interfaceManager.lightPurple()
    let cornerRadius = 10.fitWidth
}

// MARK: - AuthorizationPhoneRootCenterReturnButtonLayout
struct AuthorizationPhoneRootCenterReturnButtonLayout {
    let constraints = UIEdgeInsets(top: 19.fitWidth, left: 0, bottom: 0, right: 0)
    let titleColor = UIColor.interfaceManager.lightPurple()
    let font = UIFont.systemFont(ofSize: 13.fitWidth)
    let touchesBegan = AppViewAnimation(duration: 0.2, color: nil, transform: .init(scaleX: 1.02, y: 1.02))
}
