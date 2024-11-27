import UIKit

// MARK: - ProfileRootViewData
struct ProfileRootViewData {
    let header: ProfileRootHeaderData
    var center: ProfileRootCenterData
}

// MARK: - ProfileRootHeaderData
struct ProfileRootHeaderData {
    let layout: ProfileRootHeaderViewLayout
    let image: UIImage?
    let icon: UIImage?
    let background: UIImage?
}

// MARK: - ProfileRootCenterData
struct ProfileRootCenterData {
    var layout: ProfileRootCenterViewLayout
    let indexPath: IndexPath?
    let items: [Any]
}

// MARK: - ProfileRootCenterUserInfoCellContent
struct ProfileRootCenterUserInfoCellContent {
    let data: Any
    let action: ((ProfileRootCenterViewExternalEvent) -> Void)?
}

// MARK: - ProfileRootCenterUserInfoCellData
struct ProfileRootCenterUserInfoCellData {
    let layout: ProfileRootCenterUserInfoCellLayout
    var phone: ProfileRootCenterUserInfoSectionData
    var name: ProfileRootCenterUserInfoSectionData
}

// MARK: - ProfileRootCenterUserInfoSectionData
struct ProfileRootCenterUserInfoSectionData {
    var layout: ProfileRootCenterUserInfoSectionLayout
    let title: String
    let subtitle: String
    let icon: UIImage?
}

// MARK: - ProfileRootCenterLogoutCellContent
struct ProfileRootCenterLogoutCellContent {
    let data: Any
    let action: ((ProfileRootCenterViewExternalEvent) -> Void)?
}

// MARK: - ProfileRootCenterLogoutCellData
struct ProfileRootCenterLogoutCellData {
    let layout: ProfileRootCenterLogoutCellLayout
    let exitTitle: String
    let deleteTitle: String
}
