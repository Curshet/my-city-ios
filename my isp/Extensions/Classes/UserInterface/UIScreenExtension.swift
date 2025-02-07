import UIKit

extension UIScreen: ScreenProtocol {

    var isLegacyPhone: Bool {
        bounds.width == 320
    }
    
    var isLightMode: Bool {
        InterfaceManager.entry.information.isLightMode
    }
    
    var systemStyle: UIUserInterfaceStyle {
        traitCollection.userInterfaceStyle
    }
    
}
