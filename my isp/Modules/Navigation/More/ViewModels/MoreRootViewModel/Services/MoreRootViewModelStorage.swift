import Foundation
import Combine

class MoreRootViewModelStorage: MoreRootViewModelStorageProtocol {
    
    var dataPublisher: AnyPublisher<[MoreRootCollectionCellData], Never> {
        internalDataPublisher.eraseToAnyPublisher()
    }
    
    let internalDataPublisher = PassthroughSubject<[MoreRootCollectionCellData], Never>()
    
    func getData() {
        let supportItem = supportItem()
        let shareAppItem = shareAppItem()
        let appVersionItem = appVersionItem()
        let items = [supportItem, shareAppItem, appVersionItem]
        internalDataPublisher.send(items)
    }
    
}

// MARK: Private
private extension MoreRootViewModelStorage {
    
    func supportItem() -> MoreRootCollectionCellData {
        let title = "SUPPORT".localized
        let icon = MoreRootCollectionCellIcon.arrow
        return MoreRootCollectionCellData(title: title, subtitle: nil, icon: icon)
    }
    
    func shareAppItem() -> MoreRootCollectionCellData {
        let title = "SHARE_APPLICATION".localized
        let icon = MoreRootCollectionCellIcon.share
        return MoreRootCollectionCellData(title: title, subtitle: nil, icon: icon)
    }
    
    func appVersionItem() -> MoreRootCollectionCellData {
        let title = "APP_VERSION".localized + " \(appInfo.version)"
        let subtitle = "DEVICE".localized + ": \(appInfo.deviceModel)"
        let icon = MoreRootCollectionCellIcon.copy
        return MoreRootCollectionCellData(title: title, subtitle: subtitle, icon: icon)
    }
    
}
