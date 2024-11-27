import Foundation
import MetricKit

final class MetricManager: MetricManagerProtocol {
    
    static let entry = MetricManager()
    
    private let logger: LoggingManager
    private let systemMetricManager: MXMetricManagerProtocol
    
    private init() {
        self.logger = LoggingManager.entry
        self.systemMetricManager = MXMetricManager.shared
    }
    
    /// Add object as system metric subscriber
    func addSubscriber(_ target: Any) {
        guard let subscriber = target as? MXMetricManagerSubscriber else {
            logger.console(event: .error(info: MetricManagerMessage.subscriberError))
            return
        }
        
        systemMetricManager.add(subscriber)
    }
    
    /// Remove object as system metric subscriber
    func removeSubscriber(_ target: Any) {
        guard let subscriber = target as? MXMetricManagerSubscriber else {
            logger.console(event: .error(info: MetricManagerMessage.removingError))
            return
        }
        
        systemMetricManager.remove(subscriber)
    }
    
    /// Creating system metric log
    func create(type: OSSignpostType, category: String, name: StaticString) {
        guard !category.isEmpty(), !category.isEmptyContent else {
            logger.console(event: .error(info: MetricManagerMessage.categoryError))
            return
        }
            
        let log = MXMetricManager.makeLogHandle(category: category)
        mxSignpost(type, log: log, name: name)
    }
    
    /// Sending system metric data to server
    func send(_ data: [any NSSecureCoding]) {
        guard !data.isEmpty else {
            logger.console(event: .error(info: MetricManagerMessage.contentError))
            return
        }
        
        if let metrics = data as? [MXMetricPayload], !metrics.isEmpty {
            metrics.forEach {
                let metricsDictionary = $0.dictionaryRepresentation()
                logger.console(event: .metric(.system, info: "📍 \(metricsDictionary) ✂️"))
            }
            
            return
        }
        
        guard #available(iOS 14.0, *) else {
            logger.console(event: .error(info: MetricManagerMessage.versionError))
            return
        }
        
        if let metrics = data as? [MXDiagnosticPayload], !metrics.isEmpty {
            metrics.forEach {
                let metricsDictionary = $0.dictionaryRepresentation()
                logger.console(event: .metric(.system, info: "📍 \(metricsDictionary) ✂️"))
            }
            
            return
        }
        
        logger.console(event: .error(info: MetricManagerMessage.dataError))
    }
    
}

// MARK: - MetricManagerMessage
fileprivate enum MetricManagerMessage {
    static let subscriberError = "Error adding object as metric subscriber"
    static let removingError = "Error removing object as metric subscriber"
    static let categoryError = "Error creating metric for empty or unavaliable name of category"
    static let contentError = "Error metric data array content"
    static let versionError = "Error getting metric, because device operating system version is lower than iOS 14"
    static let dataError = "Error getting metric data array"
}
