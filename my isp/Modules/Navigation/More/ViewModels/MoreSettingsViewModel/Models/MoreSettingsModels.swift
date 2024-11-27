import Foundation

// MARK: - MoreSettingsViewData
struct MoreSettingsViewData {
    let layout: MoreSettingsViewLayout
    let items: [Any]
}

// MARK: - MoreSettingsViewUpdateData
struct MoreSettingsViewUpdateData {
    let indexPath: IndexPath
    let items: [Any]
}

// MARK: - MoreSettingsSecurityCellContent
struct MoreSettingsSecurityCellContent {
    let data: Any
    let action: ((MoreSettingsViewModelSelectEvent) -> Void)?
}

// MARK: - MoreSettingsSecurityCellData
struct MoreSettingsSecurityCellData {
    let layout: MoreSettingsSecurityCellLayout
    let header: String
    var biometrics: MoreSettingsSecuritySectionData
    var password: MoreSettingsSecuritySectionData
}

// MARK: - MoreSettingsSecuritySectionData
struct MoreSettingsSecuritySectionData {
    var layout: MoreSettingsSecuritySectionLayout
    let title: String
    let subtitle: String
    let isOn: Bool
}
