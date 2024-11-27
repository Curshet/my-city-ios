import UIKit

// MARK: - AuthorizationPhoneRootViewData
struct AuthorizationPhoneRootViewData {
    let layout: AuthorizationPhoneRootViewLayout
    let header: AuthorizationPhoneRootHeaderData
    var center: AuthorizationPhoneRootCenterData
}

// MARK: - AuthorizationPhoneRootHeaderData
struct AuthorizationPhoneRootHeaderData {
    let layout: AuthorizationPhoneRootHeaderViewLayout
    let title: String
    let subtitle: String
}

// MARK: - AuthorizationPhoneRootCenterData
struct AuthorizationPhoneRootCenterData {
    var layout: AuthorizationPhoneRootCenterViewLayout
    var textView: AuthorizationPhoneRootCenterTextViewData
    let enterTitle: String
    let returnTitle: String
}

// MARK: - AuthorizationPhoneRootCenterTextViewData
struct AuthorizationPhoneRootCenterTextViewData {
    let layout: AuthorizationPhoneRootCenterTextViewLayout
    let country: String
    var textField: AuthorizationPhoneRootCenterTextFieldData
}

// MARK: - AuthorizationPhoneRootCenterTextFieldData
struct AuthorizationPhoneRootCenterTextFieldData {
    var layout: AuthorizationPhoneRootCenterTextFieldLayout
    let placeholder: String
    let rightView: AuthorizationPhoneRootCenterTextRightViewData
}

// MARK: - AuthorizationPhoneRootCenterTextFieldState
struct AuthorizationPhoneRootCenterTextFieldState {
    let borderColor: CGColor
    let notify: AppUserNotificationType?
}

// MARK: - AuthorizationPhoneRootCenterTextRightViewData
struct AuthorizationPhoneRootCenterTextRightViewData {
    let layout: AuthorizationPhoneRootCenterTextRightViewLayout
    let image: UIImage?
}

// MARK: - AuthorizationPhoneRootNetworkRequest
struct AuthorizationPhoneRootNetworkRequest {
    let unique: Bool
    let triggerred: Bool
    let getFirst: NetworkManagerRequest
    let postPhone: NetworkManagerRequest
    let output: AuthorizationPhoneRootResponseData
}

// MARK: - AuthorizationPhoneRootResponseData
struct AuthorizationPhoneRootResponseData {
    let phone: String
    var timeInterval: Double
    let triggerred: Bool
}

// MARK: - AuthorizationPhoneRootNetworkData
struct AuthorizationPhoneRootNetworkData: Decodable {
    let status: String?
    let smsTimeInterval: Int?
}
