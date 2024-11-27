import Foundation

@propertyWrapper struct ReadHoldsValue<T> {
    
    var wrappedValue: T {
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
    
    private mutating func read() -> T {
        guard let value else {
            fatalError("Invalid value of property wrapper")
        }
        
        mutable = false
        return value
    }
    
    private mutating func write(_ newValue: T) {
        guard mutable else { return }
        value = newValue
    }
    
}
