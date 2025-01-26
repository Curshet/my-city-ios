import UIKit
import Combine

final class KeyboardManager: NSObject, KeyboardManagerProtocol {
    
    static let entry = KeyboardManager()

    /// System keyboard event publisher
    let publisher: AnyPublisher<KeyboardManagerEvent, Never>
    
    private let notificationCenter: NotificationCenterProtocol
    private let externalPublisher: PassthroughSubject<KeyboardManagerEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    private override init() {
        self.notificationCenter = NotificationCenter.default
        self.externalPublisher = PassthroughSubject<KeyboardManagerEvent, Never>()
        self.publisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
}

// MARK: Private
private extension KeyboardManager {
    
    func setupObservers() {
        notificationCenter.publisher(for: UIResponder.keyboardWillShowNotification).sink {
            self.willShowAction($0)
        }.store(in: &subscriptions)
        
        notificationCenter.publisher(for: UIResponder.keyboardDidShowNotification).sink { _ in
            self.didShowAction()
        }.store(in: &subscriptions)
        
        notificationCenter.publisher(for: UIResponder.keyboardWillHideNotification).sink { _ in
            self.willHideAction()
        }.store(in: &subscriptions)
        
        notificationCenter.publisher(for: UIResponder.keyboardDidHideNotification).sink { _ in
            self.didHideAction()
        }.store(in: &subscriptions)
        
        logger.console(event: .any(info: KeyboardManagerMessage.start))
    }
    
    func willShowAction(_ notification: Notification) {
        let userInfo = notification.userInfo
        let value = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        let keyboardFrame = value?.cgRectValue ?? .zero
        externalPublisher.send(.willShow(keyboardFrame))
    }
    
    func didShowAction() {
        logger.console(event: .any(info: KeyboardManagerMessage.show))
        externalPublisher.send(.didShow)
    }
    
    func willHideAction() {
        externalPublisher.send(.willHide)
    }
    
    func didHideAction() {
        logger.console(event: .any(info: KeyboardManagerMessage.hide))
        externalPublisher.send(.didHide)
    }
    
}

// MARK: - KeyboardManagerMessage
fileprivate enum KeyboardManagerMessage {
    static let start = "System keyboard status monitoring started"
    static let show = "System keyboard is showing"
    static let hide = "System keyboard was hidden"
}

// MARK: - KeyboardManagerEvent
enum KeyboardManagerEvent: Equatable {
    case willShow(CGRect)
    case didShow
    case willHide
    case didHide
}
