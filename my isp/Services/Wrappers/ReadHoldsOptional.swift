import Foundation

@propertyWrapper struct ReadHoldsOptional<T> {
    
    var wrappedValue: T? {
        mutating get {
            read()
        }
        
        set {
            write(newValue)
        }
    }
    
    private var value: T?
    private var mutable: Bool
    
    init() {
        self.mutable = true
    }
    
    private mutating func read() -> T? {
        mutable = false
        return value
    }
    
    private mutating func write(_ newValue: T?) {
        guard let newValue else {
            value = nil
            return
        }
        
        guard mutable else { return }
        value = newValue
    }
    
}
