import Foundation

protocol DataCacheInfoProtocol {
    func getCache<T: AnyObject>(key: String, type: T.Type) -> T?
    func getData<T>(key: String, type: T.Type) -> T?
}
