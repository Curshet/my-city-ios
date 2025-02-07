import Foundation

extension OperationQueue {
    
    func addOperation(_ value: Operation?) {
        guard let value else { return }
        addOperation(value)
    }
    
    func addOperations(_ array: [Operation]?, waitUntilFinished: Bool) {
        guard let array else { return }
        addOperations(array, waitUntilFinished: waitUntilFinished)
    }
    
}
