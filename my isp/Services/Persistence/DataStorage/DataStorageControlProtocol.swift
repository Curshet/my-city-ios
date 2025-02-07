import Foundation

protocol DataStorageControlProtocol: DataStorageInfoProtocol {
    func saveInfo<T>(key: String, value: T)
    func saveInfo<T: Hashable>(key: String, collection: Set<T>?)
    func saveEncryptedInfo(key: String, _ value: DataStorageEncryptedData)
    func saveFile(to: FileManagerDirectory, name: String, value: Data?)
    func removeInfo(key: String)
    func removeEncryptedInfo(key: String)
    func removeFile(from: FileManagerDirectory, name: String)
}
