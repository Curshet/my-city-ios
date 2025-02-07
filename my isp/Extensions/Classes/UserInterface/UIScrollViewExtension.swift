import UIKit

extension UIScrollView {
    
    func scroll(to: UIRectEdge, animated: Bool = true, file: String = #file, line: Int = #line) {
        switch to {
            case .top:
                let offset = CGPoint(x: contentOffset.x, y: -contentInset.top)
                setContentOffset(offset, animated: animated)
            
            case .bottom:
                let offset = CGPoint(x: contentOffset.x, y: max(0, contentSize.height - bounds.height) + contentInset.bottom)
                setContentOffset(offset, animated: animated)
        
            case .left:
                let offset = CGPoint(x: -contentInset.left, y: contentOffset.y)
                setContentOffset(offset, animated: animated)
            
            case .right:
                let offset = CGPoint(x: max(0, contentSize.width - bounds.width) + contentInset.right, y: contentOffset.y)
                setContentOffset(offset, animated: animated)

            default:
                logger.console(event: .error(info: "Incorrect scrolling direction value"), file: file, line: line)
        }
    }
    
}
