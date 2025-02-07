import Foundation

class MoreShareDataSource: MoreShareDataSourceProtocol {
    
    var items: [MoreShareActivityItem] {
        let title = bundle.displayName
        let text = "\(String.localized.moreRecommendInstalling).\n\n" + URL.Service.appStore
        let items = [MoreShareActivityItem(title: title, text: text)]
        return items
    }
    
    private let bundle: BundleProtocol
    
    init(bundle: BundleProtocol) {
        self.bundle = bundle
    }
    
}
