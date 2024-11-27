import UIKit
import Combine
import SnapKit

class MoreRootSystemInfoCellView: AppTransformingView {
    
    let internalEventPublisher: PassthroughSubject<Any, Never>
    let externalEventPublisher: AnyPublisher<MoreRootViewModelSelectEvent, Never>
    
    private let titleLabel: UILabel
    private let subtitleLabel: UILabel
    private let actionIcon: UIImageView
    private let externalPublisher: PassthroughSubject<MoreRootViewModelSelectEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(titleLabel: UILabel, subtitleLabel: UILabel, actionIcon: UIImageView) {
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        self.actionIcon = actionIcon
        self.internalEventPublisher = PassthroughSubject<Any, Never>()
        self.externalPublisher = PassthroughSubject<MoreRootViewModelSelectEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension MoreRootSystemInfoCellView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
        setupGestureRecognizer()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        actionIcon.contentMode = .scaleAspectFit
        addSubviews(titleLabel, subtitleLabel, actionIcon)
    }
    
    func setupGestureRecognizer() {
        let gesture = AppTapGestureRecognizer()
        
        gesture.publisher.sink { [weak self] _ in
            self?.transform {
                self?.externalPublisher.send(.copySystemInfo)
            }
        }.store(in: &subscriptions)
        
        addGesture(gesture)
    }
    
    func internalEventHandler(_ data: Any) {
        guard let data = data as? MoreRootSystemInfoCellData else {
            logger.console(event: .error(info: "\(typeName) doesn't have a data for presenting"))
            return
        }
        
        setupLayout(data)
        setupConstraints(data)
        setupSubviews(data)
    }
    
    func setupLayout(_ data: MoreRootSystemInfoCellData) {
        backgroundColor = data.layout.backgroundColor
        layer.cornerRadius = data.layout.cornerRadius
        layer.shadowOpacity = data.layout.shadowOpacity
        layer.shadowRadius = data.layout.shadowRadius
        layer.shadowOffset = data.layout.shadowOffset
        layer.shadowColor = data.layout.shadowColor
        layer.borderWidth = data.layout.borderWidth
        layer.borderColor = data.layout.borderColor
    }
    
    func setupConstraints(_ data: MoreRootSystemInfoCellData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(data.layout.titleLabel.constraints.top)
            $0.left.equalToSuperview().inset(data.layout.titleLabel.constraints.left)
            $0.right.equalTo(actionIcon.snp.left).inset(data.layout.titleLabel.constraints.right)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(data.layout.subtitleLabel.constraints.top)
            $0.left.equalToSuperview().inset(data.layout.subtitleLabel.constraints.left)
            $0.right.equalTo(actionIcon.snp.left).inset(data.layout.subtitleLabel.constraints.right)
            $0.bottom.equalToSuperview().inset(data.layout.subtitleLabel.constraints.bottom)
        }
        
        actionIcon.snp.makeConstraints {
            $0.right.equalToSuperview().inset(data.layout.actionIcon.constraints.right)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(data.layout.actionIcon.size.width)
            $0.height.equalTo(data.layout.actionIcon.size.height)
        }
    }
    
    func setupSubviews(_ data: MoreRootSystemInfoCellData) {
        titleLabel.text = data.title
        titleLabel.textColor = data.layout.titleLabel.textColor
        titleLabel.font = data.layout.titleLabel.font
        
        subtitleLabel.text = data.subtitle
        subtitleLabel.textColor = data.layout.subtitleLabel.textColor
        subtitleLabel.font = data.layout.subtitleLabel.font
        actionIcon.image = data.icon?.setColor(data.layout.actionIcon.color)
    }
    
}

// MARK: - MoreRootSystemInfoCellLayout
struct MoreRootSystemInfoCellLayout {
    let titleLabel = MoreRootSystemInfoTitleLabelLayout()
    let subtitleLabel = MoreRootSystemInfoSubtitleLabelLayout()
    let actionIcon = MoreRootSystemInfoActionIconLayout()
    let backgroundColor = UIColor.interfaceManager.themeMoreRootSystemInfoCellBackground()
    let borderWidth = CGFloat.interfaceManager.themeMoreRootItemBorderWidth()
    let borderColor = UIColor.interfaceManager.darkBackgroundTwo().cgColor
    let cornerRadius = 15.0
    let shadowOpacity = Float(0.18)
    let shadowRadius = 6.0
    let shadowOffset = CGSize.zero
    let shadowColor = UIColor.interfaceManager.themeMoreRootSystemInfoCellShadow()
}

// MARK: - MoreRootSystemInfoTitleLabelLayout
struct MoreRootSystemInfoTitleLabelLayout {
    let constraints = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: -20)
    let font = UIFont.systemFont(ofSize: 15.fitWidth)
    let textColor = UIColor.interfaceManager.themeMoreRootSystemInfoCellTitle()
}

// MARK: - MoreRootSystemInfoSubtitleLabelLayout
struct MoreRootSystemInfoSubtitleLabelLayout {
    let constraints = UIEdgeInsets(top: 12.fitWidth, left: 20, bottom: 23, right: -20)
    let font = UIFont.systemFont(ofSize: 11.2.fitWidth)
    let textColor = UIColor.interfaceManager.themeMoreRootSystemInfoCellSubtitle()
}

// MARK: - MoreRootSystemInfoActionIconLayout
struct MoreRootSystemInfoActionIconLayout {
    let constraints = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    let size = CGSize(width: 16.5.fitWidth, height: 16.5.fitWidth)
    let color = UIColor.interfaceManager.themeMoreRootSystemInfoCellActionIcon()
}
