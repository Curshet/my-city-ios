import UIKit
import Combine
import SnapKit

class ProfileRootCenterUserInfoCellView: UIView {

    let internalEventPublisher: PassthroughSubject<Any, Never>
    let externalEventPublisher: AnyPublisher<ProfileRootCenterViewExternalEvent, Never>
    
    private let phoneView: ProfileRootCenterUserInfoSectionViewProtocol
    private let nameView: ProfileRootCenterUserInfoSectionViewProtocol
    private let separator: UIView
    private let externalPublisher: PassthroughSubject<ProfileRootCenterViewExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(phoneView: ProfileRootCenterUserInfoSectionViewProtocol, nameView: ProfileRootCenterUserInfoSectionViewProtocol, separator: UIView) {
        self.phoneView = phoneView
        self.nameView = nameView
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
private extension ProfileRootCenterUserInfoCellView {
    
    func startConfiguration() {
        setupObservers()
        addSubviews(phoneView, separator, nameView)
    }

    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        phoneView.externalEventPublisher.sink { [weak self] in
            self?.externalPublisher.send(.copyPhone($0))
        }.store(in: &subscriptions)
        
        nameView.externalEventPublisher.sink { [weak self] _ in
            self?.externalPublisher.send(.editName)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ data: Any) {
        guard var data = data as? ProfileRootCenterUserInfoCellData else {
            logger.console(event: .error(info: "\(typeName) doesn't have a data for presenting"))
            return
        }
        
        setupLayout(data)
        setupConstraints(data)
        setupSubviews(&data)
    }

    func setupLayout(_ data: ProfileRootCenterUserInfoCellData) {
        layer.borderWidth = data.layout.borderWidth
        layer.borderColor = data.layout.borderColor
        layer.cornerRadius = data.layout.cornerRadius
        layer.shadowOpacity = data.layout.shadowOpacity
        layer.shadowOffset = data.layout.shadowOffset
        layer.shadowRadius = data.layout.shadowRadius
        layer.shadowColor = data.layout.shadowColor
        separator.backgroundColor = data.layout.separator.backgroundColor
    }
    
    func setupConstraints(_ data: ProfileRootCenterUserInfoCellData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(data.layout.size.width)
            $0.bottom.equalTo(nameView.snp.bottom)
        }
        
        separator.snp.makeConstraints {
            $0.top.equalTo(phoneView.snp.bottom)
            $0.width.equalToSuperview()
            $0.height.equalTo(data.layout.separator.size.height)
        }
    }
    
    func setupSubviews(_ data: inout ProfileRootCenterUserInfoCellData) {
        data.phone.layout.topConstraint = snp.top
        data.name.layout.topConstraint = separator.snp.bottom
        phoneView.internalEventPublisher.send(data.phone)
        nameView.internalEventPublisher.send(data.name)
    }
    
}

// MARK: - ProfileRootCenterUserInfoCellLayout
struct ProfileRootCenterUserInfoCellLayout {
    let separator = ProfileRootCenterUserInfoSeparatorLayout()
    let size: CGSize
    let borderWidth = CGFloat.interfaceManager.themeProfileRootItemBorderWidth()
    let borderColor = UIColor.interfaceManager.darkBackgroundTwo().cgColor
    let cornerRadius = 15.0
    let shadowOpacity = Float(0.18)
    let shadowOffset = CGSize.zero
    let shadowRadius = 6.0
    let shadowColor = CGColor.interfaceManager.themeMoreRootSystemInfoCellShadow()
}

// MARK: - ProfileRootCenterUserInfoSeparatorLayout
struct ProfileRootCenterUserInfoSeparatorLayout {
    let size = CGSize(width: 0, height: 2)
    let backgroundColor = UIColor.interfaceManager.themeBackgroundOne()
}
