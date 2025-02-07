import Foundation
import Combine

final class AppUserManager: NSObject, AppUserManagerControlProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppUserManagerInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AppUserManagerExternalEvent, Never>
    
    private let storage: DataStorageControlProtocol
    private let externalPublisher: PassthroughSubject<AppUserManagerExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(storage: DataStorageControlProtocol) {
        self.storage = storage
        self.internalEventPublisher = PassthroughSubject<AppUserManagerInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AppUserManagerExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
}

// MARK: Private
private extension AppUserManager {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AppUserManagerInternalEvent) {
        switch event {
            case .saveInfo(let value):
                saveInfo(value)
            
            case .delete:
                delete()
            
            case .logout:
                logout()
        }
    }
    
    func saveInfo(_ value: AppUserInfoType) {
        switch value {
            case .jsonWebToken(let string), .firebaseToken(let string), .userPhone(let string):
                (string.isEmpty() || string.isEmptyContent) ? errorInfoHandler(value) : successInfoHandler(value)
            
            case .apnsToken(let data), .voipToken(let data):
                data.isEmpty ? errorInfoHandler(value) : successInfoHandler(value)

            default:
                successInfoHandler(value)
        }
    }
    
    func errorInfoHandler(_ type: AppUserInfoType) {
        switch type {
            case .jsonWebToken:
                externalPublisher.send(.error(.jsonWebToken))
            
            case .firebaseToken:
                externalPublisher.send(.error(.firebaseToken))
            
            case .apnsToken:
                externalPublisher.send(.error(.apnsToken))
        
            case .voipToken:
                externalPublisher.send(.error(.voipToken))
            
            case .userPhone:
                externalPublisher.send(.error(.userPhone))
            
            default:
                return
        }
        
        logger.console(event: .error(info: type.description + AppUserManagerMessage.error))
    }
    
    func successInfoHandler(_ type: AppUserInfoType) {
        switch type {
            case .jsonWebToken(let token):
                guard isUniqueToken(type) else { return }
                storage.saveEncryptedInfo(key: AppUserManagerKey.jsonWebToken, .string(token))
                externalPublisher.send(.success(.jsonWebToken))
            
            case .firebaseToken(let token):
                guard isUniqueToken(type) else { return }
                storage.saveEncryptedInfo(key: AppUserManagerKey.firebaseToken, .string(token))
                externalPublisher.send(.success(.firebaseToken))
            
            case .apnsToken(let token):
                guard isUniqueToken(type) else { return }
                storage.saveEncryptedInfo(key: AppUserManagerKey.apnsToken, .data(token))
                externalPublisher.send(.success(.apnsToken))
            
            case .voipToken(let token):
                guard isUniqueToken(type) else { return }
                storage.saveEncryptedInfo(key: AppUserManagerKey.voipToken, .data(token))
                externalPublisher.send(.success(.voipToken))
            
            case .userImage(let data):
                storage.saveFile(to: .catalog(AppUserManagerKey.userImage), name: mutableInfoKey(.userImage), value: data)
                externalPublisher.send(.success(.userImage))
        
            case .userName(let name):
                storage.saveInfo(key: mutableInfoKey(.userName), value: name)
                externalPublisher.send(.success(.userName))
            
            case .userPhone(let phone):
                storage.saveEncryptedInfo(key: AppUserManagerKey.userPhone, .string(phone))
                externalPublisher.send(.success(.userPhone))
        
            case .biometrics(let data):
                storage.saveEncryptedInfo(key: AppUserManagerKey.biometrics, .data(data))
                externalPublisher.send(.success(.biometrics))
    
            case .password(let data):
                storage.saveEncryptedInfo(key: AppUserManagerKey.password, .data(data))
                externalPublisher.send(.success(.password))
            
            default:
                return
        }
        
        logger.console(event: .success(info: type.description + AppUserManagerMessage.success))
    }
    
    func isUniqueToken(_ type: AppUserInfoType) -> Bool {
        switch type {
            case .jsonWebToken(let new):
                let current = String(storage.getEncryptedInfo(key: AppUserManagerKey.jsonWebToken)?.string)
                return new != current
            
            case .firebaseToken(let new):
                let current = String(storage.getEncryptedInfo(key: AppUserManagerKey.firebaseToken)?.string)
                return new != current
            
            case .apnsToken(let new):
                let current = Data(storage.getEncryptedInfo(key: AppUserManagerKey.apnsToken)?.data)
                return new != current
            
            case .voipToken(let new):
                let current = Data(storage.getEncryptedInfo(key: AppUserManagerKey.voipToken)?.data)
                return new != current
        
            default:
                return false
        }
    }
    
    func delete() {
        storage.removeInfo(key: mutableInfoKey(.userName))
        storage.removeFile(from: .catalog(AppUserManagerKey.userImage), name: mutableInfoKey(.userImage))
        logger.console(event: .success(info: AppUserManagerMessage.delete))
        logout()
    }
    
    func logout() {
        storage.removeEncryptedInfo(key: AppUserManagerKey.biometrics)
        storage.removeEncryptedInfo(key: AppUserManagerKey.password)
        storage.removeEncryptedInfo(key: AppUserManagerKey.userPhone)
        storage.removeEncryptedInfo(key: AppUserManagerKey.jsonWebToken)
        logger.console(event: .success(info: AppUserManagerMessage.logout))
        externalPublisher.send(.logout)
    }
    
    func mutableInfoKey(_ type: AppUserManagerInfoType) -> String {
        var key = Data(storage.getEncryptedInfo(key: AppUserManagerKey.userPhone)?.string?.data(using: .utf8)).base64EncodedString()
        key.removeLast()
        
        switch type {
            case .userImage:
                return "photo_" + String(key.reversed())
            
            case .userName:
                return key
            
            default:
                return .clear
        }
    }
    
}

