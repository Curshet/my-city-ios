import Foundation

class AuthorizationPhoneRootDataCache: DataCache, AuthorizationPhoneRootDataCacheControlProtocol {
    
    var phone: String? {
        getData(key: typeName, type: String.self)
    }
    
    func saveData(_ value: String) {
        saveData(key: typeName, value: value)
    }
    
    func removeData() {
        removeData(.all)
    }
    
}
