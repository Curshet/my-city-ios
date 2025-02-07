import UIKit
import Combine

class AppLongPressGestureRecognizer: UILongPressGestureRecognizer, AppLongPressGestureRecognizerProtocol {
    
    let publisher: AnyPublisher<AppGestureRecognizerEvent, Never>

    private let customDelegate: UIGestureRecognizerDelegate?
    private let actionTarget: ActionTargetInfoProtocol
    private let externalPublisher: PassthroughSubject<AppGestureRecognizerEvent, Never>
    private var subscriptions: Set<AnyCancellable>

    init(delegate: UIGestureRecognizerDelegate? = nil) {
        self.customDelegate = delegate
        self.actionTarget = ActionTarget()
        self.externalPublisher = PassthroughSubject<AppGestureRecognizerEvent, Never>()
        self.publisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(target: actionTarget, action: #selector(actionTarget.primaryActionTriggered))
        self.delegate = customDelegate
        setupObservers()
    }
    
    private func setupObservers() {
        actionTarget.publisher.sink { [weak self] _ in
            self?.externalPublisher.send(.touchInside)
        }.store(in: &subscriptions)
    }
    
}
