import UIKit

// MARK: - MoreSupportViewData
struct MoreSupportViewData {
    let layout: MoreSupportViewLayout
    let items: [Any]
}

// MARK: - MoreSupportPhoneCellContent
struct MoreSupportPhoneCellContent {
    let data: Any
    let action: ((MoreSupportViewModelSelectEvent) -> Void)?
}

// MARK: - MoreSupportPhoneCellData
struct MoreSupportPhoneCellData {
    let layout: MoreSupportPhoneCellLayout
    let title: String
    let phone: String
    let icon: UIImage?
}

// MARK: - MoreSupportMessengersCellContent
struct MoreSupportMessengersCellContent {
    let data: Any
    let action: ((MoreSupportViewModelSelectEvent) -> Void)?
}

// MARK: - MoreSupportMessengersCellData
struct MoreSupportMessengersCellData {
    let layout: MoreSupportMessengersCellLayout
    let title: String
    let icons: [MoreSupportMessengerIcon]
}

// MARK: - MoreSupportMessengerIcon
enum MoreSupportMessengerIcon {
    case telegram(UIImage?)
    case whatsApp(UIImage?)
    case viber(UIImage?)
}

// MARK: - MoreSupportContacts
struct MoreSupportContacts: Decodable {
    let tel: String?
    let viber: String?
    let telegram: String?
    let whatsApp: String?
}
