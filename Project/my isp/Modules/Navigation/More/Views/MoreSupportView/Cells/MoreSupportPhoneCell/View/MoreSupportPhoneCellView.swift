import UIKit
import Combine
import SnapKit

class MoreSupportPhoneCellView: AppTransformingView {
    
    let internalEventPublisher: PassthroughSubject<Any, Never>
    let externalEventPublisher: AnyPublisher<MoreSupportViewModelSelectEvent, Never>
    
    private let titleLabel: UILabel
    private let phoneLabel: UILabel
    private let phoneIcon: UIImageView
    private let externalPublisher: PassthroughSubject<MoreSupportViewModelSelectEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(titleLabel: UILabel, phoneLabel: UILabel, phoneIcon: UIImageView) {
        self.titleLabel = titleLabel
        self.phoneLabel = phoneLabel
        self.phoneIcon = phoneIcon
        self.internalEventPublisher = PassthroughSubject<Any, Never>()
        self.externalPublisher = PassthroughSubject<MoreSupportViewModelSelectEvent, Never>()
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
private extension MoreSupportPhoneCellView {
    
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
        phoneLabel.textAlignment = .center
        phoneIcon.contentMode = .scaleAspectFit
        titleLabel.textAlignment = .center
        addSubviews(titleLabel, phoneIcon, phoneLabel)
    }
    
    func setupGestureRecognizer() {
        let gesture = AppTapGestureRecognizer()
        
        gesture.publisher.sink { [weak self] _ in
            self?.transform {
                self?.externalPublisher.send(.phone)
            }
        }.store(in: &subscriptions)
        
        addGesture(gesture)
    }
    
    func internalEventHandler(_ data: Any) {
        guard let data = data as? MoreSupportPhoneCellData else {
            logger.console(event: .error(info: "\(typeName) doesn't have a data for presenting"))
            return
        }
        
        setupLayout(data)
        setupConstraints(data)
        setupSubviews(data)
    }
    
    func setupLayout(_ data: MoreSupportPhoneCellData) {
        backgroundColor = data.layout.backgroundColor
        layer.cornerRadius = data.layout.cornerRadius
        layer.shadowOpacity = data.layout.shadowOpacity
        layer.shadowRadius = data.layout.shadowRadius
        layer.shadowOffset = data.layout.shadowOffset
        layer.shadowColor = data.layout.shadowColor
        layer.borderWidth = data.layout.borderWidth
        layer.borderColor = data.layout.borderColor
    }
    
    func setupConstraints(_ data: MoreSupportPhoneCellData) {
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
        
        phoneLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(data.layout.phoneLabel.constraints.top)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(phoneLabel.snp.width)
            $0.bottom.equalToSuperview().inset(data.layout.phoneLabel.constraints.bottom)
        }
        
        phoneIcon.snp.makeConstraints {
            $0.trailing.equalTo(phoneLabel.snp.leading).inset(data.layout.phoneIcon.constraints.right)
            $0.centerY.equalTo(phoneLabel.snp.centerY)
            $0.width.equalTo(data.layout.phoneIcon.size.width)
            $0.height.equalTo(data.layout.phoneIcon.size.height)
            $0.bottom.equalToSuperview().inset(data.layout.phoneIcon.constraints.bottom)
        }
    }
    
    func setupSubviews(_ data: MoreSupportPhoneCellData) {
        titleLabel.text = data.title
        titleLabel.font = data.layout.titleLabel.font
        titleLabel.textColor = data.layout.titleLabel.textColor
        titleLabel.numberOfLines = data.layout.titleLabel.numberOfLines
        titleLabel.interlineSpacing(data.layout.titleLabel.interlineSpacing)
        
        phoneLabel.text = data.phone
        phoneLabel.font = data.layout.phoneLabel.font
        phoneLabel.textColor = data.layout.phoneLabel.textColor
        phoneIcon.image = data.icon?.setColor(data.layout.phoneIcon.color)
    }

}

// MARK: - MoreSupportPhoneCellLayout
struct MoreSupportPhoneCellLayout {
    let titleLabel = MoreSupportPhoneTitleLabelLayout()
    let phoneIcon = MoreSupportPhoneIconLayout()
    let phoneLabel = MoreSupportPhoneLabelLayout()
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

// MARK: - MoreSupportPhoneTitleLabelLayout
struct MoreSupportPhoneTitleLabelLayout {
    let constraints = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    let numberOfLines = 0
    let interlineSpacing = 5.0
    let font = UIFont.systemFont(ofSize: 15.fitWidth)
    let textColor = UIColor.interfaceManager.themeMoreSupportCellTitle()
}

// MARK: - MoreSupportPhoneIconLayout
struct MoreSupportPhoneIconLayout {
    let constraints = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: -13)
    let size = CGSize(width: 25.fitWidth, height: 25.fitWidth)
    let color = UIColor.interfaceManager.themeMoreSupportPhoneCellIcon()
}

// MARK: - MoreSupportPhoneLabelLayout
struct MoreSupportPhoneLabelLayout {
    let constraints = UIEdgeInsets(top: 12.fitWidth, left: 0, bottom: 20, right: 0)
    let font = UIFont.systemFont(ofSize: 15.fitWidth)
    let textColor = UIColor.interfaceManager.themeMoreSupportPhoneCellSubtitle()
}
