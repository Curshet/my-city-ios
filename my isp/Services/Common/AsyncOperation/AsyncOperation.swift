import Foundation

final class AsyncOperation: Operation {
    
    var block: (() -> Void)? {
        willSet {
            guard !еxecuting else {
                logger.console(event: .error(info: "Async operation block can’t be changed during execution"))
                return
            }
        }
    }
    
    override var isAsynchronous: Bool {
        true
    }

    override var isExecuting: Bool {
        еxecuting
    }

    override var isFinished: Bool {
        finishеd
    }
    
    private var еxecuting: Bool
    private var finishеd: Bool
    
    init(block: (() -> Void)? = nil) {
        self.еxecuting = false
        self.finishеd = false
        self.block = block
        super.init()
    }

    override func start() {
        guard !isCancelled else {
            finish()
            return
        }
        
        willChangeValue(forKey: "isExecuting")
        еxecuting = true
        didChangeValue(forKey: "isExecuting")
        main()
    }
    
    override func main() {
        guard !isCancelled else {
            finish()
            return
        }
        
        block?()
    }

    /// Required call inside the asynchronous action
    func finish() {
        willChangeValue(forKey: "isExecuting")
        еxecuting = false
        didChangeValue(forKey: "isExecuting")
        
        willChangeValue(forKey: "isFinished")
        finishеd = true
        didChangeValue(forKey: "isFinished")
    }
    
}
