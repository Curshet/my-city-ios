import UIKit
import Combine

protocol CatalogRootCollectionViewProtocol: UIView {
    var dataPublisher: PassthroughSubject<CatalogRootViewLayout, Never> { get }
}
