import UIKit

protocol MoreBuilderRootCellProtocol: AnyObject {
    func rootNavigationCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ data: Any?, _ action: ((MoreRootViewModelSelectEvent) -> Void)?) -> MoreRootNavigationCell?
    func rootSystemInfoCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ data: Any?, _ action: ((MoreRootViewModelSelectEvent) -> Void)?) -> MoreRootSystemInfoCell?
}
