import UIKit
import Combine

class ChatRouter: ScreenRouter, ChatRouterProtocol {
    
    let internalEventPublisher: PassthroughSubject<ChatRouterInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AppInteractorActivity, Never>
    
    private weak var navigationController: AppNavigationControllerProtocol?
    private weak var builder: ChatBuilderRoutingProtocol?
    private let externalPublisher: PassthroughSubject<AppInteractorActivity, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(builder: ChatBuilderRoutingProtocol, notificationsManager: AppNotificationsManagerPresentProtocol, displaySpinner: DisplaySpinnerProtocol, application: ApplicationProtocol) {
        self.builder = builder
        self.internalEventPublisher = PassthroughSubject<ChatRouterInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AppInteractorActivity, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
        setupObservers()
    }
    
}

// MARK: Private
private extension ChatRouter {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: ChatRouterInternalEvent) {
        switch event {
            case .inject(let value):
                guard navigationController == nil else { return }
                navigationController = value
            
            case .trigger(let type):
                externalPublisher.send(type)
            
            case .notify(let type):
                userNotification(type)
        }
    }
    
}

// MARK: - ChatRouterInternalEvent
enum ChatRouterInternalEvent {
    case inject(navigationController: AppNavigationControllerProtocol)
    case trigger(AppInteractorActivity)
    case notify(AppUserNotificationType)
}
