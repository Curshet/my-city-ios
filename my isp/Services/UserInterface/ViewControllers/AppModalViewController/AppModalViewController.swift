import UIKit
import Combine

class AppModalViewController: UIViewController, AppModalViewControllerProtocol {
    
    let publisher: AnyPublisher<AppGestureRecognizerEvent, Never>
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private let background: UIVisualEffectView
    private let tapGesture: AppTapGestureRecognizerProtocol

    init(foreground: UIView, background: UIVisualEffectView, backgroundGesture: AppTapGestureRecognizerProtocol? = nil) {
        self.background = background
        self.tapGesture = backgroundGesture ?? AppTapGestureRecognizer()
        self.publisher = tapGesture.publisher
        super.init(nibName: nil, bundle: nil)
        setupConfiguration(foreground)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConfiguration(_ foreground: UIView) {
        background.contentView.addSubview(foreground)
        background.addGesture(tapGesture)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    final override func loadView() {
        view = background
    }
    
    final func setupBackground(_ value: AppModalViewBackground) {
        background.effect = value.effect
        background.backgroundColor = value.backgroundColor
    }
    
}

// MARK: - AppModalViewBackground
struct AppModalViewBackground {
    let effect: UIVisualEffect?
    let backgroundColor: UIColor
}
