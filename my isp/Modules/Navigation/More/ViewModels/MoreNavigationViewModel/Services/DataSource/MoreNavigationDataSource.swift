import UIKit

class MoreNavigationDataSource: MoreNavigationDataSourceProtocol {

    var tabBarItem: UITabBarItem {
        let title = String.localized.menuMore
        let image = UIImage.menuMoreItemUnselected.withRenderingMode(.alwaysOriginal)
        let selectedImage = UIImage.menuMoreItemSelected.withRenderingMode(.alwaysOriginal)
        let item = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        item.tag = 3
        return item
    }
    
}
