import UIKit
import Combine
import SnapKit

class AppPhoneCodeCenterView: UIView, AppPhoneCodeCenterViewProtocol {

    let internalEventPublisher: PassthroughSubject<AppPhoneCodeViewInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AppPhoneCodeViewExternalEvent, Never>
    
    private let stackView: AppPhoneCodeCenterStackViewProtocol
    private let repeatButton: AppButtonProtocol
    private let externalPublisher: PassthroughSubject<AppPhoneCodeViewExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(stackView: AppPhoneCodeCenterStackViewProtocol, repeatButton: AppButtonProtocol) {
        self.stackView = stackView
        self.repeatButton = repeatButton
        self.internalEventPublisher = PassthroughSubject<AppPhoneCodeViewInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AppPhoneCodeViewExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: .zero)
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func becomeFirstResponder() -> Bool {
        stackView.becomeFirstResponder()
    }
    
}

// MARK: Private
private extension AppPhoneCodeCenterView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        stackView.externalEventPublisher.sink { [weak self] in
            self?.externalPublisher.send($0)
        }.store(in: &subscriptions)
        
        repeatButton.publisher.sink { [weak self] _ in
            self?.stackView.internalEventPublisher.send(.clear)
            self?.externalPublisher.send(.repeаt)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        repeatButton.titleLabel?.textAlignment = .center
        repeatButton.isEnabled = false
        addSubviews(stackView, repeatButton)
    }
    
    func internalEventHandler(_ event: AppPhoneCodeViewInternalEvent) {
        switch event {
            case .data(let value):
                setupConstraints(value.alert.center)
                setupSubviews(value.alert.center)
            
            case .timer(let value):
                setupLayout(value)
            
            case .animation(let state):
                state == .active ? repeatButton.startOverlay() : repeatButton.stopOverlay()
            
            case .keyboard:
                stackView.becomeFirstResponder()
            
            case .reset:
                stackView.internalEventPublisher.send(.reset)
                repeatButton.stopOverlay()
        }
    }
    
    func setupLayout(_ value: AppPhoneCodeCenterRepeat) {
        repeatButton.setTitle(value.title, for: .normal)
        repeatButton.setTitleColor(value.layout.titleColor, for: .normal)
        repeatButton.titleLabel?.interlineSpacing(value.layout.interlineSpacing)
        repeatButton.backgroundColor = value.layout.backgroundColor
        repeatButton.isEnabled = value.isEnabled
        repeatButton.configureOverlay(value.layout.overlay)
    }
    
    func setupConstraints(_ data: AppPhoneCodeCenterData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.top.equalTo(data.layout.topConstraint).offset(data.layout.constraints.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(repeatButton.snp.bottom).offset(data.layout.constraints.bottom)
        }
        
        repeatButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(data.layout.repeatButton.constraints.top)
            $0.leading.equalToSuperview().inset(data.layout.repeatButton.constraints.left)
            $0.trailing.equalToSuperview().inset(data.layout.repeatButton.constraints.right)
            $0.height.equalTo(data.layout.repeatButton.size.height)
        }
    }
    
    func setupSubviews(_ data: AppPhoneCodeCenterData) {
        stackView.internalEventPublisher.send(data.stack)
        repeatButton.titleLabel?.numberOfLines = data.layout.repeatButton.numberOfLines
        repeatButton.titleLabel?.font = data.layout.repeatButton.font
        repeatButton.layer.cornerRadius = data.layout.repeatButton.cornerRadius
    }
    
}

// MARK: - AppPhoneCodeCenterViewLayout
struct AppPhoneCodeCenterViewLayout {
    let repeatButton: AppPhoneCodeCenterRepeatButtonLayout
    var constraints = UIEdgeInsets(top: 25.fitWidth, left: 0, bottom: 28.fitWidth, right: 0)
    var topConstraint: ConstraintItem!
}

// MARK: - AppPhoneCodeCenterRepeatButtonLayout
struct AppPhoneCodeCenterRepeatButtonLayout {
    let overlay: AppOverlayViewLayout
    let titleColor: UIColor
    let backgroundColor: UIColor
    var constraints = UIEdgeInsets(top: 25.fitWidth, left: 25, bottom: 0, right: 25)
    var size = CGSize(width: 0, height: 38.fitWidth)
    var numberOfLines = 2
    var interlineSpacing = 9.0
    var font = UIFont.systemFont(ofSize: 13.fitWidth)
    var cornerRadius = 9.fitWidth
}
