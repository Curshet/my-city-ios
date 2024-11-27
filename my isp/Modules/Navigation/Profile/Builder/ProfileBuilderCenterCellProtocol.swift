import UIKit

protocol ProfileBuilderCenterCellProtocol: AnyObject {
    func centerUserInfoCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ data: Any?, _ action: ((ProfileRootCenterViewExternalEvent) -> Void)?) -> ProfileRootCenterUserInfoCell?
    func centerLogoutCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ data: Any?, _ action: ((ProfileRootCenterViewExternalEvent) -> Void)?) -> ProfileRootCenterLogoutCell?
}
