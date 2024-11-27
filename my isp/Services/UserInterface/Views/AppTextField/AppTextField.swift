import UIKit
import Combine

class AppTextField: UITextField, AppTextFieldProtocol {
    
    let publisher: AnyPublisher<AppTextFieldEvent, Never>
    
    private let customDelegate: AppTextFieldDelegateProtocol
    private let actionTarget: ActionTargetControlProtocol
    private let externalPublisher: PassthroughSubject<AppTextFieldEvent, Never>
    private var selectorTargets: Set<AppTextSelector>
    private var subscriptions: Set<AnyCancellable>
    
    init(delegate: AppTextFieldDelegateProtocol, actionTarget: ActionTargetControlProtocol, frame: CGRect = .zero) {
        self.customDelegate = delegate
        self.actionTarget = actionTarget
        self.externalPublisher = PassthroughSubject<AppTextFieldEvent, Never>()
        self.publisher = AnyPublisher(externalPublisher)
        self.selectorTargets = Set<AppTextSelector>()
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: frame)
        self.delegate = customDelegate
        self.actionTarget.control = self
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    final override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        isPerform(action)
    }
    
}

// MARK: Private
private extension AppTextField {
    
    func setupObservers() {
        customDelegate.publisher.sink { [weak self] in
            self?.externalPublisher.send(.delegate($0))
        }.store(in: &subscriptions)
        
        actionTarget.publisher.sink { [weak self] in
            self?.externalPublisher.send(.control($0))
        }.store(in: &subscriptions)
    }
    
    func isPerform(_ action: Selector) -> Bool {
        switch true {
            case _ where action == #selector(select(_:)):
                externalPublisher.send(.selector(.select))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.select)
        
            case _ where action == #selector(selectAll(_:)):
                externalPublisher.send(.selector(.selectAll))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.selectAll)
            
            case _ where action == #selector(cut(_:)):
                externalPublisher.send(.selector(.cut))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.cut)
           
            case _ where action == #selector(copy(_:)):
                externalPublisher.send(.selector(.copy))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.copy)
            
            case _ where action == #selector(delete(_:)):
                externalPublisher.send(.selector(.delete))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.delete)
            
            case _ where action == #selector(paste(_:)):
                externalPublisher.send(.selector(.paste))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.paste)

            default:
                guard #available(iOS 15.0, *) else { return false }
                return isPerfоrming(action)
        }
    }
    
    @available(iOS 15.0, *)
    func isPerfоrming(_ action: Selector) -> Bool {
        switch true {
            case _ where action == #selector(pasteAndGo(_:)):
                externalPublisher.send(.selector(.pasteAndGo))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.pasteAndGo)
            
            case _ where action == #selector(pasteAndSearch(_:)):
                externalPublisher.send(.selector(.pasteAndSearch))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.pasteAndSearch)
            
            case _ where action == #selector(pasteAndSearch(_:)):
                externalPublisher.send(.selector(.pasteAndSearch))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.pasteAndSearch)
            
            case _ where action == #selector(toggleBoldface(_:)):
                externalPublisher.send(.selector(.toggleBoldface))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.toggleBoldface)
            
            case _ where action == #selector(toggleItalics(_:)):
                externalPublisher.send(.selector(.toggleItalics))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.toggleItalics)
            
            case _ where action == #selector(toggleUnderline(_:)):
                externalPublisher.send(.selector(.toggleUnderline))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.toggleUnderline)
            
            case _ where action == #selector(increaseSize(_:)):
                externalPublisher.send(.selector(.increaseSize))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.increaseSize)
            
            case _ where action == #selector(decreaseSize(_:)):
                externalPublisher.send(.selector(.decreaseSize))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.decreaseSize)
            
            case _ where action == #selector(printContent(_:)):
                externalPublisher.send(.selector(.printContent))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.printContent)
            
            case _ where action == #selector(makeTextWritingDirectionLeftToRight(_:)):
                externalPublisher.send(.selector(.makeTextWritingDirectionLeftToRight))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.makeTextWritingDirectionLeftToRight)
            
            case _ where action == #selector(makeTextWritingDirectionRightToLeft(_:)):
                externalPublisher.send(.selector(.makeTextWritingDirectionRightToLeft))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.makeTextWritingDirectionRightToLeft)

            default:
                guard #available(iOS 16.0, *) else { return false }
                return isPerfroming(action)
        }
    }
    
    @available(iOS 16.0, *)
    func isPerfroming(_ action: Selector) -> Bool {
        switch true {
            case _ where action == #selector(find(_:)):
                externalPublisher.send(.selector(.find))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.find)
            
            case _ where action == #selector(findAndReplace(_:)):
                externalPublisher.send(.selector(.findAndReplace))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.findAndReplace)
            
            case _ where action == #selector(findNext(_:)):
                externalPublisher.send(.selector(.findNext))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.findNext)
            
            case _ where action == #selector(findPrevious(_:)):
                externalPublisher.send(.selector(.findPrevious))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.findPrevious)
            
            case _ where action == #selector(useSelectionForFind(_:)):
                externalPublisher.send(.selector(.useSelectionForFind))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.useSelectionForFind)
            
            case _ where action == #selector(rename(_:)):
                externalPublisher.send(.selector(.rename))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.rename)
            
            case _ where action == #selector(move(_:)):
                externalPublisher.send(.selector(.move))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.move)
            
            case _ where action == #selector(export(_:)):
                externalPublisher.send(.selector(.export))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.export)
            
            case _ where action == #selector(duplicate(_:)):
                externalPublisher.send(.selector(.duplicate))
                return selectorTargets.isEmpty ? false : selectorTargets.contains(.duplicate)

            default:
                return false
        }
    }
    
}

// MARK: Protocol
extension AppTextField {
    
    func addTarget(_ event: UIControl.Event...) {
        event.forEach {
            actionTarget.addTarget($0)
        }
    }
    
    func removeTarget(_ event: UIControl.Event...) {
        event.forEach {
            actionTarget.removeTarget($0)
        }
    }
    
    func configureSelector(_ target: AppTextSelector...) {
        selectorTargets.removeAll()
        
        target.forEach {
            selectorTargets.insert($0)
        }
    }
    
}

// MARK: - AppTextFieldEvent
enum AppTextFieldEvent {
    case delegate(AppTextFieldDelegateEvent)
    case control(UIControl.Event)
    case selector(AppTextSelector)
}

// MARK: - AppTextSelector
enum AppTextSelector {
    case select
    case selectAll
    case cut
    case copy
    case delete
    case paste
    case pasteAndGo
    case pasteAndSearch
    case toggleBoldface
    case toggleItalics
    case toggleUnderline
    case increaseSize
    case decreaseSize
    case printContent
    case makeTextWritingDirectionLeftToRight
    case makeTextWritingDirectionRightToLeft
    case find
    case findAndReplace
    case findNext
    case findPrevious
    case useSelectionForFind
    case rename
    case move
    case export
    case duplicate
}
