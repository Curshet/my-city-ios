import UIKit
import Combine
import SnapKit

class AuthorizationPhoneRootView: UIScrollView, AuthorizationPhoneRootViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootViewModelExternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AuthorizationPhoneRootViewModelSelectEvent, Never>
    
    private let headerView: AuthorizationPhoneRootHeaderViewProtocol
    private let centerView: AuthorizationPhoneRootCenterViewProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(headerView: AuthorizationPhoneRootHeaderViewProtocol, centerView: AuthorizationPhoneRootCenterViewProtocol) {
        self.headerView = headerView
        self.centerView = centerView
        self.internalEventPublisher = PassthroughSubject<AuthorizationPhoneRootViewModelExternalEvent, Never>()
        self.externalEventPublisher = centerView.externalEventPublisher
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: .zero)
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension AuthorizationPhoneRootView {
    
    func startConfiguration() {
        setupObservers()
        setupСonfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        keyboardPublisher.sink { [weak self] in
            self?.keyboardEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func setupСonfiguration() {
        bouncesZoom = false
        alwaysBounceVertical = true
        alwaysBounceHorizontal = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        keyboardDismissMode = .interactive
        addSubviews(headerView, centerView)
    }
    
    func internalEventHandler(_ event: AuthorizationPhoneRootViewModelExternalEvent) {
        switch event {
            case .data(var value):
                backgroundColor = value.layout.backgroundColor
                headerView.internalEventPublisher.send(value.header)
                value.center.layout.topConstraint = headerView.snp.bottom
                centerView.internalEventPublisher.send(.data(value))
            
            case.animation:
                guard isVisible else { return }
                fallthrough
            
            default:
                centerView.internalEventPublisher.send(event)
        }
    }

    func keyboardEventHandler(_ event: KeyboardManagerEvent) {
        guard isVisible, case let .willShow(frame) = event else { return }
        lazy var offset = CGPoint(x: .zero, y: centerView.frame.maxY - frame.minY + 20)
        guard offset.y > contentOffset.y else { return }
        setContentOffset(offset, animated: true)
    }
    
}

// MARK: - AuthorizationPhoneRootViewLayout
struct AuthorizationPhoneRootViewLayout {
    let backgroundColor = UIColor.interfaceManager.themeBackgroundOne()
}
