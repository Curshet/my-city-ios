import Foundation

extension DispatchQueue {
    
    static func create(label: String, qos: DispatchQoS = .unspecified, attributes: DispatchQueue.Attributes = [], autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency = .inherit, target: DispatchQueue? = nil) -> DispatchQueue {
        let type = attributes.contains(.concurrent) ? "concurrent" : "serial"
        let name = "\(Bundle.main.identifier)." + "\(type)." + label
        return DispatchQueue(label: name, qos: qos, attributes: attributes, autoreleaseFrequency: autoreleaseFrequency, target: target)
    }
    
    /// Returns value which indicates that the queue is a target for execution
    var isTarget: Bool {
        let key = DispatchSpecificKey<String>()
        setSpecific(key: key, value: address)
        let result = DispatchQueue.getSpecific(key: key) != nil
        return result
    }
    
    /// Checking the current queue status before execution (to prevent a deadlock)
    func synchronous<T>(action: () throws -> T, file: String = #file, line: Int = #line) rethrows -> T {
        if isTarget {
            logger.console(event: .error(info: "Synchronous action causes a deadlock behaviour"), file: file, line: line)
            return try action()
        }
        
        return try sync(execute: action)
    }
    
    /// Checking the current queue status before execution (to prevent a deadlock)
    func synchronous(item: DispatchWorkItem?, file: String = #file, line: Int = #line) {
        guard let item else { return }

        if isTarget {
            logger.console(event: .error(info: "Synchronous action causes a deadlock behaviour"), file: file, line: line)
            item.perform()
            return
        }

        sync(execute: item)
    }
    
    /// Automatically switching on the necessary queue for execution if needed
    @preconcurrency func asynchronous(action: @escaping @Sendable () -> Void) {
        if isTarget {
            action()
            return
        }
        
        async(execute: action)
    }
    
    /// Automatically switching on the necessary queue for execution if needed
    func asynchronous(item: DispatchWorkItem?) {
        guard let item else { return }

        if isTarget {
            item.perform()
            return
        }

        async(execute: item)
    }
    
    func async(group: DispatchGroup?, item: DispatchWorkItem?) {
        guard let group, let item else { return }
        async(group: group, execute: item)
    }
    
    func asyncAndWait(item: DispatchWorkItem?) {
        guard let item else { return }
        asyncAndWait(execute: item)
    }
    
    @preconcurrency func asyncAfter(seconds: Double, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], action: @escaping @Sendable () -> Void) {
        asyncAfter(deadline: .now() + seconds, qos: qos, flags: flags, execute: action)
    }
    
    func asyncAfter(seconds: Double, item: DispatchWorkItem?) {
        guard let item else { return }
        asyncAfter(deadline: .now() + seconds, execute: item)
    }
    
}
