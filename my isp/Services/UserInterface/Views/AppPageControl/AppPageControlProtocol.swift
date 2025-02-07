import UIKit
import Combine

protocol AppPageControlProtocol: UIPageControl {
    var publisher: AnyPublisher<AppPageControlExternalEvent, Never> { get }
    func addTarget(_ event: UIControl.Event...)
    func removeTarget(_ event: UIControl.Event...)
}
