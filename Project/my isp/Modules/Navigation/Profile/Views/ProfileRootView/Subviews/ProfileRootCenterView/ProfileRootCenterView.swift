import UIKit
import Combine
import SnapKit

class ProfileRootCenterView: AppCollectionView, ProfileRootCenterViewProtocol {

    let internalEventPublisher: PassthroughSubject<ProfileRootCenterViewInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<ProfileRootCenterViewExternalEvent, Never>
    
    private let customDataSource: ProfileRootCenterViewDataSourceProtocol
    private let layout: UICollectionViewFlowLayout
    private var subscriptions: Set<AnyCancellable>
    
    init(dataSource: ProfileRootCenterViewDataSourceProtocol, layout: UICollectionViewFlowLayout) {
        self.customDataSource = dataSource
        self.layout = layout
        self.internalEventPublisher = PassthroughSubject<ProfileRootCenterViewInternalEvent, Never>()
        self.externalEventPublisher = customDataSource.externalEventPublisher
        self.subscriptions = Set<AnyCancellable>()
        super.init(delegate: nil, layout: self.layout)
        self.dataSource = customDataSource
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: Private
private extension ProfileRootCenterView {

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
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        registerCell(type: ProfileRootCenterUserInfoCell.self)
        registerCell(type: ProfileRootCenterLogoutCell.self)
    }
    
    func internalEventHandler(_ event: ProfileRootCenterViewInternalEvent) {
        switch event {
            case .data(let data):
                customDataSource.internalEventPublisher.send(data.items)
                setupLayout(data)
                setupConstraints(data.layout)
            
            case .userInfo(let data):
                updateHandler(data)
        }
    }

    func setupLayout(_ data: ProfileRootCenterData) {
        contentInset = data.layout.contentInset
        backgroundColor = data.layout.backgroundColor
        layout.minimumLineSpacing = data.layout.minimumLineSpacing
        reloadData()
    }
    
    func setupConstraints(_ data: ProfileRootCenterViewLayout) {
        snp.makeConstraints {
            $0.top.equalTo(data.topConstraint)
            $0.width.bottom.equalToSuperview()
        }
    }
    
    func updateHandler(_ data: ProfileRootCenterData) {
        guard let indexPath = data.indexPath else {
            logger.console(event: .error(info: "\(typeName) doesn't have an index path for updating"))
            return
        }
        
        customDataSource.internalEventPublisher.send(data.items)
        reloadItems(at: [indexPath])
    }
    
}

// MARK: - ProfileRootCenterViewLayout
struct ProfileRootCenterViewLayout {
    let minimumLineSpacing = 20.fitWidth
    let contentInset = UIEdgeInsets(top: 20.fitWidth, left: 0, bottom: 20.fitWidth, right: 0)
    let backgroundColor = UIColor.interfaceManager.themeBackgroundOne()
    var topConstraint: ConstraintItem!
}

// MARK: - ProfileRootCenterViewInternalEvent
enum ProfileRootCenterViewInternalEvent {
    case data(ProfileRootCenterData)
    case userInfo(ProfileRootCenterData)
}

// MARK: - ProfileRootCenterViewExternalEvent
enum ProfileRootCenterViewExternalEvent {
    case copyPhone(String?)
    case editName
    case logout
    case delete
}
