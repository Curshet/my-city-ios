import UIKit

// MARK: - AuthorizationLoginShift
struct AuthorizationLoginShift {
    let duration: Double
    let alpha: CGFloat
}

// MARK: - AuthorizationLogoutShift
struct AuthorizationLogoutShift {
    let duration: Double
    let viewFrameOne: CGRect
    let viewFrameTwo: CGRect
    let viewAlphaOne: CGFloat
    let viewAlphaTwo: CGFloat
    let keyViewFrame: CGRect
    let keyViewAlpha: CGFloat
}

// MARK: - AuthorizationViewData
struct AuthorizationViewData {
    let layout: AuthorizationViewLayout
    let header: AuthorizationHeaderData
    var center: AuthorizationCenterData
}

// MARK: - AuthorizationHeaderData
struct AuthorizationHeaderData {
    let layout: AuthorizationHeaderViewLayout
    let image: UIImage
    let text: String
}

// MARK: - AuthorizationCenterData
struct AuthorizationCenterData {
    var layout: AuthorizationCenterViewLayout
    let telegramIcon: UIImage
    let telegramTitle: String
    let separatingText: String
    let phoneTitle: String
}

// MARK: - AuthorizationNetworkRequest
struct AuthorizationNetworkRequest {
    let value: NetworkManagerRequest
    let phone: String
}

// MARK: - AuthorizationNetworkData
struct AuthorizationNetworkData: Decodable {
    let token: String?
    var phone: String?
}
