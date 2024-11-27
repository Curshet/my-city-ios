import UIKit

// MARK: - MenuLoginShift
struct MenuLoginShift {
    let duration: Double
    let viewFrameOne: CGRect
    let viewFrameTwo: CGRect
    let keyViewFrame: CGRect
    let keyViewBrightness: CGFloat
    let message: String
}

// MARK: - MenuNavigationShift
struct MenuNavigationShift {
    let duration: Double
    let alpha: CGFloat
}
 
// MARK: - MenuPresenterData
enum MenuPresenterData {
    case setup(MenuPresenterSetupData)
    case update(MenuPresenterAppearance)
}

// MARK: - MenuPresenterSetupData
struct MenuPresenterSetupData {
    let shapeLayer: CAShapeLayer?
    let borderLayer: CALayer?
    let appearance: MenuPresenterAppearance
}

// MARK: - MenuPresenterAppearance
struct MenuPresenterAppearance {
    let isUsingFaceID: Bool
    let tintColor: UIColor
    let borderColor: CGColor
    let unselectedItemTintColor: UIColor
    let itemWidth: CGFloat
    let backgroundColor: UIColor
    let backgroundImage: UIImage
    let shadowImage: UIImage
    let shadowOpacity: Float
    let shadowRadius: CGFloat
    let shadowOffset: CGSize
}
