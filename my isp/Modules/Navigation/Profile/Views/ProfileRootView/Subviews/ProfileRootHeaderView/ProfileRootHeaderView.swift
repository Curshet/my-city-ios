import UIKit
import Combine
import SnapKit

class ProfileRootHeaderView: UIImageView, ProfileRootHeaderViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<ProfileRootHeaderViewInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<ProfileRootHeaderViewExternalEvent, Never>
    
    private let imageView: UIImageView
    private let editButton: AppButtonProtocol
    private let externalPublisher: PassthroughSubject<ProfileRootHeaderViewExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(imageView: UIImageView, button: AppButtonProtocol) {
        self.imageView = imageView
        self.editButton = button
        self.internalEventPublisher = PassthroughSubject<ProfileRootHeaderViewInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<ProfileRootHeaderViewExternalEvent, Never>()
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
private extension ProfileRootHeaderView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
        setupGestureRecognizer()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        editButton.publisher.sink { [weak self] _ in
            self?.externalPublisher.send(.edit)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        contentMode = .scaleAspectFill
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        editButton.adjustsImageWhenHighlighted = false
        addSubviews(editButton, imageView)
    }
    
    func setupGestureRecognizer() {
        let tapGesture = AppTapGestureRecognizer()
        
        tapGesture.publisher.sink { [weak self] _ in
            self?.externalPublisher.send(.camera)
        }.store(in: &subscriptions)
        
        imageView.addGesture(tapGesture)
    }
    
    func internalEventHandler(_ event: ProfileRootHeaderViewInternalEvent) {
        switch event {
            case .data(let data):
                dataHandler(data)
            
            case .userImage(let image):
                imageView.image = image
        }
    }
    
    func dataHandler(_ data: ProfileRootHeaderData) {
        image = data.background
        setupConstraints(data)
        setupSubviews(data)
    }
    
    func setupConstraints(_ data: ProfileRootHeaderData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.top.width.equalToSuperview()
        }

        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide).offset(data.layout.imageView.constraints.top)
            $0.bottom.equalToSuperview().inset(data.layout.imageView.constraints.bottom)
            $0.width.equalTo(data.layout.imageView.size.width)
            $0.height.equalTo(data.layout.imageView.size.height)
        }
        
        editButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.top)
            $0.right.equalToSuperview().inset(data.layout.button.constraints.right)
            $0.width.equalTo(data.layout.button.size.width)
            $0.height.equalTo(data.layout.button.size.height)
        }
        
    }
    
    func setupSubviews(_ data: ProfileRootHeaderData) {
        backgroundColor = data.layout.backgroundColor
        imageView.image = data.image
        imageView.layer.cornerRadius = data.layout.imageView.cornerRadius
        imageView.layer.borderColor = data.layout.imageView.borderColor
        imageView.layer.borderWidth = data.layout.imageView.borderWidth
        
        editButton.setImage(data.icon, for: .normal)
        editButton.backgroundColor = data.layout.button.backgroundColor
        editButton.layer.cornerRadius = data.layout.button.cornerRadius
        editButton.configureTransform(.setup(.touchesBegan(data.layout.button.touchesBegan)))
        editButton.configureTransform(.setup(.touchInside(data.layout.button.touchInside)))
    }
    
}

// MARK: - ProfileRootHeaderViewLayout
struct ProfileRootHeaderViewLayout {
    let imageView = ProfileRootHeaderUserImageViewLayout()
    let button = ProfileRootHeaderButtonLayout()
    let backgroundColor = UIColor.interfaceManager.themeBackgroundOne()
}

// MARK: - ProfileRootHeaderUserImageViewLayout
struct ProfileRootHeaderUserImageViewLayout {
    let constraints = UIEdgeInsets(top: -17.fitWidth, left: 0, bottom: 40, right: 0)
    let size = CGSize(width: 90.fitWidth, height: 90.fitWidth)
    let cornerRadius = 45.fitWidth
    let borderColor = UIColor.white.cgColor
    let borderWidth = 2.0
}

// MARK: - ProfileRootHeaderButtonLayout
struct ProfileRootHeaderButtonLayout {
    let constraints = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 25)
    let size = CGSize(width: 26.fitWidth, height: 26.fitWidth)
    let backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
    let cornerRadius = 13.fitWidth
    let touchesBegan = AppViewAnimation(duration: 0.2, color: nil, transform: .init(scaleX: 1.1, y: 1.1))
    let touchInside = AppViewTransformation(durationStart: 0.2, durationFinish: 0.2, colorStart: nil, colorFinish: nil, transformStart: .identity, transformFinish: .identity)
}

// MARK: - ProfileRootHeaderViewInternalEvent
enum ProfileRootHeaderViewInternalEvent {
    case data(ProfileRootHeaderData)
    case userImage(UIImage?)
}

// MARK: - ProfileRootHeaderViewExternalEvent
enum ProfileRootHeaderViewExternalEvent {
    case edit
    case camera
}
