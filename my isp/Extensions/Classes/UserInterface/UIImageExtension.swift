import UIKit

extension UIImage {

    static var interfaceManager: InterfaceManagerImage {
        InterfaceManager.entry.model.image
    }

    static var clear: UIImage {
        UIImage()
    }
    
    static func create(data: Data?, scale: CGFloat = 1) -> UIImage {
        guard let data else { return .clear }
        let image = UIImage(data: data, scale: scale)
        return image ?? .clear
    }
    
    static func system(_ type: ImageSystemType, configuration: UIImage.SymbolConfiguration? = nil) -> UIImage {
        let icon = UIImage(systemName: type.rawValue)
        
        if let configuration, let image = icon?.withConfiguration(configuration) {
            return image
        }

        return icon?.setOpacity(1) ?? .clear
    }
    
    static func fill(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let rectangle = CGRect(origin: .zero, size: size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rectangle)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? .clear
    }

    func addText(_ text: String, font: UIFont, color: UIColor = .black, x: CGFloat, y: CGFloat, aligment: NSTextAlignment = .center) -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = x == .zero ? .center : aligment
        let textFontAttributes = [.font: font, .foregroundColor: color, .paragraphStyle: textStyle] as [NSAttributedString.Key : Any]
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        let rectangle = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: size.width - x, height: size.height))
        text.draw(in: rectangle, withAttributes: textFontAttributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func addImage(_ image: UIImage?, rectangle: CGRect? = nil) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, .zero)
        draw(in: CGRect(x: .zero, y: .zero, width: size.width, height: size.height))
        
        if let image = image {
            if let rectangle = rectangle {
                image.draw(in: rectangle)
            } else {
                image.draw(in: CGRect(x: .zero, y: .zero, width: size.width, height: size.height))
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func setOpacity(_ alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func setColor(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        context?.translateBy(x: .zero, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.colorBurn)
        let rectangle = CGRect(x: .zero, y: .zero, width: size.width, height: size.height)
        context?.draw(cgImage!, in: rectangle)
        context?.setBlendMode(CGBlendMode.sourceIn)
        context?.addRect(rectangle)
        context?.drawPath(using: CGPathDrawingMode.fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func roundedCorners(with radius: CGFloat?) -> UIImage {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        
        if let radius = radius, radius > .zero, radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rectangle = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rectangle, cornerRadius: cornerRadius).addClip()
        draw(in: rectangle)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? .clear
    }
    
    func rotated(to value: Measurement<UnitAngle>) -> UIImage {
        let degrees = CGFloat(value.converted(to: .degrees).value)
        let destRect = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: degrees))
        let roundedDestRect = CGRect(x: destRect.origin.x.rounded(), y: destRect.origin.y.rounded(), width: destRect.width.rounded(), height: destRect.height.rounded())
        UIGraphicsBeginImageContextWithOptions(roundedDestRect.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return .clear }
        context.translateBy(x: roundedDestRect.width / 2, y: roundedDestRect.height / 2)
        context.rotate(by: degrees)
        draw(in: CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? .clear
    }
    
    func withSize(width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, .zero)
        let frame = CGRect(origin: .zero, size: size)
        draw(in: frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? .clear
    }
    
    func brightness(by value: CGFloat) -> UIImage {
        guard let inputImage = CIImage(image: self), let filter = CIFilter(name: "CIExposureAdjust") else { return .clear }
        let context = CIContext(options: nil)
        filter.setValue(inputImage, forKey: "inputImage")
        filter.setValue(value, forKey: "inputEV")
        guard let filteredImage = filter.outputImage, let newImage = context.createCGImage(filteredImage, from: filteredImage.extent) else { return .clear }
        let image = UIImage(cgImage: newImage)
        return image
    }
    
}

// MARK: - ImageSystemType
enum ImageSystemType: String {
    case paperplane = "paperplane.fill"
    case camera = "camera.fill"
    case pencil = "square.and.pencil"
    case arrowLeft = "chevron.left"
    case arrowRight = "chevron.right"
    case share = "square.and.arrow.up"
    case copy = "doc.on.doc"
    case phone = "phone.fill"
    case xmark = "xmark"
    case xmarkFill = "xmark.circle.fill"
    case slider = "slider.horizontal.3"
}
