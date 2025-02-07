import UIKit

extension CAGradientLayer {
    
    static var interfaceManager: InterfaceManagerGradient {
        InterfaceManager.entry.model.gradient
    }
    
    static func create(_ direction: UIRectEdge, colors: [UIColor], frame: CGRect, corner: CGFloat, file: String = #file, line: Int = #line) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.cornerRadius = corner
        gradient.colors = colors.map { $0.cgColor }

        switch direction {
            case .top:
                gradient.startPoint = CGPoint(x: 0, y: 1)
                gradient.endPoint = CGPoint(x: 0, y: 0)
            
            case .bottom:
                gradient.startPoint = CGPoint(x: 1, y: 0)
                gradient.endPoint = CGPoint(x: 1, y: 1)
            
            case .left:
                gradient.startPoint = CGPoint(x: 0, y: 1)
                gradient.endPoint = CGPoint(x: 1, y: 1)
            
            case .right:
                gradient.startPoint = CGPoint(x: 1, y: 1)
                gradient.endPoint = CGPoint(x: 0, y: 0)
            
            default:
                gradient.logger.console(event: .error(info: "Incorrect creating direction value of gradient layer"), file: file, line: line)
        }
        
        return gradient
    }
    
}