// MARK: Protocol
extension AppUserManager {
    
    func information(of target: AppUserManagerInfoType...) -> AppUserInfo {
        let authorization: AppUserManagerAuthorization = storage.getEncryptedInfo(key: AppUserManagerKey.jsonWebToken) != nil ? .avaliable : .unavaliable
        var info = AppUserInfo(authorization: authorization)
        
        target.forEach {
            switch $0 {
                case .authorization:
                    break
                
                case .jsonWebToken:
                    info.jsonWebToken = storage.getEncryptedInfo(key: AppUserManagerKey.jsonWebToken)?.string
                
                case .firebaseToken:
                    info.firebaseToken = storage.getEncryptedInfo(key: AppUserManagerKey.firebaseToken)?.string
                
                case .apnsToken:
                    info.apnsToken = storage.getEncryptedInfo(key: AppUserManagerKey.apnsToken)?.data
                
                case .voipToken:
                    info.voipToken = storage.getEncryptedInfo(key: AppUserManagerKey.voipToken)?.data
                
                case .userImage:
                    info.userImage = storage.getFile(from: .catalog(AppUserManagerKey.userImage), name: mutableInfoKey(.userImage))
                
                case .userName:
                    info.userName = storage.getInfo(key: mutableInfoKey(.userName), type: String.self)
                
                case .userPhone:
                    info.userPhone = storage.getEncryptedInfo(key: AppUserManagerKey.userPhone)?.string
                
                case .biometrics:
                    info.biometrics = storage.getEncryptedInfo(key: AppUserManagerKey.biometrics)?.data
                
                case .password:
                    info.password = storage.getEncryptedInfo(key: AppUserManagerKey.password)?.data
            }
        }
        
        return info
    }
    
}

// MARK: - AppUserManagerKey
fileprivate enum AppUserManagerKey {
    static let jsonWebToken = "AppUserManagerJsonWebToken"
    static let firebaseToken = "AppUserManagerFirebaseToken"
    static let apnsToken = "AppUserManagerApnsToken"
    static let voipToken = "AppUserManagerVoipToken"
    static let userImage = "Images/Photo"
    static let userPhone = "AppUserManagerUserPhone"
    static let biometrics = "AppUserManagerUserBiometrics"
    static let password = "AppUserManagerUserPassword"
}

// MARK: - AppUserManagerMessage
fileprivate enum AppUserManagerMessage {
    static let success = " value was successfully saved"
    static let error = " error bacause of empty value"
    static let delete = "User deleted the account"
    static let logout = "User logged out from the account"
}

// MARK: - AppUserInfo
struct AppUserInfo {
    fileprivate(set) var authorization: AppUserManagerAuthorization
    fileprivate(set) var jsonWebToken: String?
    fileprivate(set) var firebaseToken: String?
    fileprivate(set) var apnsToken: Data?
    fileprivate(set) var voipToken: Data?
    fileprivate(set) var userImage: Data?
    fileprivate(set) var userName: String?
    fileprivate(set) var userPhone: String?
    fileprivate(set) var biometrics: Data?
    fileprivate(set) var password: Data?
}

// MARK: - AppUserManagerInternalEvent
enum AppUserManagerInternalEvent {
    case saveInfo(AppUserInfoType)
    case delete
    case logout
}

// MARK: - AppUserInfoType
enum AppUserInfoType {
    case authorization(AppUserManagerAuthorization)
    case jsonWebToken(String)
    case firebaseToken(String)
    case apnsToken(Data)
    case voipToken(Data)
    case userImage(Data)
    case userName(String)
    case userPhone(String)
    case biometrics(Data)
    case password(Data)
    
    fileprivate var description: String {
        switch self {
            case .authorization:
                .clear
            
            case .jsonWebToken:
                "Json web token"
            
            case .firebaseToken:
                "Firebase token"
            
            case .apnsToken:
                "APNS token"
        
            case .voipToken:
                "VoIP token"
            
            case .userImage:
                "User image"
            
            case .userName:
                "User name"
            
            case .userPhone:
                "User phone"
            
            case .biometrics:
                "User biometrics"
            
            case .password:
                "User password"
        }
    }
}

// MARK: - AppUserManagerAuthorization
enum AppUserManagerAuthorization {
    case unavaliable
    case avaliable
}

// MARK: - AppUserManagerExternalEvent
enum AppUserManagerExternalEvent {
    case success(AppUserManagerInfoType)
    case error(AppUserManagerInfoType)
    case logout
}

// MARK: - AppUserManagerInfoType
enum AppUserManagerInfoType {
    case authorization
    case jsonWebToken
    case firebaseToken
    case apnsToken
    case voipToken
    case userImage
    case userName
    case userPhone
    case biometrics
    case password
}
