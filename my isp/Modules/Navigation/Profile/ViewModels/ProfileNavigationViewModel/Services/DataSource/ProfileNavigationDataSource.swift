import UIKit

class ProfileNavigationDataSource: ProfileNavigationDataSourceProtocol {
    
    var tabBarItem: UITabBarItem {
        let title = String.localized.menuProfile
        let image = UIImage.menuProfileItemUnselected.withRenderingMode(.alwaysOriginal)
        let selectedImage = UIImage.menuProfileItemSelected.withRenderingMode(.alwaysOriginal)
        let item = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        item.tag = 1
        return item
    }
    
}
