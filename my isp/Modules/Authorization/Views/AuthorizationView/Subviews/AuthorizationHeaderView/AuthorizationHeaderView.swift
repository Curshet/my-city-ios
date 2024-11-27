import UIKit
import Combine
import SnapKit

class AuthorizationHeaderView: UIView, AuthorizationHeaderViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationHeaderData, Never>
    
    private let imageView: UIImageView
    private let textLabel: UILabel
    private var subscriptions: Set<AnyCancellable>
    
    init(imageView: UIImageView, textLabel: UILabel) {
        self.imageView = imageView
        self.textLabel = textLabel
        self.internalEventPublisher = PassthroughSubject<AuthorizationHeaderData, Never>()
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: .zero)
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension AuthorizationHeaderView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.setupConstraints($0)
            self?.setupSubviews($0)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        imageView.contentMode = .scaleAspectFit
        textLabel.textAlignment = .left
        addSubviews(imageView, textLabel)
    }
    
    func setupConstraints(_ data: AuthorizationHeaderData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.top.equalToSuperview().offset(data.layout.constraints.top)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().inset(data.layout.size.width)
            $0.bottom.equalTo(imageView.snp.bottom)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalTo(snp.centerX).offset(data.layout.imageView.constraints.right)
        }
        
        textLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(data.layout.textLabel.constraints.top)
            $0.leading.equalTo(imageView.snp.trailing).offset(data.layout.textLabel.constraints.left)
            $0.bottom.equalToSuperview().inset(data.layout.textLabel.constraints.bottom)
        }
    }
    
    func setupSubviews(_ data: AuthorizationHeaderData) {
        imageView.image = data.image
        textLabel.text = data.text
        textLabel.numberOfLines = data.layout.textLabel.numberOfLines
        textLabel.font = data.layout.textLabel.font
        textLabel.textColor = data.layout.textLabel.textColor
        textLabel.transform = data.layout.textLabel.transform
    }
    
}

// MARK: - AuthorizationHeaderViewLayout
struct AuthorizationHeaderViewLayout {
    let imageView = AuthorizationHeaderImageViewLayout()
    let textLabel = AuthorizationHeaderTextLabelLayout()
    let constraints = UIEdgeInsets(top: 60.fitHeight, left: 0, bottom: 0, right: 0)
    let size = CGSize(width: 25.fitHeight, height: 0)
}

// MARK: - AuthorizationHeaderImageViewLayout
struct AuthorizationHeaderImageViewLayout {
    let constraints = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -25.fitHeight)
}

// MARK: - AuthorizationHeaderTextLabelLayout
struct AuthorizationHeaderTextLabelLayout {
    let constraints = UIEdgeInsets(top: 5, left: 30.fitHeight, bottom: 5, right: 0)
    let numberOfLines = 0
    let font = UIFont.systemFont(ofSize: 14.fitWidth, weight: .medium)
    let textColor = UIColor.interfaceManager.themeAuthorizationRootHeader()
    let transform = CGAffineTransform(scaleX: 1.2, y: 1)
}
