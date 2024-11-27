import UIKit

extension UIApplication: ApplicationProtocol {
    
    #if DEBUG
    static let isDebug = true
    #else
    static let isDebug = false
    #endif
    
    func open(path: String?, options: [UIApplication.OpenExternalURLOptionsKey : Any] = [:], completion: ((Bool) -> Void)? = nil, file: String = #file, line: Int = #line) {
        guard let path, !path.isEmpty() else {
            logger.console(event: .error(info: "Application opening error for empty path"), file: file, line: line)
            completion?(false)
            return
        }
        
        guard let url = URL(string: path) else {
            logger.console(event: .error(info: "Application can't open the wrong URL: \(path)"), file: file, line: line)
            completion?(false)
            return
        }
        
        DispatchQueue.main.asynchronous {
            guard self.canOpenURL(url) else {
                self.logger.console(event: .error(info: "Application can't open the URL: \(path)"), file: file, line: line)
                completion?(false)
                return
            }
            
            self.logger.console(event: .success(info: "Application opened the path: \"\(path)\""), file: file, line: line)
            self.open(url, options: options, completionHandler: completion)
        }
    }
    
}
