import UIKit

extension InterfaceManagerColor {
    
    private var isLightMode: Bool {
        InterfaceManager.entry.information.isLightMode
    }
 
    func lightBackgroundOne(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#F3F6FA", alpha: alpha)
    }
    
    func lightBackgroundTwo(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#E5E5E5", alpha: alpha)
    }
    
    func darkBackgroundOne(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#1A1A25", alpha: alpha)
    }
    
    func darkBackgroundTwo(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#32323D", alpha: alpha)
    }
    
    func darkBackgroundThree(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#262631", alpha: alpha)
    }
    
    func white(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#FFFFFF", alpha: alpha)
    }

    func blackOne(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#333333", alpha: alpha)
    }
    
    func blackTwo(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#000000", alpha: alpha)
    }
    
    func lightGray(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#A8B4C3", alpha: alpha)
    }
    
    func grayOne(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#88888C", alpha: alpha)
    }
    
    func grayTwo(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#A1A3A9", alpha: alpha)
    }

    func grayThree(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#7D7E80", alpha: alpha)
    }

    func darkGray(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#434344", alpha: alpha)
    }
    
    func lightPink(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#E1569B", alpha: alpha)
    }
    
    func darkPink(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#92458A", alpha: alpha)
    }
    
    func red(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#E74326", alpha: alpha)
    }
    
    func green(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#4CAF50", alpha: alpha)
    }
    
    func blue(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#5945CE", alpha: alpha)
    }
    
    func lightPurple(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#BE4798", alpha: alpha)
    }
    
    func darkPurple(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "#823094", alpha: alpha)
    }
    
    func lightGraphite(alpha: CGFloat = 1) -> UIColor {
        UIColor.create(hex: "808084", alpha: alpha)
    }

    func themeBackgroundOne(alpha: CGFloat = 1) -> UIColor {
        isLightMode ? lightBackgroundOne(alpha: alpha) : darkBackgroundOne(alpha: alpha)
    }
    
    func themeBackgroundTwo(alpha: CGFloat = 1) -> UIColor {
        isLightMode ? white(alpha: alpha) : darkBackgroundTwo(alpha: alpha)
    }
    
    func themeBarButtonItem(alpha: CGFloat = 1) -> UIColor {
        isLightMode ? lightGray(alpha: alpha) : white(alpha: alpha)
    }
    
    func themeText(alpha: CGFloat = 1) -> UIColor {
        isLightMode ? darkGray(alpha: alpha) : white(alpha: alpha)
    }
    
}

// MARK: - Authorization
extension InterfaceManagerColor {
    
    func themeAuthorizationRootHeader() -> UIColor {
        isLightMode ? blackOne() : white()
    }
    
    func themeAuthorizationRootCenterSeparatingText() -> UIColor {
        isLightMode ? lightGray() : darkGray()
    }
    
    func themeAuthorizationRootCenterPhoneHighlitedTitle() -> UIColor {
        isLightMode ? lightGray() : darkGray()
    }
    
    func themeAuthorizationPhoneHeaderTitle() -> UIColor {
        isLightMode ? darkBackgroundOne() : white()
    }
    
    func themeAuthorizationPhoneHeaderSubtitle() -> UIColor {
        isLightMode ? grayOne() : lightGray()
    }
    
    func themeAuthorizationPhoneCenterPlaceholder() -> UIColor {
        isLightMode ? lightGray() : darkGray()
    }
    
    func themeAuthorizationPhoneCenterTextFieldBorder() -> UIColor {
        isLightMode ? grayOne() : grayThree()
    }
    
}

// MARK: - Menu
extension InterfaceManagerColor {
    
    func themeMenuTabBarBorder() -> UIColor {
        isLightMode ? lightGray() : darkGray()
    }
    
    func themeMenuTabBarBackground() -> UIColor {
        isLightMode ? white() : darkBackgroundThree()
    }
    
    func themeMenuTabBarTint() -> UIColor {
        isLightMode ? darkPink() : white()
    }
    
}

// MARK: - Profile
extension InterfaceManagerColor {
    
    func themeProfileRootCenterUserInfoCellBackground(alpha: CGFloat = 1) -> UIColor {
        isLightMode ? white() : darkBackgroundThree()
    }
    
    func themeProfileRootCenterUserInfoCellShadow() -> CGColor {
        isLightMode ? blackOne().cgColor : UIColor.clear.cgColor
    }
    
    func themeProfileRootCenterUserInfoCellTitle() -> UIColor {
        isLightMode ? darkGray() : lightBackgroundOne()
    }
    
