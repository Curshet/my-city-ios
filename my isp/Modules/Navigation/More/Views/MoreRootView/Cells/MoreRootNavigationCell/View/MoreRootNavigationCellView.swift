import UIKit
import Combine
import SnapKit

class MoreRootNavigationCellView: AppTransformingView {
    
    let internalEventPublisher: PassthroughSubject<MoreRootNavigationCellViewInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MoreRootViewModelSelectEvent, Never>
    
    private let titleLabel: UILabel
    private let actionIcon: UIImageView
    private let externalPublisher: PassthroughSubject<MoreRootViewModelSelectEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(titleLabel: UILabel, actionIcon: UIImageView) {
        self.titleLabel = titleLabel
        self.actionIcon = actionIcon
        self.internalEventPublisher = PassthroughSubject<MoreRootNavigationCellViewInternalEvent, Never>()
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
private extension MoreRootNavigationCellView {
    
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
        actionIcon.contentMode = .scaleAspectFit
        addSubviews(titleLabel, actionIcon)
    }
    
    func internalEventHandler(_ event: MoreRootNavigationCellViewInternalEvent) {
        switch event {
            case .data(let value):
                dataHandler(value)
            
            case .reset:
                gestureRecognizers?.removeAll()
                subscriptions.removeAll()
                setupObservers()
        }
    }
    
    func dataHandler(_ data: Any) {
        guard let data = data as? MoreRootNavigationCellData else {
            logger.console(event: .error(info: "\(typeName) doesn't have a data for presenting"))
            return
        }
        
        setupLayout(data)
        setupGestureRecognizer(data)
        setupConstraints(data)
        setupSubviews(data)
    }
    
    func setupLayout(_ data: MoreRootNavigationCellData) {
        backgroundColor = data.layout.backgroundColor
        layer.cornerRadius = data.layout.cornerRadius
        layer.shadowOpacity = data.layout.shadowOpacity
        layer.shadowRadius = data.layout.shadowRadius
        layer.shadowOffset = data.layout.shadowOffset
        layer.shadowColor = data.layout.shadowColor
        layer.borderWidth = data.layout.borderWidth
        layer.borderColor = data.layout.borderColor
    }
    
    func setupGestureRecognizer(_ data: MoreRootNavigationCellData) {
        let gesture = AppTapGestureRecognizer()

        gesture.publisher.sink { [weak self] _ in
            self?.transform {
                self?.externalPublisher.send(data.event)
            }
        }.store(in: &subscriptions)
        
        addGesture(gesture)
    }
    
    func setupConstraints(_ data: MoreRootNavigationCellData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(data.layout.titleLabel.constraints.bottom)
            $0.top.equalToSuperview().inset(data.layout.titleLabel.constraints.top)
            $0.left.equalToSuperview().inset(data.layout.titleLabel.constraints.left)
            $0.right.equalTo(actionIcon.snp.left).inset(data.layout.titleLabel.constraints.right)
        }
    }
    
    func setupSubviews(_ data: MoreRootNavigationCellData) {
        setupTitleLabel(data)
        setupActionIcon(data)
    }
    
    func setupTitleLabel(_ data: MoreRootNavigationCellData) {
        titleLabel.text = data.title
        titleLabel.font = data.layout.titleLabel.font
        titleLabel.textColor = data.layout.titleLabel.textColor
    }
    
    func setupActionIcon(_ data: MoreRootNavigationCellData) {
        switch data.icon {
            case .arrow(let icon):
                actionIcon.image = icon?.setColor(data.layout.actionIcon.color)
                setupArrowIconContraints(data)
            
            case .share(let icon):
                actionIcon.image = icon?.setColor(data.layout.actionIcon.color)
                setupShareIconContraints(data)
        }
    }
    
    func setupArrowIconContraints(_ data: MoreRootNavigationCellData) {
        actionIcon.snp.remakeConstraints {
            $0.right.equalToSuperview().inset(data.layout.actionIcon.rightInsetOne)
            $0.width.equalTo(data.layout.actionIcon.sizeOne.width)
            $0.height.equalTo(data.layout.actionIcon.sizeOne.height)
            $0.centerY.equalToSuperview()
        }
    }
    
    func setupShareIconContraints(_ data: MoreRootNavigationCellData) {
        actionIcon.snp.remakeConstraints {
            $0.right.equalToSuperview().inset(data.layout.actionIcon.rightInsetTwo)
            $0.width.equalTo(data.layout.actionIcon.sizeTwo.width)
            $0.height.equalTo(data.layout.actionIcon.sizeTwo.height)
            $0.centerY.equalToSuperview()
        }
    }
    
}

// MARK: - MoreRootNavigationCellLayout
struct MoreRootNavigationCellLayout {
    let titleLabel = MoreRootNavigationTitleLabelLayout()
    let actionIcon = MoreRootNavigationActionIconLayout()
    let backgroundColor = UIColor.interfaceManager.themeMoreRootNavigationCellBackground()
    let borderWidth = CGFloat.interfaceManager.themeMoreRootItemBorderWidth()
    let borderColor = UIColor.interfaceManager.darkBackgroundTwo().cgColor
    let cornerRadius = 15.0
    let shadowOpacity = Float(0.18)
    let shadowRadius = 6.0
    let shadowOffset = CGSize.zero
    let shadowColor = UIColor.interfaceManager.themeMoreRootNavigationCellShadow()
}

// MARK: - MoreRootNavigationTitleLabelLayout
struct MoreRootNavigationTitleLabelLayout {
    let constraints = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: -20)
    let font = UIFont.systemFont(ofSize: 15.fitWidth)
    let textColor = UIColor.interfaceManager.themeMoreRootNavigationCellTitle()
}

// MARK: - MoreRootNavigationActionIconLayout
struct MoreRootNavigationActionIconLayout {
    let sizeOne = CGSize(width: 10.fitWidth, height: 10.fitWidth)
    let sizeTwo = CGSize(width: 16.5.fitWidth, height: 16.5.fitWidth)
    let rightInsetOne = 23
    let rightInsetTwo = 20
    let color = UIColor.interfaceManager.themeMoreRootNavigationCellActionIcon()
}

// MARK: - MoreRootNavigationCellViewInternalEvent
enum MoreRootNavigationCellViewInternalEvent {
    case data(Any)
    case reset
}
