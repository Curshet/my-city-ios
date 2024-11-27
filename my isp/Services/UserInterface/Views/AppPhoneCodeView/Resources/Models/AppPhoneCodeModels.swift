import UIKit

// MARK: - AppPhoneCodeViewData
struct AppPhoneCodeViewData {
    let background: AppModalViewBackground
    var alert: AppPhoneCodeAlertViewData
}

// MARK: - AppPhoneCodeAlertViewData
struct AppPhoneCodeAlertViewData {
    let layout: AppPhoneCodeAlertViewLayout
    let header: AppPhoneCodeHeaderData
    var center: AppPhoneCodeCenterData
}

// MARK: - AppPhoneCodeHeaderData
struct AppPhoneCodeHeaderData {
    let layout: AppPhoneCodeHeaderViewLayout
    let title: String
    let subtitle: String
    let image: UIImage?
}

// MARK: - AppPhoneCodeCenterData
struct AppPhoneCodeCenterData {
    var layout: AppPhoneCodeCenterViewLayout
    let stack: AppPhoneCodeCenterStackViewInternalEvent
}

// MARK: - AppPhoneCodeCenterRepeat
struct AppPhoneCodeCenterRepeat {
    let layout: AppPhoneCodeCenterRepeatButtonLayout
    let title: String
    let isEnabled: Bool
}

// MARK: - AppPhoneCodeCenterStackData
struct AppPhoneCodeCenterStackData {
    let layout: AppPhoneCodeCenterStackViewLayout
    let target: AppPhoneCodeCenterStackTarget
    let label: AppPhoneCodeCenterLabelInternalEvent
}

// MARK: - AppPhoneCodeCenterStackTarget
enum AppPhoneCodeCenterStackTarget: Int {
    case four = 4
    case five = 5
}

// MARK: - AppPhoneCodeCenterLabelData
struct AppPhoneCodeCenterLabelData {
    let layout: AppPhoneCodeCenterLabelLayout
    let style: AppPhoneCodeCenterLabelStyle
}

// MARK: - AppPhoneCodeCenterLabelStyle
struct AppPhoneCodeCenterLabelStyle {
    let symbol: String
    let symbolColor: UIColor
    let textColor: UIColor
}
