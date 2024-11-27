import UIKit
import Combine

class ProfileRootDataManager: ProfileRootDataManagerProtocol {
    
    let internalEventPublisher: PassthroughSubject<ProfileRootDataProcessorInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<ProfileRootDataProcessorExternalEvent, Never>
    
    private weak var userManager: AppUserManagerControlProtocol?
    private let dataSource: ProfileRootDataSourceProtocol
    private let pasteboard: PasteboardProtocol
    private let externalPublisher: PassthroughSubject<ProfileRootDataProcessorExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(userManager: AppUserManagerControlProtocol, dataSource: ProfileRootDataSourceProtocol,  pasteboard: PasteboardProtocol) {
        self.userManager = userManager
        self.dataSource = dataSource
        self.pasteboard = pasteboard
        self.internalEventPublisher = PassthroughSubject<ProfileRootDataProcessorInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<ProfileRootDataProcessorExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension ProfileRootDataManager {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        userManager?.externalEventPublisher.sink { [weak self] in
            self?.userManagerEventHandler($0)
        }.store(in: &subscriptions)

        dataSource.externalEventPublisher.sink { [weak self] in
            self?.dataSourceEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: ProfileRootDataProcessorInternalEvent) {
        switch event {
            case .view:
                dataSource.internalEventPublisher.send(.view(userManager?.information(of: .userPhone, .userName, .userImage)))
            
            case .appearance(let target):
                appearanceRequest(target)
            
            case .copyPhone(let value):
                pasteboard.string = value
                dataSource.internalEventPublisher.send(.notify(.copy))

            case .logout:
                dataSource.internalEventPublisher.send(.alert(.logout))
            
            case .delete:
                dataSource.internalEventPublisher.send(.alert(.delete))
            
            case .notify(let type):
                dataSource.internalEventPublisher.send(.notify(type))
        }
    }
    
    func appearanceRequest(_ target: AppearanceManagerExternalEvent) {
        switch target {
            case .update(let value):
                dataSource.internalEventPublisher.send(.view(userManager?.information(of: .userPhone, .userName, .userImage)))
                fallthrough
            
            case .setup(let value):
                dataSource.internalEventPublisher.send(.navigationBar(value.navigationBar))
        }
    }
    
    func userManagerEventHandler(_ event: AppUserManagerExternalEvent) {
        guard case .success(let type) = event else { return }

        switch type {
            case .userImage:
                dataSource.internalEventPublisher.send(.userImage(userManager?.information(of: .userImage)))
            
            case .userName:
                dataSource.internalEventPublisher.send(.userInfo(userManager?.information(of: .userName)))

            default:
                break
        }
    }
    
    func dataSourceEventHandler(_ event: ProfileRootDataSourceExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(.view(value))
            
            case .appearance(let value):
                externalPublisher.send(.appearance(value))
            
            case .userImage(let value):
                externalPublisher.send(.userImage(value))
            
            case .userInfo(let value):
                externalPublisher.send(.userInfo(value))
            
            case .alert(let value):
                userManager?.internalEventPublisher.send(.logout)
                externalPublisher.send(.alert(value))
            
            case .notify(let type):
                externalPublisher.send(.notify(type))
        }
    }

}

// MARK: - ProfileRootDataProcessorInternalEvent
enum ProfileRootDataProcessorInternalEvent {
    case view
    case appearance(AppearanceManagerExternalEvent)
    case copyPhone(String?)
    case logout
    case delete
    case notify(ProfileRootDataSourceNotify)
}

// MARK: - ProfileRootDataProcessorExternalEvent
enum ProfileRootDataProcessorExternalEvent {
    case view(ProfileRootViewData)
    case appearance(AppearanceTarget)
    case userImage(UIImage?)
    case userInfo(ProfileRootCenterData)
    case alert(Any?)
    case notify(AppUserNotificationType)
}
