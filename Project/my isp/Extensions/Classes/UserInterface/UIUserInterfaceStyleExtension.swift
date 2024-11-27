import UIKit

extension UIUserInterfaceStyle {
    
    var description: String {
        switch self {
            case .light:
                "light"
            
            case .dark:
                "dark"

            case .unspecified:
                "unspecified"
            
            default:
                "unknown"
        }
    }
    
}
