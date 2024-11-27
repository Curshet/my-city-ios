import UIKit

extension InterfaceManagerSize {
    
    private var isLightMode: Bool {
        InterfaceManager.entry.information.isLightMode
    }
    
}

// MARK: - Profile
extension InterfaceManagerSize {
    
    func themeProfileRootItemBorderWidth() -> CGFloat {
        isLightMode ? 0 : 0.5
    }
    
}

// MARK: - More
extension InterfaceManagerSize {
    
    func themeMoreRootItemBorderWidth() -> CGFloat {
        isLightMode ? 0 : 0.5
    }
    
    func themeMoreSupportItemBorderWidth() -> CGFloat {
        isLightMode ? 0 : 0.5
    }
    
    func themeMoreSettingsItemBorderWidth() -> CGFloat {
        isLightMode ? 0 : 0.5
    }
    
}

// MARK: - Common
extension InterfaceManagerSize {
    
    func themePhoneCodeCenterLabelBorderWidth() -> CGFloat {
        isLightMode ? 0 : 0.7
    }
    
}
