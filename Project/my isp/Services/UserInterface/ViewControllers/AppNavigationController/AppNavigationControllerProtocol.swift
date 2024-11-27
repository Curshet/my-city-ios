import UIKit
import Combine

protocol AppNavigationControllerProtocol: UINavigationController {
    var publisher: AnyPublisher<AppNavigationControllerDelegateEvent, Never> { get }
}
