import UIKit

protocol MoreBuilderRoutingProtocol: AnyObject {
    var supportViewController: MoreSupportViewController? { get }
    var settingsViewController: MoreSettingsViewController? { get }
    var shareViewController: MoreShareViewController? { get }
}
