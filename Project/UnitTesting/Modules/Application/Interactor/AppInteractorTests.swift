import XCTest
import Combine
@testable import my_isp

final class AppInteractorTests: XCTestCase {
   
    private var presenter: AppPresenterProtocol!
    private var userManager: AppUserManagerProtocol!
    private var notificationManager: AppNotificationManagerProtocol!
    private var interactor: AppInteractor!
    private var subscriptions: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        presenter = AppPresenterMock()
        userManager = AppUserManagerMock()
        notificationManager = AppNotificationManagerMock()
        interactor = AppInteractor(presenter: presenter, userManager: userManager, notificationManager: notificationManager)
        subscriptions = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        presenter = nil
        userManager = nil
        notificationManager = nil
        interactor = nil
        subscriptions = nil
        try super.tearDownWithError()
    }
    
    func testStartApplicationEvent() {
        let expectation = XCTestExpectation()
        
        interactor.externalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .startApplication(_):
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        interactor.internalEventPublisher.send(.action(.startApplication))
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testPushNotificationEvent() {
        let expectation = XCTestExpectation()
        let pushNotification = ["Test" : "Test"]
        
        interactor.externalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .pushNotification(_):
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        interactor.internalEventPublisher.send(.userNotificationCenter(.pushNotification(pushNotification)))
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testErrorEvent() {
        let expectation = XCTestExpectation()
        let emptyToken = ""
        
        interactor.externalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .error(_):
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        userManager.internalEventPublisher.send(.saveInfo(.accessToken(emptyToken)))
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testUserLogoutEvent() {
        let expectation = XCTestExpectation()
        let token = UUID().uuidString
        
        interactor.externalEventPublisher.sink { [weak expectation] in
            switch $0 {
                case .userLogout:
                    expectation?.fulfill()
                
                default:
                    break
            }
        }.store(in: &subscriptions)
        
        userManager.internalEventPublisher.send(.saveInfo(.accessToken(token)))
        interactor.internalEventPublisher.send(.action(.userLogout))
        
        wait(for: [expectation], timeout: 2)
    }
    
}

// MARK: - AppPresenterMock
fileprivate class AppPresenterMock: AppPresenterProtocol {
    let internalEventPublisher = PassthroughSubject<AppPresenterInternalEvent, Never>()
}

// MARK: - AppUserManagerMock
final class AppUserManagerMock: AppUserManagerProtocol {
    
    let internalEventPublisher = PassthroughSubject<AppUserManagerInternalEvent, Never>()
    
    var externalEventPublisher: AnyPublisher<AppUserManagerExternalEvent, Never> {
        externalEventDataPublisher.eraseToAnyPublisher()
    }
    
    private let key = "Test"
    private let storage: UserStorageProtocol = UserStorageMock()
    private let externalEventDataPublisher = PassthroughSubject<AppUserManagerExternalEvent, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    private var authorizationStatus: AppUserManagerAuthorization {
        storage.getEncryptedInfo(key: key) != nil ? .avaliable : .unavaliable
    }
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    private func internalEventHandler(_ event: AppUserManagerInternalEvent) {
        switch event {
            case .checkAuthorizationStatus:
                externalEventDataPublisher.send(.authorizationStatus(authorizationStatus))
            
            case .saveInfo(let info):
                saveInfo(info)
            
            case .logout:
                logout()
        }
    }
    
    private func saveInfo(_ data: AppUserInfoType) {
        switch data {
            case .accessToken(let token):
                token.isEmpty ? errorTokenHandler(token) : storage.saveEncryptedInfo(key: key, .value(token))
            
            default:
                break
        }
    }
    
    private func errorTokenHandler(_ token: String) {
        storage.removeEncryptedInfo(key: key)
        externalEventDataPublisher.send(.tokenError(.accessToken(token)))
    }
    
    private func logout() {
        storage.removeEncryptedInfo(key: key)
        externalEventDataPublisher.send(.logout)
    }
    
}

// MARK: - AppNotificationManagerMock
final class AppNotificationManagerMock: AppNotificationManagerProtocol {
    
    let internalEventPublisher = PassthroughSubject<AppNotificationManagerInternalEvent, Never>()
    
    var externalEventPublisher: AnyPublisher<AppNotificationManagerExternalEvent, Never> {
        externalEventDataPublisher.eraseToAnyPublisher()
    }
    
    private let externalEventDataPublisher = PassthroughSubject<AppNotificationManagerExternalEvent, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    private func internalEventHandler(_ event: AppNotificationManagerInternalEvent) {
        switch event {
            case .register:
                externalEventDataPublisher.send(.permission(true))
        }
    }
    
}

// MARK: - UserStorageMock
final class UserStorageMock: UserStorageProtocol {
    
    var publisher: AnyPublisher<UserStorageEvent, Never> {
        internalPublisher.eraseToAnyPublisher()
    }
    
    private var data = [String : Any]()
    private var encryptedData = [String : Any]()
    private let internalPublisher = PassthroughSubject<UserStorageEvent, Never>()
    
    func saveInfo(key: String, value: Any?) {
        guard !key.isEmpty else { return }
        data[key] = value
        internalPublisher.send(.save(key))
    }
    
    func saveInfo<T: Hashable>(key: String, collection: Set<T>?) {
        guard !key.isEmpty else { return }
        data[key] = collection
        internalPublisher.send(.save(key))
    }
    
    func getInfo<T>(key: String, type: T.Type) -> T? {
        guard !key.isEmpty else { return nil }
        return data[key] as? T
    }
    
    func getInfo<T: Hashable>(key: String, hashable: T.Type) -> Set<T>? {
        guard !key.isEmpty, let data = data[key] as? Array<T> else { return nil }
        return Set(data)
    }
    
    func removeInfo(key: String) {
        guard !key.isEmpty else { return }
        encryptedData[key] = nil
        internalPublisher.send(.remove(key))
    }
    
    func saveEncryptedInfo(key: String, _ value: UserStorageEncryptedData) {
        guard !key.isEmpty else { return }
        
        switch value {
            case .value(let string):
                let data: Data? = nil
                encryptedData[key] = (value: string, data: data)
            
            case .data(let data):
                let string: String? = nil
                encryptedData[key] = (value: string, data: data)
        }
        
        internalPublisher.send(.save(key))
    }
    
    func getEncryptedInfo(key: String) -> (value: String?, data: Data?)? {
        guard !key.isEmpty else { return nil }
        return encryptedData[key] as? (value: String?, data: Data?)
    }
    
    func removeEncryptedInfo(key: String) {
        guard !key.isEmpty else { return }
        encryptedData[key] = nil
        internalPublisher.send(.remove(key))
    }
    
}
