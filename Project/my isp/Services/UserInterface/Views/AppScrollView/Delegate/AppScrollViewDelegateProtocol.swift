import UIKit
import Combine

protocol AppScrollViewDelegateProtocol: UIScrollViewDelegate {
    var publishеr: AnyPublisher<AppScrollViewDelegateEvent, Never> { get }
}
