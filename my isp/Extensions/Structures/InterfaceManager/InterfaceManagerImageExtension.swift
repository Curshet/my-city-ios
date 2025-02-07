import UIKit

extension InterfaceManagerImage {
    
    func themeNavigationBar(frame: CGRect) -> UIImage? {
        CAGradientLayer.interfaceManager.themeViolet(frame: frame, corner: .zero).image
    }
    
}
