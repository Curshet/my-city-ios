import UIKit

protocol MoreBuilderSupportCellProtocol: AnyObject {
    func supportPhoneCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ data: Any?, _ action: ((MoreSupportViewModelSelectEvent) -> Void)?) -> MoreSupportPhoneCell?
    func supportMessengersCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ data: Any?, _ action: ((MoreSupportViewModelSelectEvent) -> Void)?) -> MoreSupportMessengersCell?
}
