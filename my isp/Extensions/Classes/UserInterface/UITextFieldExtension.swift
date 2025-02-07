import UIKit

extension UITextField {
    
    func padding(_ side: UITextFieldSide, _ mode: UITextField.ViewMode = .always) {
        switch side {
            case .left(let width):
                leftView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: bounds.size.height))
                leftViewMode = mode

            case .right(let width):
                rightView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: bounds.size.height))
                rightViewMode = mode
        }
    }

    func placeholderColor(_ color: UIColor) {
        attributedPlaceholder = NSAttributedString(string: placeholder ?? .clear, attributes: [NSAttributedString.Key.foregroundColor : color])
    }
    
}

// MARK: - UITextFieldSide
enum UITextFieldSide {
    case left(CGFloat)
    case right(CGFloat)
}
