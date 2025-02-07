import UIKit
import Combine

class AppButton: UIButton, AppButtonProtocol {

    let publisher: AnyPublisher<UIControl.Event, Never>
    
    private let actionTarget: ActionTargetControlProtocol
    private let overlay: AppOverlayViewProtocol?
    private var transforming: Bool
    private var transformation: AppViewAnimationModel
    private var stаte: AppButtonState
    private var touchInsets: CGPoint?
    private var touchOffsets: CGPoint?
    private let externalPublisher: PassthroughSubject<UIControl.Event, Never>
    private var subscriptions: Set<AnyCancellable>

    init(actionTarget: ActionTargetControlProtocol, overlay: AppOverlayViewProtocol?, event: UIControl.Event = .primaryActionTriggered, frame: CGRect = .zero, transforming: Bool = true) {
        self.actionTarget = actionTarget
        self.overlay = overlay
        self.transforming = transforming
        self.transformation = AppViewAnimationModel()
        self.stаte = .enabled
        self.externalPublisher = PassthroughSubject<UIControl.Event, Never>()
        self.publisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: frame)
        self.actionTarget.control = self
        startConfiguration(event)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        guard stаte != .enabled, state == .normal else {
            super.setTitleColor(color, for: state)
            return
        }
        
        stаte = .disabled(color)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let touchInsets {
            let touchArea = bounds.insetBy(dx: touchInsets.x, dy: touchInsets.y)
            return touchArea.contains(point)
        }
        
        if let touchOffsets {
            let touchArea = bounds.insetBy(dx: -touchOffsets.x, dy: -touchOffsets.y)
            return touchArea.contains(point)
        }
        
        return bounds.contains(point)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard transforming else { return }
        
        if let duration = transformation.touchesBegan?.duration, duration <= .zero {
            return
        }
        
        animate(duration: transformation.touchesBegan?.duration ?? AppButtonValue.touchesBeganDuration) {
            self.transform = self.transformation.touchesBegan?.transform ?? AppButtonValue.touchesBeganTransform
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        guard transforming, let animation = transformation.touchesMoved, animation.duration > .zero, let transform = animation.transform else { return }

        animate(duration: animation.duration) {
            self.transform = transform
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard transforming else { return }

        if let duration = transformation.touchesEnded?.duration, duration <= .zero {
            return
        }

        animate(duration: transformation.touchesEnded?.duration ?? AppButtonValue.touchesEndedDuration) {
            self.transform = self.transformation.touchesEnded?.transform ?? AppButtonValue.touchesEndedTransform
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        guard transforming else { return }

        if let duration = transformation.touchesCancelled?.duration, duration <= .zero {
            return
        }

        animate(duration: transformation.touchesCancelled?.duration ?? AppButtonValue.touchesCancelledDuration) {
            self.transform = self.transformation.touchesCancelled?.transform ?? AppButtonValue.touchesCancelledTransform
        }
    }
    
}

// MARK: Private
private extension AppButton {
    
    func startConfiguration(_ event: UIControl.Event) {
        setupObservers()
        addTarget(event)
        addSubview(overlay)
    }
    
    func setupObservers() {
        overlay?.externalEventPublisher.sink { [weak self] in
            self?.overlayEventHandler($0)
        }.store(in: &subscriptions)
        
        actionTarget.publisher.sink { [weak self] in
            self?.transformation($0)
        }.store(in: &subscriptions)
    }
    
    func transformation(_ event: UIControl.Event) {
        guard event == .primaryActionTriggered else {
            externalPublisher.send(event)
            return
        }
            
        transform { [weak self] in
            self?.externalPublisher.send(event)
        }
    }
    
    func overlayEventHandler(_ event: AppTimeEvent) {
        switch event {
            case .start:
                let titleColor = titleLabel?.textColor
                setTitleColor(.clear, for: .normal)
                stаte = .disabled(titleColor)

            case .stop:
                guard case let .disabled(titleColor) = stаte else { return }
                stаte = .enabled
                setTitleColor(titleColor, for: .normal)
            
            default:
                break
        }
    }
    
    func transform(_ completion: (() -> Void)?) {
        guard transforming else {
            completion?()
            return
        }
        
        if let durationStart = transformation.selectedTransform?.durationStart, durationStart <= .zero, let durationFinish = transformation.selectedTransform?.durationFinish, durationFinish <= .zero {
            completion?()
            return
        }
        
        animate(duration: transformation.selectedTransform?.durationStart ?? AppButtonValue.transformDuration) {
            self.transform = self.transformation.selectedTransform?.transformStart ?? AppButtonValue.transformStart
        } completion: {
            self.animate(duration: self.transformation.selectedTransform?.durationFinish ?? AppButtonValue.transformDuration) {
                self.transform = self.transformation.selectedTransform?.transformFinish ?? AppButtonValue.transformFinish
            } completion: {
                completion?()
            }
        }
    }
    
}

// MARK: Protocol
extension AppButton {
    
    func addTarget(_ event: UIControl.Event...) {
        event.forEach {
            actionTarget.addTarget($0)
        }
    }
    
    func removeTarget(_ event: UIControl.Event...) {
        event.forEach {
            actionTarget.removeTarget($0)
        }
    }
    
    func setTouchInsets(_ value: CGPoint) {
        touchOffsets = nil
        touchInsets = value
    }
    
    func setTouchOffsets(_ value: CGPoint) {
        touchInsets = nil
        touchOffsets = value
    }
    
    func configureTransform(_ target: AppViewAnimationTarget) {
        switch target {
            case .enable:
                transforming = true
            
            case .disable:
                transforming = false
            
            case .setup(let value):
                transforming = true
                transformation.setup(value)
            
            case .reset:
                transforming = true
                transformation.reset()
        }
    }
    
    func configureOverlay(_ layout: AppOverlayViewLayout) {
        overlay?.internalEventPublisher.send(.layout(layout))
    }
    
    func startOverlay() {
        overlay?.internalEventPublisher.send(.animation(.active))
    }
    
    func stopOverlay() {
        overlay?.internalEventPublisher.send(.animation(.inactive))
    }
    
}

// MARK: - AppButtonState
fileprivate enum AppButtonState: Equatable {
    case enabled
    case disabled(UIColor?)
}

// MARK: - AppButtonValue
fileprivate enum AppButtonValue {
    static let transformDuration = 0.1
    static let transformStart = CGAffineTransform(scaleX: 0.95, y: 0.95)
    static let transformFinish = CGAffineTransform.identity
    static let touchesBeganDuration = 0.1
    static let touchesBeganTransform = CGAffineTransform(scaleX: 0.94, y: 0.94)
    static let touchesEndedDuration = 0.2
    static let touchesEndedTransform = CGAffineTransform.identity
    static let touchesCancelledDuration = 0.2
    static let touchesCancelledTransform = CGAffineTransform.identity
}
