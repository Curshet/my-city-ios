import UIKit
import Combine

class AppSwitch: UISwitch, AppSwitchProtocol {
    
    let publisher: AnyPublisher<UIControl.Event, Never>
    
    private let actionTarget: ActionTargetControlProtocol
    private let overlay: AppOverlayViewProtocol?
    private var touchInsets: CGPoint?
    private var touchOffsets: CGPoint?
    
    init(actionTarget: ActionTargetControlProtocol, overlay: AppOverlayViewProtocol?, event: UIControl.Event = .primaryActionTriggered, frame: CGRect = .zero) {
        self.actionTarget = actionTarget
        self.overlay = overlay
        self.publisher = actionTarget.publisher
        super.init(frame: .zero)
        self.actionTarget.control = self
        addTarget(event)
        addSubview(overlay)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
}

// MARK: Protocol
extension AppSwitch {
    
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
