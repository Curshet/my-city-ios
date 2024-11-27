import UIKit
import Combine

protocol ActionTargetControlProtocol: AnyObject {
    var control: UIControl? { get set }
    var publisher: AnyPublisher<UIControl.Event, Never> { get }
    func addTarget(_ event: UIControl.Event)
    func removeTarget(_ event: UIControl.Event)
}
