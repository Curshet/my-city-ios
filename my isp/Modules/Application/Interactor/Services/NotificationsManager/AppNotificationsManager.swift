import UIKit
import Combine
import Firebase

final class AppNotificationsManager: NSObject, AppNotificationsManagerControlProtocol {

    let internalEventPublisher: PassthroughSubject<AppNotificationsManagerInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AppNotificationsManagerExternalEvent, Never>
    
    private weak var keyWindow: UIWindow?
    private let firebase: Messaging?
    private let application: ApplicationProtocol
    private let notificationCenter: NotificationCenterProtocol
    private let userNotificationCenter: UserNotificationCenterProtocol
    private let mainQueue: DispatchQueue
    private let externalPublisher: PassthroughSubject<AppNotificationsManagerExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(keyWindow: UIWindow, firebase: Messaging?, application: ApplicationProtocol, notificationCenter: NotificationCenterProtocol, userNotificationCenter: UserNotificationCenterProtocol) {
        self.keyWindow = keyWindow
        self.firebase = firebase
        self.application = application
        self.notificationCenter = notificationCenter
        self.userNotificationCenter = userNotificationCenter
        self.mainQueue = DispatchQueue.main
        self.internalEventPublisher = PassthroughSubject<AppNotificationsManagerInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AppNotificationsManagerExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
}

// MARK: Private
private extension AppNotificationsManager {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        notificationCenter.publisher(for: UIApplication.willResignActiveNotification).sink { [weak self] _ in
            self?.logger.console(event: .any(info: AppNotificationsManagerMessage.appWillEnterBackground))
            self?.externalPublisher.send(.application(.willEnterBackground))
        }.store(in: &subscriptions)
        
        notificationCenter.publisher(for: UIApplication.didEnterBackgroundNotification).sink { [weak self] _ in
            self?.logger.console(event: .any(info: AppNotificationsManagerMessage.appDidEnterBackground))
            self?.externalPublisher.send(.application(.didEnterBackground))
        }.store(in: &subscriptions)
        
        notificationCenter.publisher(for: UIApplication.willEnterForegroundNotification).sink { [weak self] _ in
            self?.logger.console(event: .any(info: AppNotificationsManagerMessage.appWillBecomeActive))
            self?.externalPublisher.send(.application(.willBecomeActive))
        }.store(in: &subscriptions)
        
        notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification).sink { [weak self] _ in
            self?.logger.console(event: .any(info: AppNotificationsManagerMessage.appDidBecomeActive))
            self?.externalPublisher.send(.application(.didBecomeActive))
        }.store(in: &subscriptions)
        
        notificationCenter.publisher(for: UIApplication.willTerminateNotification).sink { [weak self] _ in
            self?.logger.console(event: .any(info: AppNotificationsManagerMessage.appWillTerminate))
            self?.externalPublisher.send(.application(.willTerminate))
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AppNotificationsManagerInternalEvent) {
        switch event {
            case .registerForNotifications:
                application.applicationIconBadgeNumber = .zero
                application.registerForRemoteNotifications()
            
            case .requestFirebaseToken:
                requestFirebaseToken()
        
            case .apnsError(let error):
                logger.console(event: .error(info: AppNotificationsManagerMessage.apnsError + String(error)))
            
            case .pushNotificationWillPresent(let notification):
                let userInfo = notification.request.content.userInfo
                logger.console(event: .pushNotification(info: AppNotificationsManagerMessage.willPresentPush + "📍 \(userInfo) ✂️"))
            
            case .pushNotificationDidReceive(let response):
                let userInfo = response.notification.request.content.userInfo
                logger.console(event: .pushNotification(info: AppNotificationsManagerMessage.didReceivePush + "📍 \(userInfo) ✂️"))
                externalPublisher.send(.pushNotification)
        }
    }
    
    func requestFirebaseToken() {
        firebase?.token { [weak self] in
            self?.firebaseTokenHandler($0, $1)
        }
    }
    
    func firebaseTokenHandler(_ token: String?, _ error: Error?) {
        guard error == nil else {
            logger.console(event: .error(info: AppNotificationsManagerMessage.firebaseError + String(error)))
            return
        }
        
        guard let token, !token.isEmpty() else {
            logger.console(event: .error(info: AppNotificationsManagerMessage.firebaseTokenError))
            return
        }
        
        externalPublisher.send(.firebaseToken(token))
    }
    
