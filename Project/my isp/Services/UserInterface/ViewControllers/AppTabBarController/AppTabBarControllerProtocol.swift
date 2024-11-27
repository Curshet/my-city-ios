import UIKit
import Combine

protocol AppTabBarControllerProtocol: UITabBarController {
    var publisher: AnyPublisher<AppTabBarControllerDelegateEvent, Never> { get }
}
