import Foundation
import MetricKit

protocol MetricManagerProtocol {
    func addSubscriber(_ target: Any)
    func removeSubscriber(_ target: Any)
    func create(type: OSSignpostType, category: String, name: StaticString)
    func send(_ data: [any NSSecureCoding])
}
