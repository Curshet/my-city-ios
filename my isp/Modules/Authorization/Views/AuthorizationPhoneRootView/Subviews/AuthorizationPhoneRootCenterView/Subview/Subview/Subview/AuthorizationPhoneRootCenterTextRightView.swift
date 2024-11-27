import UIKit
import Combine
import SnapKit

class AuthorizationPhoneRootCenterTextRightView: UIView, AuthorizationPhoneRootCenterTextRightViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootCenterTextRightViewData, Never>
    let externalEventPublisher: AnyPublisher<Void, Never>
    
    private let button: AppButtonProtocol
    private let externalPublisher: PassthroughSubject<Void, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(button: AppButtonProtocol) {
        self.button = button
        self.internalEventPublisher = PassthroughSubject<AuthorizationPhoneRootCenterTextRightViewData, Never>()
        self.externalPublisher = PassthroughSubject<Void, Never>()
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
private extension AuthorizationPhoneRootCenterTextRightView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        button.publisher.sink { [weak self] _ in
            self?.externalPublisher.send()
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        button.configureTransform(.disable)
        addSubview(button)
    }
    
    func internalEventHandler(_ event: AuthorizationPhoneRootCenterTextRightViewData) {
        button.setImage(event.image?.setColor(event.layout.button.imageColor), for: .normal)
        button.setTouchOffsets(event.layout.button.touchOffsets)
        setupConstraints(event)
    }
    
    func setupConstraints(_ data: AuthorizationPhoneRootCenterTextRightViewData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.height.equalTo(data.layout.size.height)
            $0.width.equalTo(data.layout.size.width)
        }
        
        button.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(data.layout.button.constraints.right)
            $0.height.equalToSuperview().inset(data.layout.button.size.height)
            $0.width.equalToSuperview().inset(data.layout.button.size.width)
        }
    }
    
}

// MARK: - AuthorizationPhoneRootCenterTextRightViewLayout
struct AuthorizationPhoneRootCenterTextRightViewLayout {
    let button = AuthorizationPhoneRootCenterTextRightButtonLayout()
    let size = CGSize(width: 23.fitWidth, height: 23.fitWidth)
}

// MARK: - AuthorizationPhoneRootCenterTextRightButtonLayout
struct AuthorizationPhoneRootCenterTextRightButtonLayout {
    let constraints = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    let size = CGSize(width: 5, height: 5)
    let imageColor = UIColor.interfaceManager.grayTwo()
    let touchOffsets = CGPoint(x: 18.fitWidth, y: 18.fitWidth)
}
