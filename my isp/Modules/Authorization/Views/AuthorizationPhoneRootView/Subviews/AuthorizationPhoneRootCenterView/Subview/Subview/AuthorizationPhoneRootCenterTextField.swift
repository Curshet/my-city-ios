import UIKit
import Combine
import SnapKit

class AuthorizationPhoneRootCenterTextField: AppTextField, AuthorizationPhoneRootCenterTextFieldProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootCenterTextFieldData, Never>
    let externalEventPublisher: AnyPublisher<AuthorizationPhoneRootViewModelActivity, Never>
    
    private weak var actionView: AuthorizationPhoneRootCenterTextRightViewProtocol?
    private let customDelegate: AuthorizationPhoneRootCenterTextFieldDelegateProtocol
    private let externalPublisher: PassthroughSubject<AuthorizationPhoneRootViewModelActivity, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(rightView: AuthorizationPhoneRootCenterTextRightViewProtocol, delegate: AuthorizationPhoneRootCenterTextFieldDelegateProtocol, actionTarget: ActionTargetControlProtocol) {
        self.actionView = rightView
        self.customDelegate = delegate
        self.internalEventPublisher = PassthroughSubject<AuthorizationPhoneRootCenterTextFieldData, Never>()
        self.externalPublisher = PassthroughSubject<AuthorizationPhoneRootViewModelActivity, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher.merge(with: customDelegate.externalEventPublisher))
        self.subscriptions = Set<AnyCancellable>()
        super.init(delegate: delegate, actionTarget: actionTarget, frame: .zero)
        self.delegate = customDelegate
        self.rightView = actionView
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension AuthorizationPhoneRootCenterTextField {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        publisher.sink { [weak self] in
            guard case let .control(event) = $0, event == .editingChanged else { return }
            self?.text?.removeAll()
        }.store(in: &subscriptions)
        
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        actionView?.externalEventPublisher.sink { [weak self] in
            guard let self, text != .clear else { return }
            text?.removeAll()
            externalPublisher.send(.input(text))
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        textAlignment = .left
        rightViewMode = .whileEditing
        keyboardType = .numberPad
        addTarget(.editingChanged)
    }
    
    func internalEventHandler(_ event: AuthorizationPhoneRootCenterTextFieldData) {
        setupLayout(event)
        setupConstraints(event)
        actionView?.internalEventPublisher.send(event.rightView)
        externalPublisher.send(.input(text))
    }
    
    func setupLayout(_ data: AuthorizationPhoneRootCenterTextFieldData) {
        placeholder = data.placeholder
        placeholderColor(data.layout.placeholderColor)
        font = data.layout.font
        textColor = data.layout.textColor
        tintColor = data.layout.tintColor
        padding(data.layout.leftPadding)
        layer.cornerRadius = data.layout.cornerRadius
        layer.borderWidth = data.layout.borderWidth
        layer.borderColor = data.layout.borderColor
    }
    
    func setupConstraints(_ data: AuthorizationPhoneRootCenterTextFieldData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.top.height.equalToSuperview()
            $0.leading.equalTo(data.layout.leadingConstraint).offset(data.layout.constraints.left)
            $0.trailing.equalToSuperview().inset(data.layout.constraints.right)
        }
    }
    
}

// MARK: - AuthorizationPhoneRootCenterTextFieldLayout
struct AuthorizationPhoneRootCenterTextFieldLayout {
    let constraints = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 11)
    let size = CGSize(width: 0, height: 38.fitWidth)
    let placeholderColor = UIColor.interfaceManager.themeAuthorizationPhoneCenterPlaceholder().withAlphaComponent(0.38)
    let font = UIFont.systemFont(ofSize: 14.5.fitWidth)
    let textColor = UIColor.interfaceManager.themeText()
    let tintColor = UIColor.interfaceManager.lightPurple()
    let enterColor = UIColor.interfaceManager.lightPurple().cgColor
    let messageColor = UIColor.interfaceManager.red().cgColor
    let leftPadding = UITextFieldSide.left(14.fitWidth)
    let cornerRadius = 9.fitWidth
    let borderWidth = 0.85
    let borderColor = UIColor.interfaceManager.themeAuthorizationPhoneCenterTextFieldBorder().withAlphaComponent(0.75).cgColor
    var leadingConstraint: ConstraintItem!
}
