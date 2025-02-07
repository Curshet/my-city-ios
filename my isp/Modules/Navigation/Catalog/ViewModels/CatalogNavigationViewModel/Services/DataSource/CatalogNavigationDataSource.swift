import UIKit

class CatalogNavigationDataSource: CatalogNavigationDataSourceProtocol {
    
    var tabBarItem: UITabBarItem {
        let title = String.localized.menuCatalog
        let image = UIImage.menuCalalogItemUnselected.withRenderingMode(.alwaysOriginal)
        let selectedImage = UIImage.menuCalalogItemSelected.withRenderingMode(.alwaysOriginal)
        let item = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        item.tag = 0
        return item
    }
    
}
