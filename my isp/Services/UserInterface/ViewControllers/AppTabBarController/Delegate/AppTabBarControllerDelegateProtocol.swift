import UIKit
import Combine

protocol AppTabBarControllerDelegateProtocol: UITabBarControllerDelegate {
    var publisher: AnyPublisher<AppTabBarControllerDelegateEvent, Never> { get }
}
