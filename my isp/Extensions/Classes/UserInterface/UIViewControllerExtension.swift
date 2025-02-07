import UIKit

extension UIViewController {
    
    var isVisible: Bool {
        if tabBarController != nil {
            return tabBarController?.selectedViewController === self && presentedViewController == nil
        }
        
        if navigationController != nil {
            return navigationController?.visibleViewController === self
        }
        
        return viewIfLoaded?.window != nil && presentedViewController == nil
    }
    
    var topViewController: UIViewController {
        if let tabBarController = self as? UITabBarController, let selectedViewController = tabBarController.selectedViewController {
            return selectedViewController.topViewController
        }
        
        if let navigationController = self as? UINavigationController {
            return (navigationController.visibleViewController ?? navigationController).topViewController
        }
        
        if let presentedViewController {
            return presentedViewController.topViewController
        }
        
        return self
    }
    
}
