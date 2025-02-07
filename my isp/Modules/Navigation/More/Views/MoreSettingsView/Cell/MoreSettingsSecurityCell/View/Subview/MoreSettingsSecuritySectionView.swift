import UIKit
import Combine
import SnapKit

class MoreSettingsSecuritySectionView: UIView, MoreSettingsSecuritySectionViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreSettingsSecuritySectionData, Never>
    let externalEventPublisher: AnyPublisher<Void, Never>
    
    private let titleLabel: UILabel
    private let subtitleLabel: UILabel
    private let switсh: AppSwitchProtocol
    private let externalPublisher: PassthroughSubject<Void, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(titleLabel: UILabel, subtitleLabel: UILabel, switсh: AppSwitchProtocol) {
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        self.switсh = switсh
        self.internalEventPublisher = PassthroughSubject<MoreSettingsSecuritySectionData, Never>()
        self.externalPublisher = PassthroughSubject<Void, Never>()
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
private extension MoreSettingsSecuritySectionView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }

    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.setupConstraints($0)
            self?.setupSubviews($0)
        }.store(in: &subscriptions)
        
        switсh.publisher.sink { [weak self] _ in
            self?.externalPublisher.send()
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        titleLabel.textAlignment = .left
        subtitleLabel.textAlignment = .left
        addSubviews(titleLabel, subtitleLabel, switсh)
    }

    func setupConstraints(_ data: MoreSettingsSecuritySectionData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.top.equalTo(data.layout.topConstraint).offset(data.layout.constraints.top)
            $0.leading.equalToSuperview().inset(data.layout.constraints.left)
            $0.trailing.equalToSuperview().inset(data.layout.constraints.right)
            $0.height.equalTo(snp.height)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(data.layout.subtitleLabel.constraints.top)
            $0.leading.bottom.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        switсh.snp.makeConstraints {
            $0.top.equalToSuperview().inset(data.layout.switсh.constraints.top)
            $0.trailing.equalToSuperview()
        }
    }
    
    func setupSubviews(_ data: MoreSettingsSecuritySectionData) {
        titleLabel.text = data.title
        titleLabel.font = data.layout.titleLabel.font
        titleLabel.textColor = data.layout.titleLabel.textColor
        
        subtitleLabel.text = data.subtitle
        subtitleLabel.font = data.layout.subtitleLabel.font
        subtitleLabel.textColor = data.layout.subtitleLabel.textColor
        
        switсh.isOn = data.isOn
        switсh.onTintColor = data.layout.switсh.tintColor
    }
    
}

// MARK: - MoreSettingsBiometricsSectionLayout
struct MoreSettingsSecuritySectionLayout {
    let titleLabel = MoreSettingsSecurityTitleLabelLayout()
    let subtitleLabel = MoreSettingsSecuritySubtitleLabelLayout()
    let switсh = MoreSettingsSecuritySwitchLayout()
    let constraints = UIEdgeInsets(top: 22, left: 20, bottom: 0, right: 20)
    var topConstraint: ConstraintItem!
}

// MARK: - MoreSettingsSecurityTitleLabelLayout
struct MoreSettingsSecurityTitleLabelLayout {
    let constraints = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    let font = UIFont.systemFont(ofSize: 14.fitWidth)
    let textColor = UIColor.interfaceManager.themeMoreSettingsSecurityCellSectionTitle()
}

// MARK: - MoreSettingsSecuritySubtitleLabelLayout
struct MoreSettingsSecuritySubtitleLabelLayout {
    let constraints = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
    let font = UIFont.systemFont(ofSize: 11.2.fitWidth)
    let textColor = UIColor.interfaceManager.themeMoreSettingsSecurityCellSectionSubtitle()
}

// MARK: - MoreSettingsSecuritySwitchLayout
struct MoreSettingsSecuritySwitchLayout {
    let constraints = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
    let tintColor = UIColor.interfaceManager.lightPurple()
}
