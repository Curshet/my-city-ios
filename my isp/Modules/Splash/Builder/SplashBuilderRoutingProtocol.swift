import UIKit

protocol SplashBuilderRoutingProtocol: AnyObject {
    func window() -> UIWindow?
    func alertController(_ content: AlertContent) -> UIAlertController?
}
