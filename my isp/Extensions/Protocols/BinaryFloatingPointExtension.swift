import UIKit

extension BinaryFloatingPoint {
    
    static var interfaceManager: InterfaceManagerSize {
        InterfaceManager.entry.model.size
    }
    
    /// Using screen height adaptive value
    var fitHeight: Self {
        fitToSize(.height, with: nil)
    }
    
    /// Using screen width adaptive value
    var fitWidth: Self {
        fitToSize(.width, with: nil)
    }
    
    /// Using adaptive value by screen size with multiplier
    func fitToSize(_ target: BinaryFloatingFitTarget, with multiplier: Self?) -> Self {
        switch target {
            case .width:
                let divider = 320.0
                let coefficient = Self(UIScreen.main.bounds.width / divider)
                let value = self * coefficient
                guard let multiplier else { return value }
                return value * multiplier
            
            case .height:
                let divider = 568.0
                let coefficient = Self(UIScreen.main.bounds.height / divider)
                let value = self * coefficient
                guard let multiplier else { return value }
                return value * multiplier
        }
    }
    
}

// MARK: - BinaryFloatingFitTarget
enum BinaryFloatingFitTarget {
    case height
    case width
}
