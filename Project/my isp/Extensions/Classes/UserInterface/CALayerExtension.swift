import UIKit

extension CALayer {
    
    var image: UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: frame.width, height: frame.height))
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        self.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
