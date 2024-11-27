import Foundation

protocol MoreRootDataCacheItemsProtocol: AnyObject {
    var items: [Any]? { get }
    func saveData(_ value: MoreRootViewItems)
}
