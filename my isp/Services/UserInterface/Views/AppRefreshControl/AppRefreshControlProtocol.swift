import UIKit
import Combine

protocol AppRefreshControlProtocol: UIRefreshControl {
    var publisher: AnyPublisher<UIControl.Event, Never> { get }
    func addTarget(_ event: UIControl.Event...)
    func removeTarget(_ event: UIControl.Event...)
}
