import UIKit
import Combine
import SnapKit

class AuthorizationPhoneRootHeaderView: UIView, AuthorizationPhoneRootHeaderViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootHeaderData, Never>
    
    private let titleLabel: UILabel
    private let subtitleLabel: UILabel
    private var subscriptions: Set<AnyCancellable>
    
    init(titleLabel: UILabel, subtitleLabel: UILabel) {
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        self.internalEventPublisher = PassthroughSubject<AuthorizationPhoneRootHeaderData, Never>()
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: .zero)
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension AuthorizationPhoneRootHeaderView {
    
    func startConfiguration() {
        setupObservers()
        setupСonfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.setupConstraints($0)
            self?.setupSubviews($0)
        }.store(in: &subscriptions)
    }
    
    func setupСonfiguration() {
        titleLabel.textAlignment = .center
        subtitleLabel.textAlignment = .center
        addSubviews(titleLabel, subtitleLabel)
    }
    
    func setupConstraints(_ data: AuthorizationPhoneRootHeaderData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.top.equalToSuperview().offset(data.layout.constraints.top)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().inset(data.layout.size.width)
            $0.bottom.equalTo(subtitleLabel.snp.bottom)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(data.layout.subtitleLabel.constraints.top)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    func setupSubviews(_ data: AuthorizationPhoneRootHeaderData) {
        titleLabel.text = data.title
        titleLabel.font = data.layout.titleLabel.font
        titleLabel.textColor = data.layout.titleLabel.textColor
        
        subtitleLabel.text = data.subtitle
        subtitleLabel.font = data.layout.subtitleLabel.font
        subtitleLabel.textColor = data.layout.subtitleLabel.textColor
        subtitleLabel.numberOfLines = data.layout.subtitleLabel.numberOfLines
    }
    
}

// MARK: - AuthorizationPhoneRootHeaderViewLayout
struct AuthorizationPhoneRootHeaderViewLayout {
    let titleLabel = AuthorizationPhoneRootHeaderTitleLabelLayout()
    let subtitleLabel = AuthorizationPhoneRootHeaderSubitleLabelLayout()
    let constraints = UIEdgeInsets(top: 30.fitHeight, left: 0, bottom: 0, right: 0)
    let size = CGSize(width: 20, height: 0)
}

// MARK: - AuthorizationPhoneRootHeaderTitleLabelLayout
struct AuthorizationPhoneRootHeaderTitleLabelLayout {
    let font = UIFont.boldSystemFont(ofSize: 20.fitWidth)
    let textColor = UIColor.interfaceManager.themeAuthorizationPhoneHeaderTitle()
}

// MARK: - AuthorizationPhoneRootHeaderSubitleLabelLayout
struct AuthorizationPhoneRootHeaderSubitleLabelLayout {
    let constraints = UIEdgeInsets(top: 42.fitWidth, left: 0, bottom: 0, right: 0)
    let font = UIFont.systemFont(ofSize: 13.fitWidth)
    let textColor = UIColor.interfaceManager.themeAuthorizationPhoneHeaderSubtitle()
    let numberOfLines = 0
}
