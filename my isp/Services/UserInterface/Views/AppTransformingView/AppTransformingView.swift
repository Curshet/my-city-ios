import UIKit
import Combine

class AppTransformingView: UIView, AppTransformingViewProtocol {
    
    private var animated: Bool
    private var animation: AppViewAnimationModel
    
    init(animated: Bool = true, frame: CGRect = .zero) {
        self.animated = animated
        self.animation = AppViewAnimationModel()
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard animated else { return }

        if let duration = animation.touchesBegan?.duration, duration <= .zero {
            return
        }
        
        animate(duration: animation.touchesBegan?.duration ?? AppTransformingViewValue.touchesBeganDuration) {
            self.transform = self.animation.touchesBegan?.transform ?? AppTransformingViewValue.touchesBeganTransform
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard animated else { return }
        
        if let duration = animation.touchesMoved?.duration, duration <= .zero {
            return
        }

        animate(duration: animation.touchesMoved?.duration ?? AppTransformingViewValue.touchesMovedDuration) {
            self.transform = self.animation.touchesMoved?.transform ?? AppTransformingViewValue.touchesMovedTransform
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard animated else { return }

        if let duration = animation.touchesEnded?.duration, duration <= .zero {
            return
        }
        
        animate(duration: animation.touchesEnded?.duration ?? AppTransformingViewValue.touchesEndedDuration) {
            self.transform = self.animation.touchesEnded?.transform ?? AppTransformingViewValue.touchesEndedTransform
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        guard animated else { return }

        if let duration = animation.touchesCancelled?.duration, duration <= .zero {
            return
        }
        
        animate(duration: animation.touchesCancelled?.duration ?? AppTransformingViewValue.touchesCancelledDuration) {
            self.transform = self.animation.touchesCancelled?.transform ?? AppTransformingViewValue.touchesCancelledTransform
        }
    }
    
}

// MARK: Protocol
extension AppTransformingView {
    
    func configureTransform(_ target: AppViewAnimationTarget) {
        switch target {
            case .enable:
                animated = true
            
            case .disable:
                animated = false
            
            case .setup(let value):
                animated = true
                animation.setup(value)
            
            case .reset:
                animated = true
                animation.reset()
        }
    }
    
    func transform(_ completion: (() -> Void)? = nil) {
        guard animated else {
            completion?()
            return
        }

        if let durationStart = animation.selectedTransform?.durationStart, durationStart <= .zero, let durationFinish = animation.selectedTransform?.durationFinish, durationFinish <= .zero {
            completion?()
            return
        }
        
        animate(duration: animation.selectedTransform?.durationStart ?? AppTransformingViewValue.transformDuration) {
            self.transform = self.animation.selectedTransform?.transformStart ?? AppTransformingViewValue.transformStart
        } completion: {
            completion?()
            self.animate(duration: self.animation.selectedTransform?.durationFinish ?? AppTransformingViewValue.transformDuration) {
                self.transform = self.animation.selectedTransform?.transformFinish ?? AppTransformingViewValue.transformFinish
            }
        }
    }
    
}

// MARK: - AppTransformingViewValue
fileprivate enum AppTransformingViewValue {
    static let transformDuration = 0.1
    static let transformStart = CGAffineTransform(scaleX: 0.98, y: 0.98)
    static let transformFinish = CGAffineTransform.identity
    static let touchesBeganDuration = 0.1
    static let touchesBeganTransform = CGAffineTransform(scaleX: 0.97, y: 0.97)
    static let touchesMovedDuration = 0.1
    static let touchesMovedTransform = CGAffineTransform(scaleX: 0.97, y: 0.97)
    static let touchesEndedDuration = 0.2
    static let touchesEndedTransform = CGAffineTransform.identity
    static let touchesCancelledDuration = 0.2
    static let touchesCancelledTransform = CGAffineTransform.identity
}
