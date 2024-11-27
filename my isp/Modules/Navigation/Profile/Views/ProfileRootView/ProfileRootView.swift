import UIKit
import Combine

class ProfileRootView: UIView, ProfileRootViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<ProfileRootViewModelExternalEvent, Never>
    let externalEventPublisher: AnyPublisher<ProfileRootViewModelSelectEvent, Never>
    
    private let headerView: ProfileRootHeaderViewProtocol
    private let centerView: ProfileRootCenterViewProtocol
    private let externalPublisher: PassthroughSubject<ProfileRootViewModelSelectEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(headerView: ProfileRootHeaderViewProtocol, centerView: ProfileRootCenterViewProtocol) {
        self.headerView = headerView
        self.centerView = centerView
        self.internalEventPublisher = PassthroughSubject<ProfileRootViewModelExternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<ProfileRootViewModelSelectEvent, Never>()
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
private extension ProfileRootView {
    
    func startConfiguration() {
        setupObservers()
        addSubviews(headerView, centerView)
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        headerView.externalEventPublisher.sink { [weak self] in
            self?.externalPublisher.send(.userImage($0))
        }.store(in: &subscriptions)
        
        centerView.externalEventPublisher.sink { [weak self] in
            self?.externalPublisher.send(.userInfo($0))
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: ProfileRootViewModelExternalEvent) {
        switch event {
            case .view(var data):
                headerView.internalEventPublisher.send(.data(data.header))
                data.center.layout.topConstraint = headerView.snp.bottom
                centerView.internalEventPublisher.send(.data(data.center))
                
            case .userImage(let data):
                headerView.internalEventPublisher.send(.userImage(data))
            
            case .userInfo(let data):
                centerView.internalEventPublisher.send(.userInfo(data))
        }
    }
    
}
