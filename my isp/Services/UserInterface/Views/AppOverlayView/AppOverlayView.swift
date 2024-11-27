import UIKit
import Combine
import SnapKit

class AppOverlayView: UIVisualEffectView, AppOverlayViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppOverlayViewInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AppTimeEvent, Never>
    
    private let activityIndicator: UIActivityIndicatorView
    private let externalPublisher: PassthroughSubject<AppTimeEvent, Never>
    private var startDelay: Double?
    private var stopDelay: Double?
    private var state: ActionTargetState
    private var subscriptions: Set<AnyCancellable>
    
    init(activityIndicator: UIActivityIndicatorView) {
        self.activityIndicator = activityIndicator
        self.internalEventPublisher = PassthroughSubject<AppOverlayViewInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AppTimeEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.state = .inactive
        self.subscriptions = Set<AnyCancellable>()
        super.init(effect: nil)
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension AppOverlayView {
    
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
        activityIndicator.hidesWhenStopped = true
        alpha = .zero
        isHidden = true
        contentView.addSubview(activityIndicator)
    }
    
    func internalEventHandler(_ event: AppOverlayViewInternalEvent) {
        switch event {
            case .layout(let value):
                setupLayout(value)
                setupConstraints(value)
                setupSubviews(value)
                layoutIfNeeded()
            
            case .animation(let state):
                state == .active ? startAnimation() : stopAnimation()
        }
    }
    
    func setupLayout(_ value: AppOverlayViewLayout) {
        effect = value.effect
        backgroundColor = value.backgroundColor
        layer.cornerRadius = value.cornerRadius
        startDelay = value.startDelay
        stopDelay = value.stopDelay
    }
    
    func setupConstraints(_ value: AppOverlayViewLayout) {
        if superview != nil {
            snp.remakeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        if let layout = value.activityIndicator {
            activityIndicator.snp.remakeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalTo(layout.size.width)
                $0.height.equalTo(layout.size.height)
            }
        }
    }
    
    func setupSubviews(_ value: AppOverlayViewLayout) {
        guard let layout = value.activityIndicator else {
            activityIndicator.isHidden = true
            return
        }
        
        activityIndicator.style = layout.type
        activityIndicator.backgroundColor = layout.backgroundColor
        activityIndicator.color = layout.color
        activityIndicator.layer.cornerRadius = layout.cornerRadius
        activityIndicator.isHidden = false
    }
    
    func startAnimation() {
        guard state != .active else { return }
        
        guard let startDelay else {
            logger.console(event: .error(info: "Overlay view doesn't have a configutation for presenting"))
            return
        }
        
        animate(duration: startDelay) {
            self.alpha = 1
        }
        
        state = .active
        isHidden = false
        superview?.isUserInteractionEnabled = isHidden
        activityIndicator.startAnimating()
        externalPublisher.send(.start)
    }
    
    func stopAnimation() {
        guard state == .active, let stopDelay else { return }
        
        animate(duration: stopDelay) {
            self.alpha = .zero
        } completion: {
            self.isHidden = true
            self.superview?.isUserInteractionEnabled = self.isHidden
            self.activityIndicator.stopAnimating()
            self.externalPublisher.send(.stop)
        }
        
        state = .inactive
    }
    
}

// MARK: - AppOverlayViewLayout
struct AppOverlayViewLayout {
    let activityIndicator: AppOverlayActivityIndicatorLayout?
    let effect: UIVisualEffect?
    var backgroundColor: UIColor
    var cornerRadius: CGFloat
    var startDelay: Double
    var stopDelay: Double
}

// MARK: - AppOverlayActivityIndicatorLayout
struct AppOverlayActivityIndicatorLayout {
    let type: UIActivityIndicatorView.Style
    var backgroundColor: UIColor
    var color: UIColor
    var size: CGSize
    var cornerRadius: CGFloat
}

// MARK: - AppOverlayViewInternalEvent
enum AppOverlayViewInternalEvent {
    case layout(AppOverlayViewLayout)
    case animation(ActionTargetState)
}
