import Foundation

extension FileManager: FileManagerProtocol {
    
    func path(target: FileManagerDirectory) -> URL? {
        let url = urls(for: .documentDirectory, in: .userDomainMask).first
        
        switch target {
            case .common:
                return url
            
            case .catalog(let name):
                guard !name.isEmpty() else { return url }
                return url?.appendingPathComponent(name)
        }
    }
    
    @discardableResult func createDirectory(name: String) -> URL? {
        guard !name.isEmpty(), !name.isEmptyContent else {
            logger.console(event: .error(info: FileManagerMessage.directoryNameError))
            return nil
        }
        
        guard let url = path(target: .catalog(name)) else {
            logger.console(event: .error(info: FileManagerMessage.directoryPathError))
            return nil
        }
        
        guard !fileExists(atPath: url.path) else { return url }
        
        do {
            try createDirectory(atPath: url.path, withIntermediateDirectories: true)
            return url
        } catch {
            logger.console(event: .error(info: FileManagerMessage.directoryCreatingError + String(error)))
            return nil
        }
    }
    
}

// MARK: - FileManagerMessage
fileprivate enum FileManagerMessage {
    static let directoryNameError = "File manager directory creating error for empty or unavaliable name"
    static let directoryPathError = "File manager directory creating error for unavaliable URL"
    static let directoryCreatingError = "File manager directory creating error: "
}

// MARK: - FileManagerDirectory
enum FileManagerDirectory {
    case common
    case catalog(String)
}
