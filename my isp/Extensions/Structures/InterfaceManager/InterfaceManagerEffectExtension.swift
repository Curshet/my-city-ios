import UIKit

extension InterfaceManagerEffect {
    
    private var isLightMode: Bool {
        InterfaceManager.entry.information.isLightMode
    }
    
    func themeBlur() -> UIBlurEffect {
        UIBlurEffect(style: isLightMode ? .light : .dark)
    }
    
    func themeUltraThinMaterialBlur() -> UIBlurEffect {
        UIBlurEffect(style: isLightMode ? .systemUltraThinMaterialLight : .systemUltraThinMaterialDark)
    }
    
}
