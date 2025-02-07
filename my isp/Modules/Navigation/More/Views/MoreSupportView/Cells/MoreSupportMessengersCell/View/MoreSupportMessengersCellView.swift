import UIKit
import Combine
import SnapKit

class MoreSupportMessengersCellView: UIView {
    
    let internalEventPublisher: PassthroughSubject<Any, Never>
    let externalEventPublisher: AnyPublisher<MoreSupportViewModelSelectEvent, Never>
    
    private let titleLabel: UILabel
    private let stackView: UIStackView
    private let telegramButton: AppButtonProtocol
    private let whatsAppButton: AppButtonProtocol
    private let viberButton: AppButtonProtocol
    private let externalPublisher: PassthroughSubject<MoreSupportViewModelSelectEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(titleLabel: UILabel, stackView: UIStackView, telegramButton: AppButtonProtocol, whatsAppButton: AppButtonProtocol, viberButton: AppButtonProtocol) {
        self.titleLabel = titleLabel
        self.stackView = stackView
        self.telegramButton = telegramButton
        self.whatsAppButton = whatsAppButton
        self.viberButton = viberButton
        self.internalEventPublisher = PassthroughSubject<Any, Never>()
        self.externalPublisher = PassthroughSubject<MoreSupportViewModelSelectEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: .zero)
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension MoreSupportMessengersCellView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        telegramButton.publisher.sink { [weak self] _ in
            self?.externalPublisher.send(.telegram)
        }.store(in: &subscriptions)
        
        whatsAppButton.publisher.sink { [weak self] _ in
            self?.externalPublisher.send(.whatsApp)
        }.store(in: &subscriptions)
        
        viberButton.publisher.sink { [weak self] _ in
            self?.externalPublisher.send(.viber)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        titleLabel.textAlignment = .center
        stackView.axis = .horizontal
        stackView.addArrangedSubviews(telegramButton, whatsAppButton, viberButton)
        addSubviews(titleLabel, stackView)
    }
    
    func internalEventHandler(_ data: Any) {
        guard let data = data as? MoreSupportMessengersCellData else {
            logger.console(event: .error(info: "\(typeName) doesn't have a data for presenting"))
            return
        }
        
        setupLayout(data)
        setupConstraints(data)
        setupSubviews(data)
    }
    
    func setupLayout(_ data: MoreSupportMessengersCellData) {
        backgroundColor = data.layout.backgroundColor
        layer.cornerRadius = data.layout.cornerRadius
        layer.shadowOpacity = data.layout.shadowOpacity
        layer.shadowRadius = data.layout.shadowRadius
        layer.shadowOffset = data.layout.shadowOffset
        layer.shadowColor = data.layout.shadowColor
        layer.borderWidth = data.layout.borderWidth
        layer.borderColor = data.layout.borderColor
    }
    
    func setupConstraints(_ data: MoreSupportMessengersCellData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(data.layout.size.width)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(data.layout.titleLabel.constraints.top)
            $0.leading.equalToSuperview().inset(data.layout.titleLabel.constraints.left)
            $0.trailing.equalToSuperview().inset(data.layout.titleLabel.constraints.right)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(data.layout.stackView.constraints.top)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(data.layout.stackView.constraints.bottom)
        }
        
        telegramButton.snp.makeConstraints {
            $0.height.equalTo(data.layout.button.size.height)
            $0.width.equalTo(data.layout.button.size.width)
        }
        
        whatsAppButton.snp.makeConstraints {
            $0.height.equalTo(data.layout.button.size.height)
            $0.width.equalTo(data.layout.button.size.width)
        }
        
        viberButton.snp.makeConstraints {
            $0.height.equalTo(data.layout.button.size.height)
            $0.width.equalTo(data.layout.button.size.width)
        }
    }
    
    func setupSubviews(_ data: MoreSupportMessengersCellData) {
        setupTitleLabel(data)
        stackView.spacing = data.layout.stackView.spacing
        setupMessengersIcons(data)
    }
    
    func setupTitleLabel(_ data: MoreSupportMessengersCellData) {
        titleLabel.text = data.title
        titleLabel.textColor = data.layout.titleLabel.textColor
        titleLabel.font = data.layout.titleLabel.font
        titleLabel.numberOfLines = data.layout.titleLabel.numberOfLines
        titleLabel.interlineSpacing(data.layout.titleLabel.interlineSpacing)
    }
    
    func setupMessengersIcons(_ data: MoreSupportMessengersCellData) {
        data.icons.forEach {
            switch $0 {
                case .telegram(let icon):
                    telegramButton.setImage(icon, for: .normal)
                    telegramButton.setImage(icon, for: .highlighted)
                    telegramButton.configureTransform(.setup(.touchesBegan(data.layout.button.touchesBegan)))
                    telegramButton.configureTransform(.setup(.touchInside(data.layout.button.touchInside)))
                
                case .whatsApp(let icon):
                    whatsAppButton.setImage(icon, for: .normal)
                    whatsAppButton.setImage(icon, for: .highlighted)
                    whatsAppButton.configureTransform(.setup(.touchesBegan(data.layout.button.touchesBegan)))
                    whatsAppButton.configureTransform(.setup(.touchInside(data.layout.button.touchInside)))
                
                case .viber(let icon):
                    viberButton.setImage(icon, for: .normal)
                    viberButton.setImage(icon, for: .highlighted)
                    viberButton.configureTransform(.setup(.touchesBegan(data.layout.button.touchesBegan)))
                    viberButton.configureTransform(.setup(.touchInside(data.layout.button.touchInside)))
            }
        }
    }
    
}

// MARK: - MoreSupportMessengersCellLayout
struct MoreSupportMessengersCellLayout {
    let titleLabel = MoreSupportMessengersTitleLabelLayout()
    let button = MoreSupportMessengersButtonLayout()
    let stackView = MoreSupportMessengersStackViewLayout()
    let size: CGSize
    let backgroundColor = UIColor.interfaceManager.themeMoreSupportCellBackground()
    let borderWidth = CGFloat.interfaceManager.themeMoreSupportItemBorderWidth()
    let borderColor = UIColor.interfaceManager.darkBackgroundTwo().cgColor
    let cornerRadius = 15.0
    let shadowOpacity = Float(0.18)
    let shadowRadius = 6.0
    let shadowOffset = CGSize.zero
    let shadowColor = UIColor.interfaceManager.themeMoreSupportCellShadow()
}

// MARK: - MoreSupportMessengersTitleLabelLayout
struct MoreSupportMessengersTitleLabelLayout {
    let constraints = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    let numberOfLines = 0
    let interlineSpacing = 5.0
    let font = UIFont.systemFont(ofSize: 15.fitWidth)
    let textColor = UIColor.interfaceManager.themeMoreSupportCellTitle()
}

// MARK: - MoreSupportMessengersButtonLayout
struct MoreSupportMessengersButtonLayout {
    let size = CGSize(width: 40, height: 40)
    let touchesBegan = AppViewAnimation(duration: 0.2, color: nil, transform: .init(scaleX: 1.11, y: 1.11))
    let touchInside = AppViewTransformation(durationStart: 0.12, durationFinish: 0.2, colorStart: nil, colorFinish: nil, transformStart: .init(scaleX: 0.7, y: 0.7), transformFinish: .identity)
}

// MARK: - MoreSupportMessengersStackViewLayout
struct MoreSupportMessengersStackViewLayout {
    let constraints = UIEdgeInsets(top: 25, left: 0, bottom: 20, right: 0)
    let spacing = 40.0
}
