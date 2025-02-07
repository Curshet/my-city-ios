import UIKit
import Combine

protocol AppCollectionViewDelegateProtocol: UICollectionViewDelegate {
    var publisher: AnyPublisher<AppCollectionViewDelegateEventType, Never> { get }
}
