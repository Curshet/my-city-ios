import UIKit
import Combine

final class AppEffectPresenter: AppEffectPresenterProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppEffectPresenterInternalEvent, Never>
    
    private let window: UIWindow
    private var subscriptions: Set<AnyCancellable>
    
    init(window: UIWindow) {
        self.internalEventPublisher = PassthroughSubject<AppEffectPresenterInternalEvent, Never>()
        self.window = window
        self.subscriptions = Set<AnyCancellable>()
        startConfiguration()
    }
    
}

// MARK: Private
private extension AppEffectPresenter {

    func startConfiguration() {
        setupObservers()
        setupWindow()
    }
    
    func setupObservers() {
        internalEventPublisher.sink {
            switch $0 {
                case .showEffect:
                    break
                
                case .hideEffect:
                    break
            }
        }.store(in: &subscriptions)
    }
    
    func setupWindow() {
        window.windowLevel = .normal + 1
        window.alpha = 0
        window.isHidden = true
    }
    
    func showEffect() {
        UIView.animate(withDuration: 0.2) {
            self.window.isHidden = false
            self.window.alpha = 0.1
        }
    }
    
    func hideEffect() {
        guard !window.isHidden else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.window.alpha = 0
        } completion: { _ in
            self.window.isHidden = true
        }
    }
    
}

// MARK: AppEffectPresenterInternalEvent
enum AppEffectPresenterInternalEvent {
    case showEffect
    case hideEffect
}