    func themeProfileRootCenterUserInfoCellSubtitle() -> UIColor {
        isLightMode ? grayOne() : grayThree()
    }
    
    func themeProfileRootCenterUserInfoCellActionIcon() -> UIColor {
        isLightMode ? darkPink() : white()
    }
    
    func themeProfileRootCenterLogoutCellBackground() -> UIColor {
        isLightMode ? white() : darkBackgroundThree()
    }
    
    func themeProfileRootCenterLogoutCellShadow(alpha: CGFloat = 1) -> CGColor {
        isLightMode ? blackOne().cgColor : UIColor.clear.cgColor
    }
    
    func themeProfileRootCenterLogoutCellTitle(alpha: CGFloat = 1) -> UIColor {
        isLightMode ? darkGray() : lightBackgroundOne()
    }
    
}

// MARK: - Chat
extension InterfaceManagerColor {
    
    func themeChatTint() -> UIColor {
        isLightMode ? lightPurple() : blackOne()
    }
    
}

// MARK: - More
extension InterfaceManagerColor {
    
    func themeMoreRootNavigationCellBackground() -> UIColor {
        isLightMode ? white() : darkBackgroundThree()
    }
    
    func themeMoreRootNavigationCellShadow() -> CGColor {
        isLightMode ? darkGray().cgColor : UIColor.clear.cgColor
    }
    
    func themeMoreRootNavigationCellTitle() -> UIColor {
        isLightMode ? darkGray() : lightBackgroundOne()
    }
    
    func themeMoreRootNavigationCellActionIcon() -> UIColor {
        isLightMode ? grayOne() : lightBackgroundOne()
    }
    
    func themeMoreRootSystemInfoCellBackground() -> UIColor {
        isLightMode ? lightBackgroundOne() : darkBackgroundThree()
    }
    
    func themeMoreRootSystemInfoCellShadow() -> CGColor {
        isLightMode ? darkGray().cgColor : UIColor.clear.cgColor
    }
    
    func themeMoreRootSystemInfoCellTitle() -> UIColor {
        isLightMode ? darkGray() : lightBackgroundOne()
    }
    
    func themeMoreRootSystemInfoCellSubtitle() -> UIColor {
        isLightMode ? grayOne() : lightBackgroundOne()
    }
    
    func themeMoreRootSystemInfoCellActionIcon() -> UIColor {
        isLightMode ? grayOne() : lightBackgroundOne()
    }
    
    func themeMoreSupportCellBackground() -> UIColor {
        isLightMode ? white() : darkBackgroundThree()
    }
    
    func themeMoreSupportCellShadow() -> CGColor {
        isLightMode ? darkGray().cgColor : UIColor.clear.cgColor
    }
    
    func themeMoreSupportCellTitle() -> UIColor {
        isLightMode ? grayOne() : lightBackgroundOne()
    }
    
    func themeMoreSupportPhoneCellIcon() -> UIColor {
        isLightMode ? darkGray() : lightBackgroundOne()
    }
    
    func themeMoreSupportPhoneCellSubtitle() -> UIColor {
        isLightMode ? darkGray() : grayTwo()
    }
    
    func themeMoreSettingsSecurityCellBackground() -> UIColor {
        isLightMode ? white() : darkBackgroundThree()
    }
    
    func themeMoreSettingsSecurityCellShadow() -> CGColor {
        isLightMode ? blackOne().cgColor : UIColor.clear.cgColor
    }
    
    func themeMoreSettingsSecurityCellHeader() -> UIColor {
        isLightMode ? darkBackgroundOne() : white()
    }
    
    func themeMoreSettingsSecurityCellSectionTitle() -> UIColor {
        isLightMode ? darkGray() : lightBackgroundOne()
    }

    func themeMoreSettingsSecurityCellSectionSubtitle() -> UIColor {
        isLightMode ? grayOne() : grayThree()
    }
    
}

// MARK: - Common
extension InterfaceManagerColor {
    
    func themePhoneCodeEffectBackground() -> UIColor {
        isLightMode ? blackOne(alpha: 0.4) : .clear
    }
    
    func themePhoneCodeAlertBackground() -> UIColor {
        isLightMode ? white() : darkBackgroundOne(alpha: 0.9)
    }
    
    func themePhoneCodeCenterLabelBackground() -> UIColor {
        isLightMode ? UIColor.create(hex: "#E7EAF7") : UIColor.interfaceManager.darkBackgroundThree()
    }
    
}
