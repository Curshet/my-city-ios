import UIKit

class AppImageView: UIImageView, AppImageViewProtocol {

    private let overlay: AppOverlayViewProtocol

    init(overlay: AppOverlayViewProtocol, frame: CGRect = .zero) {
        self.overlay = overlay
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        addSubview(overlay)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Protocol
extension AppImageView {
    
    func configureOverlay(_ layout: AppOverlayViewLayout) {
        overlay.internalEventPublisher.send(.layout(layout))
    }
    
    func startOverlay() {
        overlay.internalEventPublisher.send(.animation(.active))
    }
    
    func stopOverlay() {
        overlay.internalEventPublisher.send(.animation(.inactive))
    }
    
}
