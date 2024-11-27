import Foundation

protocol DataCacheControlProtocol: DataCacheInfoProtocol {
    func saveCache<T: AnyObject>(key: String, value: T)
    func saveData<T>(key: String, value: T)
    func removeCache(_ target: DataCacheRemove)
    func removeData(_ target: DataCacheRemove)
}
