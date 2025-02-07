import Foundation

@propertyWrapper struct ImmutableValue<T> {
    
    var wrappedValue: T {
        get {
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
    
    private func read() -> T {
        guard let value else {
            fatalError("Invalid value of property wrapper")
        }
        
        return value
    }
    
    private mutating func write(_ newValue: T) {
        guard mutable else { return }
        mutable = false
        value = newValue
    }
    
}
