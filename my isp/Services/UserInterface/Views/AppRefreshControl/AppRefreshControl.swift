import UIKit
import Combine

class AppRefreshControl: UIRefreshControl, AppRefreshControlProtocol {
    
    let publisher: AnyPublisher<UIControl.Event, Never>
    
    private let actionTarget: ActionTargetControlProtocol
    
    init(actionTarget: ActionTargetControlProtocol, event: UIControl.Event = .valueChanged, frame: CGRect = .zero) {
        self.actionTarget = actionTarget
        self.publisher = actionTarget.publisher
        super.init()
        self.actionTarget.control = self
        addTarget(event)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    final func addTarget(_ event: UIControl.Event...) {
        event.forEach {
            actionTarget.addTarget($0)
        }
    }
    
    final func removeTarget(_ event: UIControl.Event...) {
        event.forEach {
            actionTarget.removeTarget($0)
        }
    }
    
}
