import UIKit

extension UILabel {
    
    func interlineSpacing(_ value: CGFloat) {
        let alignment = textAlignment
        let attributed = NSMutableAttributedString(string: text ?? .clear)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = value
        attributed.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributed.length))
        attributedText = attributed
        textAlignment = alignment
    }
    
}
