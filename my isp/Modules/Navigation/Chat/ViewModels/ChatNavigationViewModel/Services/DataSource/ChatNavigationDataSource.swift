import UIKit

class ChatNavigationDataSource: ChatNavigationDataSourceProtocol {
    
    var tabBarItem: UITabBarItem {
        let title = String.localized.menuChat
        let image = UIImage.menuChatItemUnselected.withRenderingMode(.alwaysOriginal)
        let selectedImage = UIImage.menuChatItemSelected.withRenderingMode(.alwaysOriginal)
        let item = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        item.tag = 2
        return item
    }
    
}
