import UIKit
import Combine

final class DisplayWindow: UIWindow, DisplayWindowProtocol {
    
    let internalEventPublisher: PassthroughSubject<DisplaySpinnerEvent, Never>
    
    private let presenter: DisplayPresenterProtocol
    private let viеwController: DisplayViewControllerProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(presenter: DisplayPresenterProtocol, viewController: DisplayViewControllerProtocol, screen: ScreenProtocol) {
        self.presenter = presenter
        self.viеwController = viewController
        self.internalEventPublisher = PassthroughSubject<DisplaySpinnerEvent, Never>()
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: screen.bounds)
        self.rootViewController = viewController
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.viеwController.internalEventPublisher.send($0)
            self?.presenter.internalEventPublisher.send(.configure)
        }.store(in: &subscriptions)
    }
    
}
