import UIKit
import Combine

class IntercomRouter: ScreenRouter, IntercomRouterProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppInteractorActivity, Never>
    let externalEventPublisher: AnyPublisher<AppInteractorActivity, Never>
    
    private weak var builder: IntercomBuilderRoutingProtocol?
    private let externalPublisher: PassthroughSubject<AppInteractorActivity, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(builder: IntercomBuilderRoutingProtocol, notificationsManager: AppNotificationsManagerPresentProtocol, displaySpinner: DisplaySpinnerProtocol, application: ApplicationProtocol) {
        self.builder = builder
        self.internalEventPublisher = PassthroughSubject<AppInteractorActivity, Never>()
        self.externalPublisher = PassthroughSubject<AppInteractorActivity, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(notificationsManager: notificationsManager, displaySpinner: displaySpinner, application: application)
    }
    
}
