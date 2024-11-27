import UIKit
import Combine
import SnapKit

class AuthorizationView: UIScrollView, AuthorizationViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationViewModelExternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AuthorizationViewModelSelectEvent, Never>
    
    private let headerView: AuthorizationHeaderViewProtocol
    private let centerView: AuthorizationCenterViewProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(headerView: AuthorizationHeaderViewProtocol, centerView: AuthorizationCenterViewProtocol) {
        self.headerView = headerView
        self.centerView = centerView
        self.internalEventPublisher = PassthroughSubject<AuthorizationViewModelExternalEvent, Never>()
        self.externalEventPublisher = centerView.externalEventPublisher
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: .zero)
        startСonfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension AuthorizationView {
    
    func startСonfiguration() {
        setupObservers()
        setupСonfiguration()
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
        addSubviews(headerView, centerView)
    }
    
    func internalEventHandler(_ event: AuthorizationViewModelExternalEvent) {
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
    
}

// MARK: - AuthorizationViewLayout
struct AuthorizationViewLayout {
    let backgroundColor = UIColor.interfaceManager.themeBackgroundOne()
}
