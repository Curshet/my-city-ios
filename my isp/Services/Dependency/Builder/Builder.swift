import Foundation

class Builder: NSObject {
    
    let injector: InjectorProtocol
    
    init(injector: InjectorProtocol) {
        self.injector = injector
        super.init()
    }
    
    final func error<Input, Output>(of type: Input.Type, file: String = #file, line: Int = #line) -> Output? {
        logger.console(event: .error(info: "Resolving process error for type: \(type)"), file: file, line: line)
        return nil
    }
    
    final func error<Input>(of type: Input.Type, file: String = #file, line: Int = #line) {
        logger.console(event: .error(info: "Resolving process error for type: \(type)"), file: file, line: line)
    }
    
}
