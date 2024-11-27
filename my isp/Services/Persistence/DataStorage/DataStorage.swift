import Foundation
import KeychainAccess

final class DataStorage: NSObject, DataStorageControlProtocol {
    
    static let entry = DataStorage()
    
    private let userDefaults: UserDefaultsProtocol
    private let keychain: Keychain
    private let fileManager: FileManagerProtocol
    private let userDefaultsQueue: DispatchQueue
    private let keychainQueue: DispatchQueue
    private let fileManagerQueue: DispatchQueue
    
    private override init() {
        self.userDefaults = UserDefaults.standard
        self.keychain = Keychain()
        self.fileManager = FileManager.default
        self.userDefaultsQueue = DispatchQueue.create(label: "dataStorage.userDefaults", qos: .userInitiated, attributes: .concurrent)
        self.keychainQueue = DispatchQueue.create(label: "dataStorage.keychain", qos: .userInitiated, attributes: .concurrent)
        self.fileManagerQueue = DispatchQueue.create(label: "dataStorage.fileManager", qos: .userInitiated, attributes: .concurrent)
        super.init()
    }
    
    /// Returns value from UserDefaults
    func getInfo<T>(key: String, type: T.Type) -> T? {
        guard !key.isEmpty(), !key.isEmptyContent else {
            logger.console(event: .error(info: DataStorageMessage.readingInfoKeyError))
            return nil
        }
        
        var value: T?
        
        userDefaultsQueue.sync {
            value = userDefaults.object(forKey: key) as? T
        }
            
        guard let value else {
            logger.console(event: .error(info: DataStorageMessage.readingInfoError + key))
            return nil
        }
        
        return value
    }
    
    /// Returns hashable value as <Set> from UserDefaults
    func getInfo<T: Hashable>(key: String, hashable: T.Type) -> Set<T>? {
        guard !key.isEmpty(), !key.isEmptyContent else {
            logger.console(event: .error(info: DataStorageMessage.readingInfoKeyError))
            return nil
        }
        
        var value: Set<T>?
        
        userDefaultsQueue.sync {
            if let data = userDefaults.object(forKey: key) as? Array<T> {
                value = Set(data)
            }
        }
        
        guard let value else {
            logger.console(event: .error(info: DataStorageMessage.readingCollectionInfoError + key))
            return nil
        }
        
        return value
    }
    
    /// Saving value to UserDefaults
    func saveInfo<T>(key: String, value: T) {
        guard !key.isEmpty(), !key.isEmptyContent else {
            logger.console(event: .error(info: DataStorageMessage.savingInfoKeyError))
            return
        }
    
        userDefaultsQueue.async(flags: .barrier) {
            self.userDefaults.setValue(value, forKey: key)
        }
    }
    
    /// Saving hashable value as <Set> to UserDefaults
    func saveInfo<T: Hashable>(key: String, collection: Set<T>?) {
        guard !key.isEmpty(), !key.isEmptyContent else {
            logger.console(event: .error(info: DataStorageMessage.savingInfoKeyError))
            return
        }
        
        userDefaultsQueue.async(flags: .barrier) {
            if let collection, let data = collection as? Set<Character> {
                let array = data.map { String($0) }
                self.userDefaults.setValue(array, forKey: key)
                return
            }
            
            let array = collection?.map { $0 }
            self.userDefaults.setValue(array, forKey: key)
        }
    }
    
    /// Removing value from UserDefaults
    func removeInfo(key: String) {
        guard !key.isEmpty(), !key.isEmptyContent else {
            logger.console(event: .error(info: DataStorageMessage.removingInfoKeyError))
            return
        }
        
        userDefaultsQueue.async(flags: .barrier) { [weak self] in
            self?.userDefaults.removeObject(forKey: key)
        }
    }
    
    /// Returns value from Keychain
    func getEncryptedInfo(key: String) -> (string: String?, data: Data?)? {
        guard !key.isEmpty(), !key.isEmptyContent else {
            logger.console(event: .error(info: DataStorageMessage.readingEncryptedInfoKeyError))
            return nil
        }
        
        var value: (string: String?, data: Data?)?
        
        keychainQueue.sync {
            let string = try? keychain.getString(key)
            let data = try? keychain.getData(key)
            
            if string != nil || data != nil {
                value = (string: string, data: data)
            }
        }
        
        guard let value else {
            logger.console(event: .error(info: DataStorageMessage.readingEncryptedInfoError + key))
            return nil
        }

        return value
    }
    
