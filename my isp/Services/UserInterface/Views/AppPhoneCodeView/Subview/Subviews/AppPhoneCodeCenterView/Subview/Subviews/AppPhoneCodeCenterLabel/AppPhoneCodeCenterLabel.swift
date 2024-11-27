import UIKit
import Combine

class AppPhoneCodeCenterLabel: UILabel, AppPhoneCodeCenterLabelProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppPhoneCodeCenterLabelInternalEvent, Never>
    
    private var style: AppPhoneCodeCenterLabelStyle?
    private var subscriptions: Set<AnyCancellable>
    
    init() {
        self.internalEventPublisher = PassthroughSubject<AppPhoneCodeCenterLabelInternalEvent, Never>()
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: .zero)
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension AppPhoneCodeCenterLabel {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        textAlignment = .center
        layer.masksToBounds = true
    }

    func internalEventHandler(_ event: AppPhoneCodeCenterLabelInternalEvent) {
        switch event {
            case .data(let value):
                style = value.style
                internalEventHandler(.update(text))
                setupLayout(value)
            
            case .update(let value):
                text = (value == .clear || value == nil) ? style?.symbol : value
                textColor = text == style?.symbol ? style?.symbolColor : style?.textColor
        }
    }
    
    func setupLayout(_ data: AppPhoneCodeCenterLabelData) {
        font = data.layout.font
        backgroundColor = data.layout.backgroundColor
        layer.cornerRadius = data.layout.cornerRadius
        layer.borderWidth = data.layout.borderWidth
        layer.borderColor = data.layout.borderColor
    }
    
}

// MARK: - AppPhoneCodeCenterLabelLayout
struct AppPhoneCodeCenterLabelLayout {
    var font = UIFont.systemFont(ofSize: 37)
    var backgroundColor = UIColor.interfaceManager.themePhoneCodeCenterLabelBackground()
    var cornerRadius = 10.fitWidth
    var borderWidth = CGFloat.interfaceManager.themePhoneCodeCenterLabelBorderWidth()
    var borderColor = UIColor.interfaceManager.darkBackgroundTwo().cgColor
}

// MARK: - AppPhoneCodeCenterLabelInternalEvent
enum AppPhoneCodeCenterLabelInternalEvent {
    case data(AppPhoneCodeCenterLabelData)
    case update(String?)
}
