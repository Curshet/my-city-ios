import UIKit
import SnapKit
import Combine

class MoreRootCollectionCellView: UIView {
    
    let dataPublisher: PassthroughSubject<MoreRootCollectionCellData, Never>
    
    private let titleLabel: UILabel
    private let subtitleLabel: UILabel
    private let actionIcon: UIImageView
    private var constraint: MoreRootCollectionCellViewConstraint
    private var subscriptions: Set<AnyCancellable>
    
    init(titleLabel: UILabel, subtitleLabel: UILabel, actionIcon: UIImageView) {
        self.dataPublisher = PassthroughSubject<MoreRootCollectionCellData, Never>()
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        self.actionIcon = actionIcon
        self.constraint = MoreRootCollectionCellViewConstraint()
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: .zero)
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension MoreRootCollectionCellView {
    
    func startConfiguration() {
        setupObservers()
        setupLayout()
        setupConstraints()
        setupStyle()
    }
    
    func setupObservers() {
        dataPublisher.sink { [weak self] in
            self?.setupData($0)
        }.store(in: &subscriptions)
        
        interfaceStylePublisher.sink { [weak self] _ in
            UIView.animate(withDuration: 1) {
                self?.setupStyle()
            }
        }.store(in: &subscriptions)
    }
    
    func setupLayout() {
        layer.shadowOpacity = 0.18
        layer.shadowOffset = .zero
        layer.shadowRadius = 6
        layer.cornerRadius = 15
        
        titleLabel.font = .systemFont(ofSize: 15.fitWidth)
        subtitleLabel.font = .systemFont(ofSize: 11.fitWidth)
        actionIcon.contentMode = .scaleAspectFit
        
        addSubviews(titleLabel, subtitleLabel, actionIcon)
    }
    
    func setupConstraints() {
        snp.makeConstraints {
            $0.width.equalTo(appInfo.screenBounds.width - 40)
        }
        
        actionIcon.snp.makeConstraints {
            constraint.actionIconSize = $0.width.height.equalTo(20).constraint
            constraint.actionIconRight = $0.right.equalToSuperview().inset(20).constraint
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            constraint.titleBottom = $0.bottom.equalToSuperview().inset(20).constraint
            $0.top.left.equalToSuperview().inset(20)
            $0.right.equalTo(actionIcon.snp.left).inset(-20)
        }
    }
    
    func setupStyle() {
        titleLabel.textColor = .interfaceStyle.themeMoreRootCellTitleText()
        subtitleLabel.textColor = .interfaceStyle.gray()
        actionIcon.setImageColor(.interfaceStyle.themeMoreRootCellSubtitleText())
        layer.shadowColor = .interfaceStyle.themeMoreRootCellShadow()
        layer.borderWidth = appInfo.interfaceStyle == .dark ? 0.5 : 0
        layer.borderColor = .interfaceStyle.darkBackgroundTwo().cgColor
        backgroundColor = .interfaceStyle.themeMoreRootCellBackground(subtitleLabel.text)
    }
    
    func setupData(_ data: MoreRootCollectionCellData) {
        configureTitle(data.title)
        configureSubtitle(data.subtitle)
        configureActionIcon(data.icon)
    }
    
    func configureTitle(_ text: String) {
        switch text.isEmpty {
            case true:
                titleLabel.text = "\("EMPTY_INFO".localized)..."
            
            case false:
                titleLabel.text = text
        }
    }
    
    func configureSubtitle(_ text: String?) {
        guard let text else { return }
        
        subtitleLabel.text = text
        backgroundColor = .interfaceStyle.themeMoreRootCellBackground(text)
        
        subtitleLabel.snp.makeConstraints {
            constraint.titleBottom?.deactivate()
            $0.top.equalTo(titleLabel.snp.bottom).offset(10.fitWidth)
            $0.right.equalTo(actionIcon.snp.left).inset(-20)
            $0.left.bottom.equalToSuperview().inset(20)
        }
    }
    
    func configureActionIcon(_ type: MoreRootCollectionCellIcon) {
        switch type {
            case .arrow:
                actionIcon.image = .interfaceStyle.themeMoreCellArrow()

                actionIcon.snp.makeConstraints {
                    constraint.actionIconSize?.deactivate()
                    constraint.actionIconRight?.deactivate()
                    $0.right.equalToSuperview().inset(23)
                    $0.width.height.equalTo(13)
                }
            
            case .share:
                actionIcon.image = .interfaceStyle.themeMoreCellShare()
            
            case .copy:
                actionIcon.image = .interfaceStyle.themeMoreCellCopy()
        }
    }
    
}

// MARK: MoreRootCollectionCellViewConstraint
fileprivate struct MoreRootCollectionCellViewConstraint {
    var titleBottom: Constraint?
    var actionIconSize: Constraint?
    var actionIconRight: Constraint?
}

// MARK: MoreRootCollectionCellData
struct MoreRootCollectionCellData {
    let title: String
    let subtitle: String?
    let icon: MoreRootCollectionCellIcon
}

// MARK: MoreRootCollectionCellIcon
enum MoreRootCollectionCellIcon {
    case arrow
    case share
    case copy
}
