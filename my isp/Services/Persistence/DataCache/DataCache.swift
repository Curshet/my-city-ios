import Foundation

class DataCache: NSObject, DataCacheControlProtocol {

    private var data: [String : Any]
    private let cache: NSCache<NSString, AnyObject>
    private let dataQueue: DispatchQueue
    private let cacheQueue: DispatchQueue
    
    override init() {
        self.data = [String : Any]()
        self.cache = NSCache<NSString, AnyObject>()
        self.dataQueue = DispatchQueue.create(label: "dataCache.data", qos: .userInitiated, attributes: .concurrent)
        self.cacheQueue = DispatchQueue.create(label: "dataCache.cache", qos: .userInitiated, attributes: .concurrent)
        super.init()
    }
    
}

// MARK: Protocol
extension DataCache {
    
    /// Returns permanent data cache
    func getData<T>(key: String, type: T.Type) -> T? {
        guard !key.isEmpty() else {
            logger.console(event: .error(info: logger.console(event: .error(info: DataCacheMessage.readingDataKeyError))))
            return nil
        }
        
        var value: T?
        
        dataQueue.sync {
            value = data[key] as? T
        }
        
        guard let value else {
            logger.console(event: .error(info: DataCacheMessage.readingDataError + key))
            return nil
        }
        
        return value
    }
    
    /// Saving permanent data cache
    func saveData<T>(key: String, value: T) {
        guard !key.isEmpty() else {
            logger.console(event: .error(info: DataCacheMessage.savingDataKeyError))
            return
        }
        
        dataQueue.async(flags: .barrier) { [weak self] in
            self?.data[key] = value
        }
    }
    
    // Removing permanent data cache
    func removeData(_ target: DataCacheRemove) {
        dataQueue.async(flags: .barrier) { [weak self] in
            switch target {
                case .key(let value):
                    guard !value.isEmpty() else {
                        self?.logger.console(event: .error(info: DataCacheMessage.removingDataKeyError))
                        return
                    }
                
                    self?.data[value] = nil
                
                case .all:
                    self?.data.removeAll()
            }
        }
    }
    
    /// Returns temporary cache (perhaps already deleted by system)
    func getCache<T: AnyObject>(key: String, type: T.Type) -> T? {
        guard !key.isEmpty() else {
            logger.console(event: .error(info: DataCacheMessage.readingCacheKeyError))
            return nil
        }
        
        var value: T?
        
        cacheQueue.sync {
            value = cache.object(forKey: NSString(string: key)) as? T
        }
        
        guard let value else {
            logger.console(event: .error(info: DataCacheMessage.readingCacheError + key))
            return nil
        }
        
        return value
    }
    
    /// Saving temporary cache (can be deleted by system)
    func saveCache<T: AnyObject>(key: String, value: T) {
        guard !key.isEmpty() else {
            logger.console(event: .error(info: DataCacheMessage.savingCacheKeyError))
            return
        }
        
        cacheQueue.async(flags: .barrier) { [weak self] in
            self?.cache.setObject(value, forKey: NSString(string: key))
        }
    }
    
    /// Removing temporary cache
    func removeCache(_ target: DataCacheRemove) {
        cacheQueue.async(flags: .barrier) { [weak self] in
            switch target {
                case .key(let value):
                    guard !value.isEmpty() else {
                        self?.logger.console(event: .error(info: DataCacheMessage.removingCacheKeyError))
                        return
                    }
                
                    self?.cache.removeObject(forKey: NSString(string: value))
                
                case .all:
                    self?.cache.removeAllObjects()
            }
        }
    }
    
}

// MARK: - DataCacheMessage
fileprivate enum DataCacheMessage {
    static let readingDataKeyError = "Reading permanent data cache error for empty key"
    static let readingDataError = "Reading permanent data cache error for key: "
    static let savingDataKeyError = "Saving permanent data cache error for empty key"
    static let removingDataKeyError = "Removing permanent data cache error for empty key"
    static let readingCacheKeyError = "Reading temporary data cache error for empty key"
    static let readingCacheError = "Reading temporary data cache error for key: "
    static let savingCacheKeyError = "Saving temporary data cache error for empty key"
    static let removingCacheKeyError = "Removing temporary data cache error for empty key"
}

// MARK: - DataCacheRemove
enum DataCacheRemove {
    case key(String)
    case all
}
