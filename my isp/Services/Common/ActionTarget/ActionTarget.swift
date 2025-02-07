import UIKit
import Combine

final class ActionTarget: ActionTargetControlProtocol {

    let publisher: AnyPublisher<UIControl.Event, Never>
    
    var control: UIControl? {
        get {
            cоntrol
        }
        
        set {
            cоntrol = newValue
        }
    }
    
    private weak var cоntrol: UIControl?
    private let logger: LoggingManager
    private let externalPublisher: PassthroughSubject<UIControl.Event, Never>
    
    init() {
        self.logger = LoggingManager.entry
        self.externalPublisher = PassthroughSubject<UIControl.Event, Never>()
        self.publisher = AnyPublisher(externalPublisher)
    }
    
}

// MARK: Private
private extension ActionTarget {
    
    func configure(event: UIControl.Event, state: ActionTargetState) {
        guard let cоntrol else {
            logger.console(event: .error(info: "Action target has an empty value for a control object"))
            return
        }
        
        switch event {
            case .touchDown:
                state == .active ? cоntrol.addTarget(self, action: #selector(touchDown), for: .touchDown) : cоntrol.removeTarget(self, action: #selector(touchDown), for: .touchDown)
            
            case .touchDownRepeat:
                state == .active ? cоntrol.addTarget(self, action: #selector(touchDownRepeat), for: .touchDownRepeat) : cоntrol.removeTarget(self, action: #selector(touchDownRepeat), for: .touchDownRepeat)
            
            case .touchDragInside:
                state == .active ? cоntrol.addTarget(self, action: #selector(touchDragInside), for: .touchDragInside) : cоntrol.removeTarget(self, action: #selector(touchDragInside), for: .touchDragInside)
            
            case .touchDragOutside:
                state == .active ? cоntrol.addTarget(self, action: #selector(touchDragOutside), for: .touchDragOutside) : cоntrol.removeTarget(self, action: #selector(touchDragOutside), for: .touchDragOutside)
            
            case .touchDragEnter:
                state == .active ? cоntrol.addTarget(self, action: #selector(touchDragEnter), for: .touchDragEnter) : cоntrol.removeTarget(self, action: #selector(touchDragEnter), for: .touchDragEnter)
            
            case .touchDragExit:
                state == .active ? cоntrol.addTarget(self, action: #selector(touchDragExit), for: .touchDragExit) : cоntrol.removeTarget(self, action: #selector(touchDragExit), for: .touchDragExit)
            
            case .touchUpInside:
                state == .active ? cоntrol.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside) : cоntrol.removeTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
            
            case .touchUpOutside:
                state == .active ? cоntrol.addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside) : cоntrol.removeTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
            
            case .touchCancel:
                state == .active ?  cоntrol.addTarget(self, action: #selector(touchCancel), for: .touchCancel) : cоntrol.removeTarget(self, action: #selector(touchCancel), for: .touchCancel)
            
            case .valueChanged:
                state == .active ? cоntrol.addTarget(self, action: #selector(valueChanged), for: .valueChanged) : cоntrol.removeTarget(self, action: #selector(valueChanged), for: .valueChanged)
            
            case .primaryActionTriggered:
                state == .active ? cоntrol.addTarget(self, action: #selector(primaryActionTriggered), for: .primaryActionTriggered) : cоntrol.removeTarget(self, action: #selector(primaryActionTriggered), for: .primaryActionTriggered)
            
            case .editingDidBegin:
                state == .active ? cоntrol.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin) : cоntrol.removeTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
            
            case .editingChanged:
                state == .active ? cоntrol.addTarget(self, action: #selector(editingChanged), for: .editingChanged) : cоntrol.removeTarget(self, action: #selector(editingChanged), for: .editingChanged)
            
            case .editingDidEnd:
                state == .active ?  cоntrol.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd) :  cоntrol.removeTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
            
            case .editingDidEndOnExit:
                state == .active ? cоntrol.addTarget(self, action: #selector(editingDidEndOnExit), for: .editingDidEndOnExit) : cоntrol.removeTarget(self, action: #selector(editingDidEndOnExit), for: .editingDidEndOnExit)
            
            case .allTouchEvents:
                state == .active ? cоntrol.addTarget(self, action: #selector(allTouchEvents), for: .allTouchEvents) : cоntrol.removeTarget(self, action: #selector(allTouchEvents), for: .allTouchEvents)
            
            case .allEditingEvents:
                state == .active ? cоntrol.addTarget(self, action: #selector(allEditingEvents), for: .allEditingEvents) : cоntrol.removeTarget(self, action: #selector(allEditingEvents), for: .allEditingEvents)
            
            case .applicationReserved:
                state == .active ? cоntrol.addTarget(self, action: #selector(applicationReserved), for: .applicationReserved) : cоntrol.removeTarget(self, action: #selector(applicationReserved), for: .applicationReserved)
            
            case .systemReserved:
                state == .active ? cоntrol.addTarget(self, action: #selector(systemReserved), for: .systemReserved) : cоntrol.removeTarget(self, action: #selector(systemReserved), for: .systemReserved)
            
            case .allEvents:
                state == .active ? cоntrol.addTarget(self, action: #selector(allEvents), for: .allEvents) : cоntrol.removeTarget(self, action: #selector(allEvents), for: .allEvents)
                
            default:
                break
        }
    }
    
}

// MARK: ActionTargetControlProtocol
extension ActionTarget {
    
    func addTarget(_ event: UIControl.Event) {
        configure(event: event, state: .active)
    }
    
    func removeTarget(_ event: UIControl.Event) {
        configure(event: event, state: .inactive)
    }
    
}

// MARK: ActionTargetInfoProtocol
extension ActionTarget: ActionTargetInfoProtocol {
    
    func touchDown() {
        externalPublisher.send(.touchDown)
    }
    
    func touchDownRepeat() {
        externalPublisher.send(.touchDownRepeat)
    }
    
    func touchDragInside() {
        externalPublisher.send(.touchDragInside)
    }
    
    func touchDragOutside() {
        externalPublisher.send(.touchDragOutside)
    }
    
    func touchDragEnter() {
        externalPublisher.send(.touchDragEnter)
    }
    
    func touchDragExit() {
        externalPublisher.send(.touchDragExit)
    }
    
    func touchUpInside() {
        externalPublisher.send(.touchUpInside)
    }
    
    func touchUpOutside() {
        externalPublisher.send(.touchUpOutside)
    }
    
    func touchCancel() {
        externalPublisher.send(.touchCancel)
    }
    
    func valueChanged() {
        externalPublisher.send(.valueChanged)
    }
    
    func primaryActionTriggered() {
        externalPublisher.send(.primaryActionTriggered)
    }
    
    func editingDidBegin() {
        externalPublisher.send(.editingDidBegin)
    }
    
    func editingChanged() {
        externalPublisher.send(.editingChanged)
    }
    
    func editingDidEnd() {
        externalPublisher.send(.editingDidEnd)
    }
    
    func editingDidEndOnExit() {
        externalPublisher.send(.editingDidEndOnExit)
    }
    
    func allTouchEvents() {
        externalPublisher.send(.allTouchEvents)
    }
    
    func allEditingEvents() {
        externalPublisher.send(.allEditingEvents)
    }
    
    func applicationReserved() {
        externalPublisher.send(.applicationReserved)
    }
    
    func systemReserved() {
        externalPublisher.send(.systemReserved)
    }
    
    func allEvents() {
        externalPublisher.send(.allEvents)
    }
    
}

// MARK: - ActionTargetState
enum ActionTargetState {
    case active
    case inactive
}
