import UIKit

extension InterfaceManagerGradient {
    
    private var isLightMode: Bool {
        InterfaceManager.entry.information.isLightMode
    }

    func lightViolet(frame: CGRect, corner: CGFloat, direction: UIRectEdge = .left) -> CAGradientLayer {
        let one = UIColor.create(hex: "#E1569B")
        let two = UIColor.create(hex: "#CE4E9A")
        let three = UIColor.create(hex: "#A63E97")
        let four = UIColor.create(hex: "#8A3395")
        let five = UIColor.create(hex: "#782C93")
        let six = UIColor.create(hex: "#722993")
        let colors = [one, two, three, four, five, six]
        let gradient = CAGradientLayer.create(direction, colors: colors, frame: frame, corner: corner)
        return gradient
    }
    
    func darkViolet(frame: CGRect, corner: CGFloat, direction: UIRectEdge = .left) -> CAGradientLayer {
        let one = UIColor.create(hex: "#2B1046")
        let two = UIColor.create(hex: "#410C58")
        let colors = [one, two]
        let gradient = CAGradientLayer.create(direction, colors: colors, frame: frame, corner: corner)
        return gradient
    }
    
    func themeViolet(frame: CGRect, corner: CGFloat, direction: UIRectEdge = .left) -> CAGradientLayer {
        isLightMode ? lightViolet(frame: frame, corner: corner, direction: direction) : darkViolet(frame: frame, corner: corner, direction: direction)
    }
    
}