    func requestNotificationSettings(_ completion: ((UNNotificationSettings) -> Void)?) {
        userNotificationCenter.getNotificationSettings { [weak self] settings in
            self?.mainQueue.async {
                completion?(settings)
            }
        }
    }
    
    func present(_ type: AppUserNotificationType) {
        logger.console(event: .userNotification(info: AppNotificationsManagerMessage.userNotification + type.description))
        
        switch type {
            case .push(let title, let text, let timeInterval):
                let request = notificationRequest(title, text, timeInterval)
                userNotificationCenter.add(request)

            default:
                break
        }
    }
    
    func notificationRequest(_ title: String, _ text: String, _ timeInterval: Double) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = title
        content.body = text
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: Bundle.main.identifier, content: content, trigger: trigger)
        return request
    }
    
}

// MARK: AppNotificationsManagerPresentProtocol
extension AppNotificationsManager {
    
    func presentUserNotification(_ type: AppUserNotificationType) {
        mainQueue.asynchronous { [weak self] in
            self?.present(type)
        }
    }
    
}

// MARK: AppNotificationsManagerAuthorizationProtocol
extension AppNotificationsManager: AppNotificationsManagerAuthorizationProtocol {
    
    func requestAuthorization(_ completion: ((UNNotificationSettings) -> Void)?) {
        userNotificationCenter.requestAuthorization(options: [.badge, .sound, .alert]) { [weak self] (status, error) in
            self?.logger.console(event: .any(info: AppNotificationsManagerMessage.permissionStatus + String(error == nil ? status : false)))
            self?.requestNotificationSettings(completion)
        }
    }

}

// MARK: - AppNotificationsManagerMessage
fileprivate enum AppNotificationsManagerMessage {
    static let apnsError = "APNS registration error: "
    static let firebaseError = "Firebase error: "
    static let firebaseTokenError = "Firebase token has an unavaliable value"
    static let appWillBecomeActive = "Application will become active 􀣺"
    static let appDidBecomeActive = "Application did become active 􀣺"
    static let appWillEnterBackground = "Application will enter backgroung 􀣺"
    static let appDidEnterBackground = "Application did enter backgroung 􀣺"
    static let appWillTerminate = "Application was terminated 􀣺"
    static let willPresentPush = "Push notification will present with content: "
    static let didReceivePush = "Push notification did receive to user with content: "
    static let permissionStatus = "User notifications permission has a status of "
    static let userNotification = "Presenting user notification as "
}

// MARK: - AppNotificationsManagerInternalEvent
enum AppNotificationsManagerInternalEvent {
    case registerForNotifications
    case requestFirebaseToken
    case apnsError(Error)
    case pushNotificationWillPresent(UNNotification)
    case pushNotificationDidReceive(UNNotificationResponse)
}

// MARK: - AppUserNotificationType
enum AppUserNotificationType: Equatable {
    case action(AppUserNotificationAction)
    case success(String)
    case error(String)
    case message(String)
    case push(title: String, text: String, timeInterval: Double)
    
    fileprivate var description: String {
        switch self {
            case .action(let type):
                "action on \(type.description)"
            
            case .success(let message):
                "success with message: \"\(message)\""
            
            case .error(let message):
                "error with message: \"\(message)\""
            
            case .message(let text):
                "message with text: \"\(text)\""
            
            case .push(let title, let text, let timeInterval):
                "local push notification with title: \"\(title)\", text: \"\(text)\", timeInterval: \"\(timeInterval)\""
        }
    }
}

// MARK: - AppUserNotificationAction
enum AppUserNotificationAction: Equatable {
    case copy(String)
    case biometrics(String)
    case password(String)
    
    fileprivate var description: String {
        switch self {
            case .copy(let message):
                "copy with message: \"\(message)\""
            
            case .biometrics(let message):
                "biometrics with message: \"\(message)\""
            
            case .password(let message):
                "password with message: \"\(message)\""
        }
    }
}

// MARK: - AppNotificationManagerExternalEvent
enum AppNotificationsManagerExternalEvent: Equatable {
    case firebaseToken(String)
    case pushNotification
    case application(AppStateEvent)
}

// MARK: - AppStateEvent
enum AppStateEvent {
    case willEnterBackground
    case didEnterBackground
    case willBecomeActive
    case didBecomeActive
    case willTerminate
}
