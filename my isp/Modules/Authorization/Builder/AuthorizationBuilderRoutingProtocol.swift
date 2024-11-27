import UIKit

protocol AuthorizationBuilderRoutingProtocol: AnyObject {
    var window: UIWindow? { get }
    var phoneNavigationController: AppNavigationControllerProtocol? { get }
    var phoneCodeViewController: AuthorizationPhoneCodeViewController? { get }
}
