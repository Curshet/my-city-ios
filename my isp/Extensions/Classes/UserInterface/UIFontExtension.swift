import UIKit

extension UIFont {
    
    static var interfaceManager: InterfaceManagerFont {
        InterfaceManager.entry.model.font
    }
        
    static func create(name: String, size: CGFloat) -> UIFont {
        UIFont(name: name, size: size) ?? .systemFont(ofSize: size)
    }

}
