import UIKit
import Combine

class AppSwipePressGestureRecognizer: UISwipeGestureRecognizer, AppSwipeGestureRecognizerProtocol {
    
    let publisher: AnyPublisher<AppGestureRecognizerEvent, Never>

    private let customDelegate: AppGestureRecognizerDelegateProtocol?
    private let actionTarget: ActionTargetInfoProtocol
    private let externalPublisher: PassthroughSubject<AppGestureRecognizerEvent, Never>
    private var subscriptions: Set<AnyCancellable>

    init(delegate: AppGestureRecognizerDelegateProtocol? = nil) {
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
        customDelegate?.publisher.sink { [weak self] in
            self?.externalPublisher.send($0)
        }.store(in: &subscriptions)
        
        actionTarget.publisher.sink { [weak self] _ in
            self?.externalPublisher.send(.touchInside)
        }.store(in: &subscriptions)
    }
    
}
