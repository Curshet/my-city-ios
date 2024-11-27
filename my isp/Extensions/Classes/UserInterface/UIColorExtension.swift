import UIKit

extension UIColor {
    
    static var interfaceManager: InterfaceManagerColor {
        InterfaceManager.entry.model.color
    }
    
    static func create(hex: String, alpha: CGFloat = 1) -> UIColor {
        guard !hex.isEmpty() else { return .clear }
        
        var hexString = hex.removeSymbols(" ", "\n").uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6 {
            return .clear
        }
        
        var rgb: UInt64 = .zero
        Scanner(string: hexString).scanHexInt64(&rgb)
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func withBrightness(_ value: CGFloat) -> UIColor {
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red = min(max(red + value * red, 0.0), 1.0)
        green = min(max(green + value * green, 0.0), 1.0)
        blue = min(max(blue + value * blue, 0.0), 1.0)
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
}
