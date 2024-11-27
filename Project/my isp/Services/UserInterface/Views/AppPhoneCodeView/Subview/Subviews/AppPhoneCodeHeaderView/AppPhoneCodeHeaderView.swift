import UIKit
import Combine
import SnapKit

class AppPhoneCodeHeaderView: UIView, AppPhoneCodeHeaderViewProtocol {

    let internalEventPublisher: PassthroughSubject<AppPhoneCodeHeaderData, Never>
    let externalEventPublisher: AnyPublisher<Void, Never>
    
    private let titleLabel: UILabel
    private let subtitleLabel: UILabel
    private let exitButton: AppButtonProtocol
    private let externalPublisher: PassthroughSubject<Void, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(titleLabel: UILabel, subtitleLabel: UILabel, exitButton: AppButtonProtocol) {
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        self.exitButton = exitButton
        self.internalEventPublisher = PassthroughSubject<AppPhoneCodeHeaderData, Never>()
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
private extension AppPhoneCodeHeaderView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.setupConstraints($0)
            self?.setupSubviews($0)
        }.store(in: &subscriptions)
        
        exitButton.publisher.sink { [weak self] _ in
            self?.externalPublisher.send()
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        titleLabel.textAlignment = .center
        subtitleLabel.textAlignment = .center
        addSubviews(titleLabel, subtitleLabel, exitButton)
    }
    
    func setupConstraints(_ data: AppPhoneCodeHeaderData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(subtitleLabel.snp.bottom)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(data.layout.titleLabel.constraints.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(data.layout.subtitleLabel.constraints.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        exitButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(data.layout.exitButton.constraints.top)
            $0.trailing.equalToSuperview().inset(data.layout.exitButton.constraints.right)
            $0.width.equalTo(data.layout.exitButton.size.width)
            $0.height.equalTo(data.layout.exitButton.size.height)
        }
    }
    
    func setupSubviews(_ data: AppPhoneCodeHeaderData) {
        titleLabel.text = data.title
        titleLabel.font = data.layout.titleLabel.font
        titleLabel.textColor = data.layout.titleLabel.textColor
        
        subtitleLabel.text = data.subtitle
        subtitleLabel.font = data.layout.subtitleLabel.font
        subtitleLabel.textColor = data.layout.subtitleLabel.textColor
        
        exitButton.setImage(data.image?.setColor(data.layout.exitButton.imageColorNormal), for: .normal)
        exitButton.setImage(data.image?.setColor(data.layout.exitButton.imageColorHighlighted), for: .highlighted)
        exitButton.setTouchOffsets(data.layout.exitButton.touchOffsets)
        exitButton.configureTransform(.setup(.touchesBegan(data.layout.exitButton.touchesBegan)))
    }
    
}

// MARK: - AppPhoneCodeHeaderViewLayout
struct AppPhoneCodeHeaderViewLayout {
    let titleLabel: AppPhoneCodeHeaderTitleLabelLayout
    let subtitleLabel: AppPhoneCodeHeaderSubtitleLabelLayout
    var exitButton = AppPhoneCodeHeaderExitButtonLayout()
}

// MARK: - AppPhoneCodeHeaderTitleLabelLayout
struct AppPhoneCodeHeaderTitleLabelLayout {
    var constraints = UIEdgeInsets(top: 22.fitWidth, left: 0, bottom: 0, right: 0)
    var font = UIFont.boldSystemFont(ofSize: 18.fitWidth)
    var textColor = UIColor.interfaceManager.themeText()
}

// MARK: - AppPhoneCodeHeaderSubtitleLabelLayout
struct AppPhoneCodeHeaderSubtitleLabelLayout {
    var constraints = UIEdgeInsets(top: 15.fitWidth, left: 0, bottom: 0, right: 0)
    var font = UIFont.systemFont(ofSize: 13.fitWidth)
    var textColor = UIColor.interfaceManager.grayOne()
}

// MARK: - AppPhoneCodeHeaderExitButtonLayout
struct AppPhoneCodeHeaderExitButtonLayout {
    var constraints = UIEdgeInsets(top: 14.fitWidth, left: 0, bottom: 0, right: 14.fitWidth)
    var size = CGSize(width: 12.5.fitWidth, height: 13.fitWidth)
    var imageColorNormal = UIColor.interfaceManager.lightPink()
    var imageColorHighlighted = UIColor.interfaceManager.red()
    var imageConfiguration = UIImage.SymbolConfiguration(weight: .medium)
    var touchOffsets = CGPoint(x: 10.fitWidth, y: 10.fitWidth)
    var touchesBegan = AppViewAnimation(duration: 0.2, color: nil, transform: .init(scaleX: 1.12, y: 1.12))
}
