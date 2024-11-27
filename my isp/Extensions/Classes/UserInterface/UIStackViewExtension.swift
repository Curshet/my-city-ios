import UIKit

extension UIStackView {
    
    func addArrangedSubview(_ view: UIView?) {
        guard let view else { return }
        addArrangedSubview(view)
    }
    
    func addArrangedSubviews(_ views: UIView?...) {
        views.forEach {
            addArrangedSubview($0)
        }
    }
    
    func removeArrangedSubviews() {
        arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    func hideArrangedSubviews() {
        arrangedSubviews.forEach {
            $0.isHidden = true
        }
    }
    
    func showArrangedSubviews() {
        arrangedSubviews.forEach {
            $0.isHidden = false
        }
    }
    
}
