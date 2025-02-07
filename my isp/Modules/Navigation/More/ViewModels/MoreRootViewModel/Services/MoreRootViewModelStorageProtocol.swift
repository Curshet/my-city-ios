import Foundation
import Combine

protocol MoreRootViewModelStorageProtocol: ServiceProtocol {
    var dataPublisher: AnyPublisher<[MoreRootCollectionCellData], Never> { get }
    func getData()
}
