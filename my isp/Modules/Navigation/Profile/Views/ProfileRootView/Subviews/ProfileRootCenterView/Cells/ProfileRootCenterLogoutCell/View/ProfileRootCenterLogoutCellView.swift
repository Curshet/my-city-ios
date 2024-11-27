import UIKit
import Combine
import SnapKit

class ProfileRootCenterLogoutCellView: UIView {
    
    let internalEventPublisher: PassthroughSubject<Any, Never>
    let externalEventPublisher: AnyPublisher<ProfileRootCenterViewExternalEvent, Never>

    private let logoutLabel: UILabel
    private let deleteLabel: UILabel
    private let separator: UIView
    private let externalPublisher: PassthroughSubject<ProfileRootCenterViewExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(logoutLabel: UILabel, deleteLabel: UILabel, separator: UIView) {
        self.logoutLabel = logoutLabel
        self.deleteLabel = deleteLabel
        self.separator = separator
        self.internalEventPublisher = PassthroughSubject<Any, Never>()
        self.externalPublisher = PassthroughSubject<ProfileRootCenterViewExternalEvent, Never>()
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
private extension ProfileRootCenterLogoutCellView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
        setupGestureRecognizers()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        logoutLabel.textAlignment = .center
        deleteLabel.textAlignment = .center
        addSubviews(logoutLabel, separator, deleteLabel)
    }
    
    func setupGestureRecognizers() {
        let logoutGesture = AppTapGestureRecognizer()
        let deleteGesture = AppTapGestureRecognizer()

        logoutGesture.publisher.sink { [weak self] _ in
            self?.externalPublisher.send(.logout)
        }.store(in: &subscriptions)

        deleteGesture.publisher.sink { [weak self] _ in
            self?.externalPublisher.send(.delete)
        }.store(in: &subscriptions)

        logoutLabel.addGesture(logoutGesture)
        deleteLabel.addGesture(deleteGesture)
    }

    func internalEventHandler(_ data: Any) {
        guard let data = data as? ProfileRootCenterLogoutCellData else {
            logger.console(event: .error(info: "\(typeName) doesn't have a data for presenting"))
            return
        }

        setupLayout(data)
        setupConstraints(data)
        setupSubviews(data)
    }
    
    func setupLayout(_ data: ProfileRootCenterLogoutCellData) {
        backgroundColor = data.layout.backgroundColor
        layer.shadowOpacity = data.layout.shadowOpacity
        layer.shadowOffset = data.layout.shadowOffset
        layer.shadowRadius = data.layout.shadowRadius
        layer.borderColor = data.layout.borderColor
        layer.borderWidth = data.layout.borderWidth
        layer.shadowColor = data.layout.shadowColor
        layer.cornerRadius = data.layout.cornerRadius
    }
    
    func setupConstraints(_ data: ProfileRootCenterLogoutCellData) {
        guard constraints.isEmpty else { return }

        snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(data.layout.size.width)
        }
        
        logoutLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(data.layout.logoutLabel.size.height)
        }
        
        separator.snp.makeConstraints {
            $0.top.equalTo(logoutLabel.snp.bottom).offset(data.layout.separator.constraints.top)
            $0.height.equalTo(data.layout.separator.size.height)
            $0.width.equalToSuperview()
        }
        
        deleteLabel.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(data.layout.deleteLabel.constraints.top)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(data.layout.deleteLabel.size.height)
        }
    }
    
    func setupSubviews(_ value: ProfileRootCenterLogoutCellData) {
        logoutLabel.text = value.exitTitle
        logoutLabel.textColor = value.layout.logoutLabel.textColor
        logoutLabel.font = value.layout.logoutLabel.font
        separator.backgroundColor = value.layout.separator.backgroundColor
        deleteLabel.text = value.deleteTitle
        deleteLabel.textColor = value.layout.deleteLabel.textColor
        deleteLabel.font = value.layout.deleteLabel.font
    }

}

// MARK: - ProfileRootCenterLogoutCellLayout
struct ProfileRootCenterLogoutCellLayout {
    let logoutLabel = ProfileRootCenterLogoutLabelLayout()
    let separator = ProfileRootCenterLogoutSeparatorLayout()
    let deleteLabel = ProfileRootCenterLogoutDeleteLabelLayout()
    let size: CGSize
    let borderWidth = CGFloat.interfaceManager.themeProfileRootItemBorderWidth()
    let borderColor = CGColor.interfaceManager.darkBackgroundTwo().cgColor
    let shadowOpacity = Float(0.18)
    let shadowOffset = CGSize.zero
    let shadowRadius = 6.0
    let cornerRadius = 15.0
    let shadowColor = CGColor.interfaceManager.themeProfileRootCenterLogoutCellShadow()
    let backgroundColor = UIColor.interfaceManager.themeProfileRootCenterLogoutCellBackground()
}

// MARK: - ProfileRootCenterLogoutLabelLayout
struct ProfileRootCenterLogoutLabelLayout {
    let size = CGSize(width: 0, height: 50.fitWidth)
    let font = UIFont.systemFont(ofSize: 15.fitWidth)
    let textColor = UIColor.interfaceManager.themeProfileRootCenterLogoutCellTitle()
}

// MARK: - ProfileRootCenterLogoutSeparatorLayout
struct ProfileRootCenterLogoutSeparatorLayout {
    let constraints = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    let size = CGSize(width: 0, height: 2)
    let backgroundColor = UIColor.interfaceManager.themeBackgroundOne()
}

// MARK: - ProfileRootCenterLogoutDeleteLabelLayout
struct ProfileRootCenterLogoutDeleteLabelLayout {
    let constraints = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    let size = CGSize(width: 0, height: 50.fitWidth)
    let font = UIFont.systemFont(ofSize: 15.fitWidth)
    let textColor = UIColor.interfaceManager.red()
}
