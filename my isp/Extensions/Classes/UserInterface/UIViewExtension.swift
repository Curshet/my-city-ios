import UIKit
import Combine

extension UIView {
    
    var keyboardPublisher: AnyPublisher<KeyboardManagerEvent, Never> {
        KeyboardManager.entry.publisher
    }
    
    var isVisible: Bool {
        var responder = next

        while let superview = responder as? UIView {
            responder = superview.next
        }

        if let viewController = responder as? UIViewController {
            return viewController.isVisible
        }
        
        return window != nil && !isHidden
    }
    
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        
        return nil
    }
    
    var hierarchyImage: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        defer { UIGraphicsEndImageContext() }
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func hideKeyboard() {
        endEditing(true)
    }
    
    func addGesture(_ recognizer: UIGestureRecognizer?) {
        guard let recognizer else { return }
        isUserInteractionEnabled = true
        addGestureRecognizer(recognizer)
    }
    
    func removeGesture(_ recognizer: UIGestureRecognizer?) {
        guard let recognizer else { return }
        removeGestureRecognizer(recognizer)
    }
    
    func addSubview(_ view: UIView?) {
        guard let view else { return }
        addSubview(view)
    }
    
    func addSubviews(_ views: UIView?...) {
        views.forEach {
            addSubview($0)
        }
    }
    
    func hideSubviews(_ views: UIView?...) {
        guard !views.isEmpty else {
            subviews.forEach {
                $0.isHidden = true
            }
            
            return
        }
        
        views.forEach {
            $0?.isHidden = true
        }
    }
    
    func showSubviews(_ views: UIView?...) {
        guard !views.isEmpty else {
            subviews.forEach {
                $0.isHidden = false
            }
            
            return
        }
        
        views.forEach {
            $0?.isHidden = false
        }
    }
    
    func removeSubviews(_ views: UIView?...) {
        guard !views.isEmpty else {
            subviews.forEach {
                $0.removeFromSuperview()
            }
            
            return
        }
        
        views.forEach {
            $0?.removeFromSuperview()
        }
    }
    
    func animate(duration: Double, delay: Double = .zero, damping: CGFloat = 1, velocity: CGFloat = 1, options: UIView.AnimationOptions = [], animation: @escaping () -> Void, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: options, animations: animation) { _ in
            completion?()
        }
    }

}
