import UIKit
import Combine

final class DisplaySpinner: DisplaySpinnerProtocol {
    
    let internalEventPublisher: PassthroughSubject<DisplaySpinnerEvent, Never>
    
    private weak var keyWindow: UIWindow?
    private let topWindow: DisplayWindowProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(keyWindow: UIWindow, topWindow: DisplayWindowProtocol) {
        self.keyWindow = keyWindow
        self.topWindow = topWindow
        self.internalEventPublisher = PassthroughSubject<DisplaySpinnerEvent, Never>()
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension DisplaySpinner {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: DisplaySpinnerEvent) {
        DispatchQueue.main.asynchronous { [weak self] in
            guard let self else { return }
            
            switch event {
                case .start(let type) where topWindow.isHidden:
                    guard !type.withKeyboard else { break }
                    keyWindow?.hideKeyboard()
                
                case .stop where !topWindow.isHidden:
                    break
                
                default:
                    return
            }
            
            topWindow.internalEventPublisher.send(event)
        }
    }

}

// MARK: - DisplaySpinnerEvent
enum DisplaySpinnerEvent {
    case start(DisplaySpinnerType)
    case stop
}

// MARK: - DisplaySpinnerType
enum DisplaySpinnerType {
    case defаult
    case defаultWithKeyboard
    case layout(AppOverlayViewLayout)
    case layoutWithKeyboard(AppOverlayViewLayout)
    case custom(subview: UIView, layout: DisplayViewLayout)
    case customWithKeyboard(subview: UIView, layout: DisplayViewLayout)
    
    fileprivate var withKeyboard: Bool {
        switch self {
            case .defаultWithKeyboard, .layoutWithKeyboard, .customWithKeyboard:
                true
            
            default:
                false
        }
    }
}
