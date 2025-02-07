import Foundation

class MoreRootDataCache: DataCache, MoreRootDataCacheControlProtocol {
    
    var contacts: MoreSupportContacts? {
        getData(key: MoreRootDataCacheKeys.contacts, type: MoreSupportContacts.self)
    }

    func saveData(_ value: MoreSupportContacts?) {
        saveData(key: MoreRootDataCacheKeys.contacts, value: value)
    }
    
}

// MARK: MoreRootDataCacheItemsProtocol
extension MoreRootDataCache: MoreRootDataCacheItemsProtocol {
    
    var items: [Any]? {
        getData(key: MoreRootDataCacheKeys.items, type: MoreRootViewItems.self)?.values
    }
    
    func saveData(_ value: MoreRootViewItems) {
        saveData(key: MoreRootDataCacheKeys.items, value: value)
    }
    
}

// MARK: MoreRootDataCacheSizesProtocol
extension MoreRootDataCache: MoreRootDataCacheSizesProtocol {
    
    var sizes: [CGSize]? {
        getData(key: MoreRootDataCacheKeys.items, type: MoreRootViewItems.self)?.sizes
    }
    
}

// MARK: - MoreRootDataCacheKeys
fileprivate enum MoreRootDataCacheKeys {
    static let contacts = "Contacts"
    static let items = "Items"
}
