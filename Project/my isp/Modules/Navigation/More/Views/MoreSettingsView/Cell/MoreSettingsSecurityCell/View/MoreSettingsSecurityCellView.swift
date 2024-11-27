import UIKit
import Combine
import SnapKit

class MoreSettingsSecurityCellView: UIView {
    
    let internalEventPublisher: PassthroughSubject<Any, Never>
    let externalEventPublisher: AnyPublisher<MoreSettingsViewModelSelectEvent, Never>

    private let headerLabel: UILabel
    private let biometricsView: MoreSettingsSecuritySectionViewProtocol
    private let passwordView: MoreSettingsSecuritySectionViewProtocol
    private let separator: UIView
    private let externalPublisher: PassthroughSubject<MoreSettingsViewModelSelectEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(headerLabel: UILabel, biometricsView: MoreSettingsSecuritySectionViewProtocol, passwordView: MoreSettingsSecuritySectionViewProtocol, separator: UIView) {
        self.headerLabel = headerLabel
        self.biometricsView = biometricsView
        self.passwordView = passwordView
        self.separator = separator
        self.internalEventPublisher = PassthroughSubject<Any, Never>()
        self.externalPublisher = PassthroughSubject<MoreSettingsViewModelSelectEvent, Never>()
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
private extension MoreSettingsSecurityCellView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }

    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        biometricsView.externalEventPublisher.sink { [weak self] in
            self?.externalPublisher.send(.biometrics)
        }.store(in: &subscriptions)
        
        passwordView.externalEventPublisher.sink { [weak self] in
            self?.externalPublisher.send(.password)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        headerLabel.textAlignment = .left
        addSubviews(headerLabel, biometricsView, separator, passwordView)
    }
    
    func internalEventHandler(_ data: Any) {
        guard var data = data as? MoreSettingsSecurityCellData else {
            logger.console(event: .error(info: "\(typeName) doesn't have a data for presenting"))
            return
        }
        
        setupLayout(data)
        setupConstraints(data)
        setupSubviews(&data)
    }

    func setupLayout(_ data: MoreSettingsSecurityCellData) {
        backgroundColor = data.layout.backgroundColor
        layer.cornerRadius = data.layout.cornerRadius
        layer.shadowOpacity = data.layout.shadowOpacity
        layer.shadowRadius = data.layout.shadowRadius
        layer.shadowOffset = data.layout.shadowOffset
        layer.borderColor = data.layout.borderColor
        layer.borderWidth = data.layout.borderWidth
        layer.shadowColor = data.layout.shadowColor
    }
    
    func setupConstraints(_ data: MoreSettingsSecurityCellData) {
        guard constraints.isEmpty else { return }

        snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.equalTo(data.layout.size.width)
            $0.bottom.equalTo(passwordView.snp.bottom).offset(data.layout.constraints.bottom)
        }
        
        headerLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(data.layout.headerLabel.constraints.top)
            $0.leading.equalToSuperview().inset(data.layout.headerLabel.constraints.left)
            $0.height.equalTo(headerLabel.snp.height)
        }

        separator.snp.makeConstraints {
            $0.top.equalTo(biometricsView.snp.bottom).offset(data.layout.separator.constraints.top)
            $0.height.equalTo(data.layout.separator.size.height)
            $0.width.equalToSuperview()
        }
    }
    
    func setupSubviews(_ data: inout MoreSettingsSecurityCellData) {
        headerLabel.text = data.header
        headerLabel.font = data.layout.headerLabel.font
        headerLabel.textColor = data.layout.headerLabel.textColor
        separator.backgroundColor = data.layout.separator.backgroundColor
        data.biometrics.layout.topConstraint = headerLabel.snp.bottom
        data.password.layout.topConstraint = separator.snp.bottom
        biometricsView.internalEventPublisher.send(data.biometrics)
        passwordView.internalEventPublisher.send(data.password)
    }

}

// MARK: - MoreSettingsSecurityCellLayout
struct MoreSettingsSecurityCellLayout {
    let headerLabel = MoreSettingsSecurityHeaderLabelLayout()
    let separator = MoreSettingsSecuritySeparatorLayout()
    let size: CGSize
    let constraints = UIEdgeInsets(top: 0, left: 0, bottom: 23, right: 0)
    let backgroundColor = UIColor.interfaceManager.themeMoreSettingsSecurityCellBackground()
    let borderWidth = CGFloat.interfaceManager.themeMoreSettingsItemBorderWidth()
    let borderColor = CGColor.interfaceManager.darkBackgroundTwo().cgColor
    let cornerRadius = 15.0
    let shadowOpacity = Float(0.18)
    let shadowRadius = 6.0
    let shadowOffset = CGSize.zero
    let shadowColor = CGColor.interfaceManager.themeMoreSettingsSecurityCellShadow()
}

// MARK: - MoreSettingsSecurityHeaderLabelLayout
struct MoreSettingsSecurityHeaderLabelLayout {
    let constraints = UIEdgeInsets(top: 15, left: 20, bottom: 0, right: 0)
    let font = UIFont.boldSystemFont(ofSize: 17.fitWidth)
    let textColor = UIColor.interfaceManager.themeMoreSettingsSecurityCellHeader()
}

// MARK: - MoreSettingsSecuritySeparatorLayout
struct MoreSettingsSecuritySeparatorLayout {
    let constraints = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
    let size = CGSize(width: 0, height: 2)
    let backgroundColor = UIColor.interfaceManager.themeBackgroundOne()
}
