import UIKit

extension InterfaceManagerFont {
    
    func sourceSansPro(type: UIFont.Weight, size: CGFloat) -> UIFont {
        let prefix = "SourceSansPro-"
        let suffix: String
        
        switch type {
            case .regular:
                suffix = "Regular"
            
            case .semibold:
                suffix = "SemiBold"
            
            default:
                suffix = .clear
        }
        
        return UIFont.create(name: prefix + suffix, size: size)
    }
    
}
