import UIKit
import Combine
import SnapKit

class SplashView: UIView, SplashViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<SplashViewModelExternalEvent, Never>
    let externalEventPublisher: AnyPublisher<Void, Never>
    
    private let imageView: UIImageView
    private let externalPublisher: PassthroughSubject<Void, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(imageView: UIImageView) {
        self.imageView = imageView
        self.internalEventPublisher = PassthroughSubject<SplashViewModelExternalEvent, Never>()
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
private extension SplashView {
    
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
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    
    func internalEventHandler(_ event: SplashViewModelExternalEvent) {
        switch event {
            case .view(let value):
                setupLayout(value)
                setupConstraints(value)
            
            case .animation(let value):
                animate(value)
        }
    }
    
    func setupLayout(_ data: SplashViewData) {
        imageView.image = data.image
        backgroundColor = data.layout.backgroundColor
    }
    
    func setupConstraints(_ data: SplashViewData) {
        guard imageView.constraints.isEmpty else { return }
        
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(data.layout.imageView.size.width)
            $0.height.equalTo(data.layout.imageView.size.height)
        }
    }
    
    func animate(_ value: SplashImageViewLayout) {
        animate(duration: value.duration) {
            self.imageView.transform = value.transform
        } completion: {
            self.externalPublisher.send()
        }
    }

}

// MARK: - SplashViewLayout
struct SplashViewLayout {
    let imageView = SplashImageViewLayout()
    let backgroundColor = UIColor.interfaceManager.themeBackgroundOne()
}

// MARK: - SplashImageViewLayout
struct SplashImageViewLayout {
    let size = CGSize(width: 100, height: 100)
    let duration = 2.5
    let transform = CGAffineTransform(scaleX: 1.11, y: 1.11)
}
