import UIKit
import Combine

class AppPhoneCodeCenterTextField: AppTextField, AppPhoneCodeCenterTextFieldProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppPhoneCodeCenterTextFieldInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AppPhoneCodeCenterTextFieldExternalEvent, Never>
    
    private let customDelegate: AppPhoneCodeCenterTextFieldDelegateProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(delegate: AppPhoneCodeCenterTextFieldDelegateProtocol, actionTarget: ActionTargetControlProtocol) {
        self.customDelegate = delegate
        self.internalEventPublisher = PassthroughSubject<AppPhoneCodeCenterTextFieldInternalEvent, Never>()
        self.externalEventPublisher = delegate.externalEventPublisher
        self.subscriptions = Set<AnyCancellable>()
        super.init(delegate: delegate, actionTarget: actionTarget, frame: .zero)
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension AppPhoneCodeCenterTextField {
    
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
        keyboardType = .numberPad
        textContentType = .oneTimeCode
    }
    
    func internalEventHandler(_ event: AppPhoneCodeCenterTextFieldInternalEvent) {
        switch event {
            case .target(let value):
                customDelegate.internalEventPublisher.send(value)
            
            case .clear:
                text?.removeAll()
        }
    }
    
}

// MARK: - AppPhoneCodeCenterTextFieldInternalEvent
enum AppPhoneCodeCenterTextFieldInternalEvent {
    case target(AppPhoneCodeCenterStackTarget)
    case clear
}

// MARK: - AppPhoneCodeCenterTextFieldExternalEvent
enum AppPhoneCodeCenterTextFieldExternalEvent {
    case input([String]?)
    case validation(String)
}
