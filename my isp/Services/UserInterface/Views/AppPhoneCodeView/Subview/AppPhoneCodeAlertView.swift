import UIKit
import Combine
import SnapKit

class AppPhoneCodeAlertView: UIView, AppPhoneCodeAlertViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<AppPhoneCodeViewInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<AppPhoneCodeViewExternalEvent, Never>
    
    private let headerView: AppPhoneCodeHeaderViewProtocol
    private let centerView: AppPhoneCodeCenterViewProtocol
    private let externalPublisher: PassthroughSubject<AppPhoneCodeViewExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(headerView: AppPhoneCodeHeaderViewProtocol, centerView: AppPhoneCodeCenterViewProtocol) {
        self.headerView = headerView
        self.centerView = centerView
        self.internalEventPublisher = PassthroughSubject<AppPhoneCodeViewInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<AppPhoneCodeViewExternalEvent, Never>()
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
private extension AppPhoneCodeAlertView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
        setupGestureRecognizer()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        headerView.externalEventPublisher.sink { [weak self] in
            self?.externalPublisher.send(.exit)
        }.store(in: &subscriptions)
        
        centerView.externalEventPublisher.sink { [weak self] in
            self?.externalPublisher.send($0)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        clipsToBounds = true
        addSubviews(headerView, centerView)
    }
    
    func setupGestureRecognizer() {
        let gesture = AppTapGestureRecognizer()
        
        gesture.publisher.sink { [weak self] _ in
            self?.centerView.becomeFirstResponder()
        }.store(in: &subscriptions)
        
        addGesture(gesture)
    }
    
    func internalEventHandler(_ event: AppPhoneCodeViewInternalEvent) {
        switch event {
            case .data(var value):
                dataHandler(&value)
            
            default:
                centerView.internalEventPublisher.send(event)
        }
    }

    func dataHandler(_ data: inout AppPhoneCodeViewData) {
        setupLayout(data)
        setupConstraints(data)
        headerView.internalEventPublisher.send(data.alert.header)
        data.alert.center.layout.topConstraint = headerView.snp.bottom
        centerView.internalEventPublisher.send(.data(data))
    }
    
    func setupLayout(_ data: AppPhoneCodeViewData) {
        backgroundColor = data.alert.layout.backgroundColor
        layer.cornerRadius = data.alert.layout.cornerRadius
    }
    
    func setupConstraints(_ data: AppPhoneCodeViewData) {
        guard constraints.isEmpty else { return }
        
        snp.makeConstraints {
            $0.top.equalToSuperview().offset(data.alert.layout.constraints.top)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().inset(data.alert.layout.size.width)
            $0.bottom.equalTo(centerView.snp.bottom)
        }
    }
    
}

// MARK: - AppPhoneCodeAlertViewLayout
struct AppPhoneCodeAlertViewLayout {
    var constraints = UIEdgeInsets(top: 50.fitWidth, left: 0, bottom: 0, right: 0)
    var size = CGSize(width: 25.fitToSize(.height, with: 1.3), height: 0)
    var backgroundColor = UIColor.interfaceManager.themePhoneCodeAlertBackground()
    var cornerRadius = 13.0.fitWidth
}
