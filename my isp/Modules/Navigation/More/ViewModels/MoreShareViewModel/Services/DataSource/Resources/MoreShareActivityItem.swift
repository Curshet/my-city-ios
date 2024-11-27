import UIKit
import LinkPresentation

class MoreShareActivityItem: NSObject, UIActivityItemSource {
    
    private let title: String
    private let text: String
    
    init(title: String, text: String) {
        self.title = title
        self.text = text
        super.init()
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        return metadata
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        text
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        text
    }

}
