import UIKit
import Combine
import SnapKit

class AppPhoneCodeCenterStackView: UIStackView, AppPhoneCodeCenterStackViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppPhoneCodeCenterStackViewInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AppPhoneCodeViewExternalEvent, Never>
    
    private weak var builder: AppPhoneCodeBuilderProtocol?
    private let textField: AppPhoneCodeCenterTextFieldProtocol
    private let externalPublisher: PassthroughSubject<AppPhoneCodeViewExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>

    init(builder: AppPhoneCodeBuilderProtocol, textField: AppPhoneCodeCenterTextFieldProtocol) {
        self.builder = builder
        self.textField = textField
        self.externalPublisher = PassthroughSubject<AppPhoneCodeViewExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.internalEventPublisher = PassthroughSubject<AppPhoneCodeCenterStackViewInternalEvent, Never>()
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: .zero)
        startConfiguration()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
    
}

// MARK: Private
private extension AppPhoneCodeCenterStackView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        textField.externalEventPublisher.sink { [weak self] in
            self?.textFieldEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        axis = .horizontal
        distribution = .fillEqually
        addSubview(textField)
    }
    
    func internalEventHandler(_ event: AppPhoneCodeCenterStackViewInternalEvent) {
        switch event {
            case .data(let value):
                spacing = value.layout.spacing
                setupConstraints(value)
                setupSubviews(value)

            case .reset:
                textField.becomeFirstResponder()
                fallthrough
            
            case .clear:
                textField.internalEventPublisher.send(.clear)
        }
    }
    
    func textFieldEventHandler(_ event: AppPhoneCodeCenterTextFieldExternalEvent) {
        switch event {
            case .input(let text):
                setupLabels(.update(text))
                externalPublisher.send(.input)
            
            case .validation(let text):
                externalPublisher.send(.validation(text))
        }
    }

    func setupConstraints(_ data: AppPhoneCodeCenterStackData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(data.layout.constraints.left)
            $0.trailing.equalToSuperview().inset(data.layout.constraints.right)
            $0.height.equalTo(data.layout.size.height)
        }
    }
    
    func setupSubviews(_ data: AppPhoneCodeCenterStackData) {
        textField.internalEventPublisher.send(.target(data.target))
        
        switch true {
            case _ where arrangedSubviews.isEmpty:
                setupArrangedSubviews(data)
                textField.becomeFirstResponder()

            case _ where arrangedSubviews.count != data.target.rawValue:
                removeArrangedSubviews()
                setupArrangedSubviews(data)
            
            default:
                setupLabels(.data(data.label))
        }
    }
    
    func setupArrangedSubviews(_ data: AppPhoneCodeCenterStackData) {
        for _ in 0..<data.target.rawValue {
            guard let subview = builder?.phoneCodeCenterLabel else {
                logger.console(event: .error(info: "Phone code stack view doesn't have arranged subviews for presenting"))
                return
            }
            
            addArrangedSubview(subview)
        }
        
        textField.internalEventPublisher.send(.clear)
        setupLabels(.data(data.label))
    }
    
    func setupLabels(_ target: AppPhoneCodeCenterStackViewTarget) {
        for (index, subview) in arrangedSubviews.enumerated() {
            guard let label = subview as? AppPhoneCodeCenterLabelProtocol else {
                logger.console(event: .error(info: "Phone code stack view can't setup data to arranged subviews"))
                return
            }
            
            switch target {
                case .data(let value):
                    label.internalEventPublisher.send(value)
                
                case .update(let text):
                    label.internalEventPublisher.send(.update(text?[safe: index]))
            }
        }
    }
    
}

// MARK: - AppPhoneCodeCenterStackViewTarget
fileprivate enum AppPhoneCodeCenterStackViewTarget {
    case data(AppPhoneCodeCenterLabelInternalEvent)
    case update([String]?)
}

// MARK: - AppPhoneCodeCenterStackViewLayout
struct AppPhoneCodeCenterStackViewLayout {
    var constraints = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
    var size = CGSize(width: 0, height: 60.fitWidth)
    var spacing = 11.0
}

// MARK: - AppPhoneCodeCenterStackViewInternalEvent
enum AppPhoneCodeCenterStackViewInternalEvent {
    case data(AppPhoneCodeCenterStackData)
    case reset
    case clear
}