    /// Saving value to Keychain
    func saveEncryptedInfo(key: String, _ value: DataStorageEncryptedData) {
        guard !key.isEmpty(), !key.isEmptyContent else {
            logger.console(event: .error(info: DataStorageMessage.savingEncryptedInfoKeyError))
            return
        }
        
        keychainQueue.async(flags: .barrier) {
            switch value {
                case .string(let value):
                    self.keychain[string: key] = value
                
                case .data(let data):
                    self.keychain[data: key] = data
            }
        }
    }
    
    /// Removing value from Keychain
    func removeEncryptedInfo(key: String) {
        guard !key.isEmpty(), !key.isEmptyContent else {
            logger.console(event: .error(info: DataStorageMessage.removingEncryptedInfoKeyError))
            return
        }
        
        keychainQueue.async(flags: .barrier) {
            self.keychain[key] = nil
        }
    }
    
    /// Returns data from FileManager
    func getFile(from: FileManagerDirectory, name: String) -> Data? {
        guard !name.isEmpty(), !name.isEmptyContent else {
            logger.console(event: .error(info: DataStorageMessage.readingFileNameError))
            return nil
        }
        
        guard let directory = fileManager.path(target: from) else {
            logger.console(event: .error(info: DataStorageMessage.directoryFileError + name))
            return nil
        }
        
        let url = directory.appendingPathComponent(name)
        var data: Data?
        
        fileManagerQueue.sync {
            do {
                data = try Data(contentsOf: url)
            } catch {
                self.logger.console(event: .error(info: error))
            }
        }
        
        return data
    }
    
    /// Saving data to FileManager
    func saveFile(to: FileManagerDirectory, name: String, value: Data?) {
        guard !name.isEmpty(), !name.isEmptyContent else {
            logger.console(event: .error(info: DataStorageMessage.savingFileNameError))
            return
        }
        
        guard let directory = fileManager.path(target: to) else {
            logger.console(event: .error(info: DataStorageMessage.directoryFileError + name))
            return
        }
        
        let path: URL?
        
        switch to {
            case .common:
                path = directory
            
            case .catalog(let name):
                path = fileManager.createDirectory(name: name)
        }

        guard let url = path?.appendingPathComponent(name) else {
            logger.console(event: .error(info: DataStorageMessage.directoryFileError + name))
            return
        }
        
        fileManagerQueue.async(flags: .barrier) {
            do {
                try value?.write(to: url)
            } catch {
                self.logger.console(event: .error(info: error))
            }
        }
    }
    
    /// Removing data from FileManager
    func removeFile(from: FileManagerDirectory, name: String) {
        guard !name.isEmpty(), !name.isEmptyContent else {
            logger.console(event: .error(info: DataStorageMessage.removingFileNameError))
            return
        }
        
        guard let directory = fileManager.path(target: from) else {
            logger.console(event: .error(info: DataStorageMessage.directoryFileError + name))
            return
        }
        
        let url = directory.appendingPathComponent(name)
        
        fileManagerQueue.async(flags: .barrier) {
            do {
                try self.fileManager.removeItem(atPath: url.path)
            } catch {
                self.logger.console(event: .error(info: error))
            }
        }
    }
    
}

// MARK: - DataStorageMessage
fileprivate enum DataStorageMessage {
    static let readingInfoKeyError = "Data storage reading information error for empty or unavaliable key"
    static let readingInfoError = "Data storage reading information error for key: "
    static let readingCollectionInfoError = "Data storage reading collection information error for key: "
    static let savingInfoKeyError = "Data storage saving information error for empty or unavaliable key"
    static let removingInfoKeyError = "Data storage removing information error for empty or unavaliable key"
    static let readingEncryptedInfoKeyError = "Data storage encrypted information reading error for empty or unavaliable key"
    static let readingEncryptedInfoError = "Data storage encrypted information reading error for key: "
    static let savingEncryptedInfoKeyError = "Data storage encrypted information saving error for empty or unavaliable key"
    static let removingEncryptedInfoKeyError = "Data storage encrypted information removing error for empty or unavaliable key"
    static let readingFileNameError = "Data storage reading file error for empty or unavaliable name"
    static let savingFileNameError = "Data storage saving file error for empty or unavaliable name"
    static let removingFileNameError = "Data storage removing file error for empty or unavaliable name"
    static let directoryFileError = "Data storage directory access error for file: "
}

// MARK: - DataStorageEncryptedData
enum DataStorageEncryptedData {
    case string(String)
    case data(Data)
}
