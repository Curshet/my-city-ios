import UIKit

class AppHighlightingView: AppTransformingView, AppHighlightingViewProtocol {

    private var animated: Bool
    private var animation: AppViewAnimationModel
    private var color: UIColor?
    
    override init(animated: Bool = true, frame: CGRect = .zero) {
        self.animated = animated
        self.animation = AppViewAnimationModel()
        super.init(animated: false, frame: frame)
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
        
        animate(duration: animation.touchesBegan?.duration ?? AppAppHighlightingViewValue.touchesBeganDuration) {
            self.backgroundColor = self.animation.touchesBegan?.color ?? self.color?.withAlphaComponent(AppAppHighlightingViewValue.touchesBeganAlpha)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard animated else { return }
        
        if let duration = animation.touchesMoved?.duration, duration <= .zero {
            return
        }

        animate(duration: animation.touchesMoved?.duration ?? AppAppHighlightingViewValue.touchesMovedDuration) {
            self.backgroundColor = self.animation.touchesMoved?.color ?? self.color?.withAlphaComponent(AppAppHighlightingViewValue.touchesMovedAlpha)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard animated else { return }

        if let duration = animation.touchesEnded?.duration, duration <= .zero {
            return
        }
        
        animate(duration: animation.touchesEnded?.duration ?? AppAppHighlightingViewValue.touchesEndedDuration) {
            self.backgroundColor = self.animation.touchesEnded?.color ?? self.color?.withAlphaComponent(AppAppHighlightingViewValue.touchesEndedAlpha)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        guard animated else { return }

        if let duration = animation.touchesCancelled?.duration, duration <= .zero {
            return
        }
        
        animate(duration: animation.touchesCancelled?.duration ?? AppAppHighlightingViewValue.touchesCancelledDuration) {
            self.backgroundColor = self.animation.touchesCancelled?.color ?? self.color?.withAlphaComponent(AppAppHighlightingViewValue.touchesCancelledAlpha)
        }
    }
    
}

// MARK: Protocol
extension AppHighlightingView {
    
    func backgroundColor(_ value: UIColor?) {
        backgroundColor = value
        color = backgroundColor
    }
    
    func configureHighlight(_ target: AppViewAnimationTarget) {
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
    
    func highlight(_ completion: (() -> Void)?) {
        guard animated else {
            transform(completion)
            return
        }
        
        transform()

        if let durationStart = animation.selectedTransform?.durationStart, durationStart <= .zero, let durationFinish = animation.selectedTransform?.durationFinish, durationFinish <= .zero {
            completion?()
            return
        }
        
        animate(duration: animation.selectedTransform?.durationStart ?? AppAppHighlightingViewValue.highlightDurationStart) {
            self.backgroundColor = self.animation.selectedTransform?.colorStart ?? self.color?.withAlphaComponent(AppAppHighlightingViewValue.highlightAlphaStart)
        } completion: {
            completion?()
            self.animate(duration: self.animation.selectedTransform?.durationFinish ?? AppAppHighlightingViewValue.highlightDurationFinish) {
                self.backgroundColor = self.animation.selectedTransform?.colorFinish ?? self.color?.withAlphaComponent(AppAppHighlightingViewValue.highlightAlphaFinish)
            }
        }
    }
    
}

// MARK: - AppAppHighlightingViewValue
fileprivate struct AppAppHighlightingViewValue {
    static let highlightDurationStart = 0.1
    static let highlightDurationFinish = 0.15
    static let highlightAlphaStart = 0.75
    static let highlightAlphaFinish = 1.0
    static let touchesBeganDuration = 0.2
    static let touchesBeganAlpha = 0.75
    static let touchesMovedDuration = 0.2
    static let touchesMovedAlpha = 0.75
    static let touchesEndedDuration = 0.2
    static let touchesEndedAlpha = 1.0
    static let touchesCancelledDuration = 0.2
    static let touchesCancelledAlpha = 1.0
}

// MARK: - AppViewAnimationModel
struct AppViewAnimationModel {
    var touchesBegan: AppViewAnimation?
    var touchesMoved: AppViewAnimation?
    var touchesEnded: AppViewAnimation?
    var touchesCancelled: AppViewAnimation?
    var selectedTransform: AppViewTransformation?
    
    mutating func setup(_ value: AppViewAnimationType) {
        switch value {
            case .touchesBegan(let value):
                touchesBegan = value
            
            case .touchesMoved(let value):
                touchesMoved = value
            
            case .touchesEnded(let value):
                touchesEnded = value
            
            case .touchesCancelled(let value):
                touchesCancelled = value
            
            case .touchInside(let value):
                selectedTransform = value
        }
    }
    
    mutating func reset() {
        touchesBegan = nil
        touchesMoved = nil
        touchesEnded = nil
        touchesCancelled = nil
        selectedTransform = nil
    }
}

// MARK: - AppViewAnimation
struct AppViewAnimation {
    let duration: Double
    let color: UIColor?
    let transform: CGAffineTransform?
}

// MARK: - AppViewTransformation
struct AppViewTransformation {
    let durationStart: Double
    let durationFinish: Double
    let colorStart: UIColor?
    let colorFinish: UIColor?
    let transformStart: CGAffineTransform?
    let transformFinish: CGAffineTransform?
}

// MARK: - AppViewAnimationTarget
enum AppViewAnimationTarget {
    /// Activate animation with installed custom properties (default state)
    case enable
    /// Deactivate animation without removing installed custom properties
    case disable
    /// Setup custom animation properties and activate animation
    case setup(AppViewAnimationType)
    /// Reset custom properties and activate default animation
    case reset
}

// MARK: - AppViewAnimationType
enum AppViewAnimationType {
    case touchesBegan(AppViewAnimation)
    case touchesMoved(AppViewAnimation)
    case touchesEnded(AppViewAnimation)
    case touchesCancelled(AppViewAnimation)
    case touchInside(AppViewTransformation)
}
