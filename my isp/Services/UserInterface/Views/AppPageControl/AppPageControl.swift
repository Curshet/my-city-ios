import UIKit
import Combine

class AppPageControl: UIPageControl, AppPageControlProtocol {
    
    let publisher: AnyPublisher<AppPageControlExternalEvent, Never>
    
    private let actionTarget: ActionTargetControlProtocol
    private let externalPublisher: PassthroughSubject<AppPageControlExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(actionTarget: ActionTargetControlProtocol, event: UIControl.Event = .valueChanged, frame: CGRect = .zero) {
        self.actionTarget = actionTarget
        self.externalPublisher = PassthroughSubject<AppPageControlExternalEvent, Never>()
        self.publisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: frame)
        self.actionTarget.control = self
        addTarget(event)
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupObservers() {
        actionTarget.publisher.sink { [weak self] in
            guard let page = self?.currentPage else { return }
            let event = AppPageControlExternalEvent(type: $0, page: page)
            self?.externalPublisher.send(event)
        }.store(in: &subscriptions)
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

// MARK: - AppPageControlExternalEvent
struct AppPageControlExternalEvent {
    let type: UIControl.Event
    let page: Int
}
