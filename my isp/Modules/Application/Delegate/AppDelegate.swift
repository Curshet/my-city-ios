import UIKit
import UserNotifications
import Firebase

@main
final class AppDelegate: UIResponder {
    
    private var injector: InjectorProtocol!
    private var builder: AppBuilderProtocol!
    private var module: AppBuilderModule!
    
}

// MARK: UIApplicationDelegate
extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        injector = Injector()
        builder = AppBuilder(injector: injector)
        module = builder?.module
        guard let module else { return false }
        return module.coordinator.start()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        module?.interactor.internalEventPublisher.send(.activity(.route(.deepLink(url))))
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        module?.interactor.internalEventPublisher.send(.activity(.route(.universalLink(userActivity))))
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        module?.interactor.internalEventPublisher.send(.token(.apnsToken(deviceToken)))
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        module?.interactor.internalEventPublisher.send(.notification(.apnsError(error)))
    }
    
}

// MARK: UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        module?.interactor.internalEventPublisher.send(.notification(.pushNotificationWillPresent(userInfo)))
        completionHandler([.badge, .sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        module?.interactor.internalEventPublisher.send(.notification(.pushNotificationDidReceive(userInfo)))
        completionHandler()
    }
    
}

// MARK: MessagingDelegate
extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let token = String(fcmToken)
        module?.interactor.internalEventPublisher.send(.token(.firebaseToken(token)))
    }
    
}
