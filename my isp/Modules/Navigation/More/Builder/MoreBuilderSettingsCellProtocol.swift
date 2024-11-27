import UIKit

protocol MoreBuilderSettingsCellProtocol: AnyObject {
    func securityCell(_ collectionView: UICollectionView, _ indexPath: IndexPath, _ data: Any?, _ action: ((MoreSettingsViewModelSelectEvent) -> Void)?) -> MoreSettingsSecurityCell?
}
