import UIKit
import Combine
import SnapKit

class AppPhoneCodeView: UIScrollView, AppPhoneCodeViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppPhoneCodeViewInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AppPhoneCodeViewExternalEvent, Never>
    
    private let alertView: AppPhoneCodeAlertViewProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(alertView: AppPhoneCodeAlertViewProtocol) {
        self.alertView = alertView
        self.internalEventPublisher = PassthroughSubject<AppPhoneCodeViewInternalEvent, Never>()
        self.externalEventPublisher = alertView.externalEventPublisher
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: .zero)
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension AppPhoneCodeView {
    
    func startConfiguration() {
        setupObservers()
        setupСonfiguration()
        setupGestureRecognizer()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func setupСonfiguration() {
        bouncesZoom = false
        alwaysBounceVertical = true
        alwaysBounceHorizontal = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        keyboardDismissMode = .interactive
        addSubview(alertView)
    }
    
    func setupGestureRecognizer() {
        let gesture = AppTapGestureRecognizer()
        
        gesture.publisher.sink { [weak self] _ in
            self?.hideKeyboard()
        }.store(in: &subscriptions)
        
        addGesture(gesture)
    }
    
    func internalEventHandler(_ event: AppPhoneCodeViewInternalEvent) {
        switch event {
            case .data:
                setupConstraints()
                fallthrough
                
            default:
                alertView.internalEventPublisher.send(event)
        }
    }
    
    func setupConstraints() {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}

// MARK: - AppPhoneCodeViewInternalEvent
enum AppPhoneCodeViewInternalEvent {
    case data(AppPhoneCodeViewData)
    case timer(AppPhoneCodeCenterRepeat)
    case animation(ActionTargetState)
    case keyboard
    case reset
}

// MARK: - AppPhoneCodeViewExternalEvent
enum AppPhoneCodeViewExternalEvent {
    case input
    case validation(String)
    case repeаt
    case exit
}
