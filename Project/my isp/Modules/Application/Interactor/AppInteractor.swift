import Foundation
import Combine

final class AppInteractor: NSObject, AppInteractorProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppInteractorInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AppInteractorExternalEvent, Never>
    
    private let presenter: AppPresenterProtocol
    private let userManager: AppUserManagerControlProtocol
    private let routeManager: AppRouteManagerProtocol
    private let connectionManager: ConnectionManagerProtocol
    private let notificationsManager: AppNotificationsManagerControlProtocol
    private let externalPublisher: PassthroughSubject<AppInteractorExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(presenter: AppPresenterProtocol, userManager: AppUserManagerControlProtocol, routeManager: AppRouteManagerProtocol, connectionManager: ConnectionManagerProtocol, notificationManager: AppNotificationsManagerControlProtocol) {
        self.presenter = presenter
        self.userManager = userManager
        self.routeManager = routeManager
        self.connectionManager = connectionManager
        self.notificationsManager = notificationManager
        self.internalEventPublisher = PassthroughSubject<AppInteractorInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AppInteractorExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
}

// MARK: Private
private extension AppInteractor {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        userManager.externalEventPublisher.sink { [weak self] in
            guard case let .success(type) = $0, type == .apnsToken else { return }
            self?.notificationsManager.internalEventPublisher.send(.requestFirebaseToken)
        }.store(in: &subscriptions)
        
        routeManager.externalEventPublisher.sink { [weak self] in
            self?.externalPublisher.send(.activity(.route($0)))
        }.store(in: &subscriptions)
        
        connectionManager.publisher.sink { [weak self] in
            guard !$0.isConnected else { return }
            self?.notificationsManager.presentUserNotification(.error(.localized.internetError))
        }.store(in: &subscriptions)
        
        notificationsManager.externalEventPublisher.sink { [weak self] in
            self?.notificationsManagerEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AppInteractorInternalEvent) {
        switch event {
            case .start:
                let userInfo = userManager.information(of: .authorization)
                notificationsManager.internalEventPublisher.send(.registerForNotifications)
                externalPublisher.send(.start(userInfo.authorization))

            case .fatalError(let value):
                let description = value.description
                logger.console(event: .error(info: description))
                fatalError(description)
        
            case .activity(let value):
                activityHandler(value)
        
            case .token(let type):
                userManager.internalEventPublisher.send(.saveInfo(type))
            
            case .notification(let event):
                notificationsManager.internalEventPublisher.send(event)
        }
    }
    
    func activityHandler(_ value: AppInteractorUserActivity) {
        switch value {
            case .request:
                routeManager.internalEventPublisher.send(.request)
            
            case .route(let type):
                routeManager.internalEventPublisher.send(type)
        }
    }
    
    func notificationsManagerEventHandler(_ event: AppNotificationsManagerExternalEvent) {
        switch event {
            case .firebaseToken(let value):
                userManager.internalEventPublisher.send(.saveInfo(.firebaseToken(value)))
            
            case .pushNotification:
                externalPublisher.send(.activity(.pushNotification))
            
            case .application(let event):
                applicationEventHandler(event)
        }
    }
    
    func applicationEventHandler(_ event: AppStateEvent) {
        switch event {
            case .willEnterBackground:
                presenter.internalEventPublisher.send(.showEffect)
            
            case .didBecomeActive:
                presenter.internalEventPublisher.send(.hideEffect)
            
            default:
                break
        }
    }
    
}

// MARK: - AppInteractorMessage
fileprivate enum AppInteractorMessage {
    static let splashCoordinatorError = "Splash coordinator doesn't exist"
    static let authorizationCoordinatorError = "Authorization coordinator doesn't exist"
    static let navigationCoordinatorError = "Navigation coordinator doesn't exist"
    static let intercomCoordinatorError = "Intercom coordinator doesn't exist"
}

// MARK: - AppInteractorInternalEvent
enum AppInteractorInternalEvent {
    case start
    case fatalError(AppInteractorInternalError)
    case activity(AppInteractorUserActivity)
    case token(AppUserInfoType)
    case notification(AppNotificationsManagerInternalEvent)
}

// MARK: - AppInteractorUserActivity
enum AppInteractorUserActivity {
    case request
    case route(AppRouteManagerInternalEvent)
}

// MARK: - AppInteractorInternalError
enum AppInteractorInternalError {
    case splashCoordinator
    case authorizationCoordinator
    case navigationCoordinator
    case intercomCoordinator
    
    fileprivate var description: String {
        switch self {
            case .splashCoordinator:
                AppInteractorMessage.splashCoordinatorError

            case .authorizationCoordinator:
                AppInteractorMessage.authorizationCoordinatorError
            
            case .navigationCoordinator:
                AppInteractorMessage.navigationCoordinatorError
            
            case .intercomCoordinator:
                AppInteractorMessage.intercomCoordinatorError
        }
    }
}

// MARK: - AppInteractorExternalEvent
enum AppInteractorExternalEvent {
    case start(AppUserManagerAuthorization)
    case activity(AppInteractorActivity)
}

// MARK: - AppInteractorActivity
enum AppInteractorActivity: Equatable {
    case route(AppRouteManagerExternalEvent)
    case pushNotification
}
