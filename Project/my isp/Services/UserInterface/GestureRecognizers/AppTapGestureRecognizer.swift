import UIKit
import Combine

final class AppTapGestureRecognizer: UITapGestureRecognizer {
    
    let publisher: AnyPublisher<Void, Never>

    private let actionTarget: ActionTargetInfoProtocol
    private let externalPublisher: PassthroughSubject<Void, Never>
    private var subscriptions: Set<AnyCancellable>

    init() {
        self.actionTarget = ActionTarget()
        self.externalPublisher = PassthroughSubject<Void, Never>()
        self.publisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(target: actionTarget, action: #selector(actionTarget.primaryActionTriggered))
        setupObservers()
    }
    
    private func setupObservers() {
        actionTarget.publisher.sink { [weak self] _ in
            self?.externalPublisher.send()
        }.store(in: &subscriptions)
    }
    
}
