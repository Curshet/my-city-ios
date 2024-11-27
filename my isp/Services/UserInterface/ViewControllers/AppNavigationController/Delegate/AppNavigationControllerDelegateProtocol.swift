import UIKit
import Combine

protocol AppNavigationControllerDelegateProtocol: UINavigationControllerDelegate {
    var publisher: AnyPublisher<AppNavigationControllerDelegateEvent, Never> { get }
}
