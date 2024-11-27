import Foundation

@propertyWrapper struct ImmutableOptional<T> {
    
    var wrappedValue: T? {
        get {
            value
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
    
    private mutating func write(_ newValue: T?) {
        guard let newValue else {
            value = nil
            return
        }
        
        guard mutable else { return }
        mutable = false
        value = newValue
    }
    
}
