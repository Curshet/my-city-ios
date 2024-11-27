import Foundation

protocol DataStorageInfoProtocol {
    func getInfo<T>(key: String, type: T.Type) -> T?
    func getInfo<T: Hashable>(key: String, hashable: T.Type) -> Set<T>?
    func getEncryptedInfo(key: String) -> (string: String?, data: Data?)?
    func getFile(from: FileManagerDirectory, name: String) -> Data?
}
