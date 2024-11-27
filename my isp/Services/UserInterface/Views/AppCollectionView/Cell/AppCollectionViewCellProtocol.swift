import UIKit
import Combine

protocol AppCollectionViewCellProtocol: UICollectionViewCell {
    associatedtype View: UIView
    associatedtype Data
    
    var internalEventPublisher: PassthroughSubject<AppCollectionViewCellInternalEvent<View, Data>, Never> { get }
}
