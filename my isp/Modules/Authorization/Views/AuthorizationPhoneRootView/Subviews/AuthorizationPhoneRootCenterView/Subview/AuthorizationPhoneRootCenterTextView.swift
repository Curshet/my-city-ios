import UIKit
import Combine
import SnapKit

class AuthorizationPhoneRootCenterTextView: UIView, AuthorizationPhoneRootCenterTextViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootViewModelExternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AuthorizationPhoneRootViewModelActivity, Never>
    
    var text: String? {
        textField.text
    }
    
    private let countryLabel: UILabel
    private let textField: AuthorizationPhoneRootCenterTextFieldProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(countryLabel: UILabel, textField: AuthorizationPhoneRootCenterTextFieldProtocol, messageLabel: UILabel) {
        self.countryLabel = countryLabel
        self.textField = textField
        self.internalEventPublisher = PassthroughSubject<AuthorizationPhoneRootViewModelExternalEvent, Never>()
        self.externalEventPublisher = textField.externalEventPublisher
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: .zero)
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension AuthorizationPhoneRootCenterTextView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        countryLabel.clipsToBounds = true
        countryLabel.textAlignment = .center
        addSubviews(countryLabel, textField)
    }
    
    func internalEventHandler(_ event: AuthorizationPhoneRootViewModelExternalEvent) {
        switch event {
            case .data(var value):
                setupConstraints(value.center.textView)
                setupSubviews(&value.center.textView)
        
            case .textField(let value):
                textField.layer.borderColor = value.borderColor
            
            default:
                break
        }
    }
    
    func setupConstraints(_ data: AuthorizationPhoneRootCenterTextViewData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(countryLabel.snp.bottom)
        }
        
        countryLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(data.layout.countryLabel.constraints.left)
            $0.width.equalTo(data.layout.countryLabel.size.width)
            $0.height.equalTo(data.layout.countryLabel.size.height)
        }
    }
    
    func setupSubviews(_ data: inout AuthorizationPhoneRootCenterTextViewData) {
        countryLabel.text = data.country
        countryLabel.font = data.layout.countryLabel.font
        countryLabel.textColor = data.layout.countryLabel.textColor
        countryLabel.backgroundColor = data.layout.countryLabel.backgroundColor
        countryLabel.layer.cornerRadius = data.layout.countryLabel.cornerRadius
        data.textField.layout.leadingConstraint = countryLabel.snp.trailing
        textField.internalEventPublisher.send(data.textField)
    }
    
}

// MARK: - AuthorizationPhoneRootCenterTextViewLayout
struct AuthorizationPhoneRootCenterTextViewLayout {
    let countryLabel = AuthorizationPhoneRootCenterTextCountryLabelLayout()
}

// MARK: - AuthorizationPhoneRootCenterTextCountryLabelLayout
struct AuthorizationPhoneRootCenterTextCountryLabelLayout {
    let constraints = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    let size = CGSize(width: 60.fitWidth, height: 38.fitWidth)
    let font = UIFont.systemFont(ofSize: 13.fitWidth)
    let textColor = UIColor.interfaceManager.themeText()
    let backgroundColor = UIColor.interfaceManager.lightGray(alpha: 0.2)
    let cornerRadius = 10.fitWidth
}
