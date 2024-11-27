import UIKit

// MARK: - MoreRootViewData
struct MoreRootViewData {
    let layout: MoreRootViewLayout
    let items: MoreRootViewItems
}

// MARK: - MoreRootViewItems
struct MoreRootViewItems {
    let values: [Any]
    let sizes: [CGSize]
}

// MARK: - MoreRootNavigationCellContent
struct MoreRootNavigationCellContent {
    let data: Any
    let action: ((MoreRootViewModelSelectEvent) -> Void)?
}

// MARK: - MoreRootNavigationCellData
struct MoreRootNavigationCellData {
    let layout: MoreRootNavigationCellLayout
    let event: MoreRootViewModelSelectEvent
    let title: String
    let icon: MoreRootNavigationCellActionIcon
}

// MARK: - MoreRootNavigationCellActionIcon
enum MoreRootNavigationCellActionIcon {
    case arrow(UIImage?)
    case share(UIImage?)
}

// MARK: - MoreRootSystemInfoCellContent
struct MoreRootSystemInfoCellContent {
    let data: Any
    let action: ((MoreRootViewModelSelectEvent) -> Void)?
}

// MARK: - MoreRootSystemInfoCellData
struct MoreRootSystemInfoCellData {
    let layout: MoreRootSystemInfoCellLayout
    let title: String
    let subtitle: String
    let icon: UIImage?
}
