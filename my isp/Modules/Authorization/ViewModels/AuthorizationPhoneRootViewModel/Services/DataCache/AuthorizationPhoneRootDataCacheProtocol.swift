import Foundation

protocol AuthorizationPhoneRootDataCacheControlProtocol: AuthorizationPhoneCodeDataCacheInfoProtocol {
    func saveData(_ value: String)
    func removeData()
}
