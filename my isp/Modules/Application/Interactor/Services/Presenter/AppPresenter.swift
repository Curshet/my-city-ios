import UIKit
import Combine

final class AppPresenter: NSObject, AppPresenterProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppPresenterInternalEvent, Never>
    
    private weak var keyWindow: UIWindow?
    private let effectView: UIVisualEffectView
    private let interfaceManager: InterfaceManagerInfoProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(keyWindow: UIWindow, effectView: UIVisualEffectView, interfaceManager: InterfaceManagerInfoProtocol) {
        self.keyWindow = keyWindow
        self.effectView = effectView
        self.interfaceManager = interfaceManager
        self.internalEventPublisher = PassthroughSubject<AppPresenterInternalEvent, Never>()
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        startConfiguration()
    }
    
}

// MARK: Private
private extension AppPresenter {

    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        interfaceManager.publisher.sink { [weak self] _ in
            self?.effectView.effect = .interfaceManager.themeBlur()
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        guard let keyWindow else {
            logger.console(event: .error(info: "Application presenter doesn’t have the key window"))
            return
        }
        
        effectView.frame = keyWindow.bounds
        effectView.effect = .interfaceManager.themeBlur()
    }
    
    func internalEventHandler(_ event: AppPresenterInternalEvent) {
        switch event {
            case .showEffect:
                showEffect()
            
            case .hideEffect:
                hideEffect()
        }
    }
    
    func showEffect() {
        effectView.alpha = 0.99
        keyWindow?.hideKeyboard()
        keyWindow?.addSubview(effectView)
    }
    
    func hideEffect() {
        UIView.animate(withDuration: 0.2) {
            self.effectView.alpha = .zero
        } completion: { _ in
            self.effectView.removeFromSuperview()
        }
    }
    
}

// MARK: - AppPresenterInternalEvent
enum AppPresenterInternalEvent {
    case showEffect
    case hideEffect
}
