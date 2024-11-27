import UIKit
import Combine
import SnapKit

class ProfileRootCenterUserInfoSectionView: AppHighlightingView, ProfileRootCenterUserInfoSectionViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<ProfileRootCenterUserInfoSectionData, Never>
    let externalEventPublisher: AnyPublisher<String?, Never>

    private let titleLabel: UILabel
    private let subtitleLabel: UILabel
    private let actionIcon: UIImageView
    private let externalPublisher: PassthroughSubject<String?, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(titleLabel: UILabel, subtitleLabel: UILabel, actionIcon: UIImageView) {
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        self.actionIcon = actionIcon
        self.internalEventPublisher = PassthroughSubject<ProfileRootCenterUserInfoSectionData, Never>()
        self.externalPublisher = PassthroughSubject<String?, Never>()
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
private extension ProfileRootCenterUserInfoSectionView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
        setupGestureRecognizer()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.setupLayout($0)
            self?.setupConstraints($0)
            self?.setupSubviews($0)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        actionIcon.contentMode = .scaleAspectFit
        addSubviews(titleLabel, subtitleLabel, actionIcon)
    }
    
    func setupGestureRecognizer() {
        let gesture = AppTapGestureRecognizer()
        
        gesture.publisher.sink { [weak self] _ in
            self?.highlight {
                self?.externalPublisher.send(self?.subtitleLabel.text)
            }
        }.store(in: &subscriptions)
        
        addGesture(gesture)
    }
    
    func setupLayout(_ data: ProfileRootCenterUserInfoSectionData) {
        layer.maskedCorners = data.layout.cornerMask
        layer.cornerRadius = data.layout.cornerRadius
        backgroundColor(data.layout.backgroundColor)
        configureHighlight(.setup(.touchInside(data.layout.configuration)))
    }

    func setupConstraints(_ data: ProfileRootCenterUserInfoSectionData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.top.equalTo(data.layout.topConstraint)
            $0.width.equalToSuperview()
            $0.height.equalTo(snp.height)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(data.layout.titleLabel.constraints.top)
            $0.left.equalToSuperview().inset(data.layout.titleLabel.constraints.left)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(data.layout.subtitleLabel.constraints.top)
            $0.left.equalToSuperview().inset(data.layout.subtitleLabel.constraints.left)
            $0.right.equalTo(actionIcon.snp.left).offset(data.layout.subtitleLabel.constraints.right)
            $0.bottom.equalToSuperview().inset(data.layout.subtitleLabel.constraints.bottom)
        }
        
        actionIcon.snp.makeConstraints {
            $0.right.equalToSuperview().inset(data.layout.actionIcon.constraints.right)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(data.layout.actionIcon.size.height)
            $0.width.equalTo(data.layout.actionIcon.size.width)
        }
    }
    
    func setupSubviews(_ data: ProfileRootCenterUserInfoSectionData) {
        titleLabel.text = data.title
        titleLabel.font = data.layout.titleLabel.font
        titleLabel.textColor = data.layout.titleLabel.textColor
        
        subtitleLabel.text = data.subtitle
        subtitleLabel.font = data.layout.subtitleLabel.font
        subtitleLabel.textColor = data.layout.subtitleLabel.textColor
        
        actionIcon.image = data.icon
        actionIcon.imageColor(data.layout.actionIcon.color)
    }
    
}

// MARK: - ProfileRootCenterUserInfoSectionLayout
struct ProfileRootCenterUserInfoSectionLayout {
    let titleLabel = ProfileRootCenterUserInfoTitleLabelLayout()
    let subtitleLabel = ProfileRootCenterUserInfoSubtitleLabelLayout()
    let actionIcon = ProfileRootCenterUserInfoActionIconLayout()
    let cornerMask: CACornerMask
    let cornerRadius = 15.0
    let backgroundColor = UIColor.interfaceManager.themeProfileRootCenterUserInfoCellBackground()
    let configuration = AppViewTransformation(durationStart: 0.25, durationFinish: 0.4, colorStart: nil, colorFinish: nil, transformStart: nil, transformFinish: nil)
    var topConstraint: ConstraintItem!
}

// MARK: - ProfileRootCenterUserInfoTitleLabelLayout
struct ProfileRootCenterUserInfoTitleLabelLayout {
    let constraints = UIEdgeInsets(top: 18.fitWidth, left: 20, bottom: 0, right: 0)
    let font = UIFont.systemFont(ofSize: 15.fitWidth)
    let textColor = UIColor.interfaceManager.themeProfileRootCenterUserInfoCellTitle()
}

// MARK: - ProfileRootUserInfoSubtitleLabelLayout
struct ProfileRootCenterUserInfoSubtitleLabelLayout {
    let constraints = UIEdgeInsets(top: 18, left: 20, bottom: 18.fitWidth, right: 20)
    let font = UIFont.systemFont(ofSize: 13.fitWidth)
    let textColor = UIColor.interfaceManager.themeProfileRootCenterUserInfoCellSubtitle()
}

// MARK: - ProfileRootCenterUserInfoActionIconLayout
struct ProfileRootCenterUserInfoActionIconLayout {
    let size = CGSize(width: 19.fitWidth, height: 19.fitWidth)
    let constraints = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    let color = UIColor.interfaceManager.themeProfileRootCenterUserInfoCellActionIcon()
}
