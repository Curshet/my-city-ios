import UIKit
import Combine

class ProfileRootViewModel: ProfileRootViewModelProtocol {
    
    let internalEventPublisher: PassthroughSubject<ProfileRootViewModelInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<ProfileRootViewModelExternalEvent, Never>
    
    private weak var router: ProfileRouterProtocol?
    private let dataManager: ProfileRootDataManagerProtocol
    private let networkManager: ProfileRootNetworkManagerProtocol
    private let appearanceManager: AppearanceManagerProtocol
    private let externalPublisher: PassthroughSubject<ProfileRootViewModelExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(router: ProfileRouterProtocol, dataManager: ProfileRootDataManagerProtocol, networkManager: ProfileRootNetworkManagerProtocol, appearanceManager: AppearanceManagerProtocol) {
        self.router = router
        self.dataManager = dataManager
        self.networkManager = networkManager
        self.appearanceManager = appearanceManager
        self.internalEventPublisher = PassthroughSubject<ProfileRootViewModelInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<ProfileRootViewModelExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension ProfileRootViewModel {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        router?.externalEventPublisher.sink { [weak self] in
            self?.routerEventHandler($0)
        }.store(in: &subscriptions)
        
        dataManager.externalEventPublisher.sink { [weak self] in
            self?.dataManagerEventHandler($0)
        }.store(in: &subscriptions)
        
        appearanceManager.extеrnalEvеntPublisher.sink { [weak self] in
            self?.dataManager.internalEventPublisher.send(.appearance($0))
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: ProfileRootViewModelInternalEvent) {
        switch event {
            case .dataRequest:
                dataManager.internalEventPublisher.send(.view)
            
            case .setupNavigationBar:
                appearanceManager.internalEvеntPublishеr.send(.configure)

            case .select(let event):
                selectEventHandler(event)
        }
    }
    
    func selectEventHandler(_ event: ProfileRootViewModelSelectEvent) {
        switch event {
            case .userImage(let event):
                userImageSelectHandler(event)
            
            case .userInfo(let event):
                userInfoSelectHandler(event)
        }
    }
    
    func userImageSelectHandler(_ event: ProfileRootHeaderViewExternalEvent) {
        switch event {
            case .edit:
                router?.internalEventPublisher.send(.transition(.editImage))
            
            case .camera:
                break
        }
    }
    
    func userInfoSelectHandler(_ event: ProfileRootCenterViewExternalEvent) {
        switch event {
            case .copyPhone(let value):
                dataManager.internalEventPublisher.send(.copyPhone(value))
            
            case .editName:
                router?.internalEventPublisher.send(.transition(.editName))
                
            case .logout:
                dataManager.internalEventPublisher.send(.logout)
                
            case .delete:
                dataManager.internalEventPublisher.send(.delete)
        }
    }
    
    func routerEventHandler(_ event: ProfileRouterExternalEvent) {
        guard case .trigger(let type) = event, case let .route(value) = type else { return }
        
        switch value {
            case .authorization:
                dataManager.internalEventPublisher.send(.notify(.authorization))
            
            default:
                break
        }
    }
    
    func dataManagerEventHandler(_ event: ProfileRootDataProcessorExternalEvent) {
        switch event {
            case .view(let value):
                externalPublisher.send(.view(value))
            
            case .appearance(let value):
                appearanceManager.internalEvеntPublishеr.send(.appearance(value))
            
            case .userImage(let value):
                externalPublisher.send(.userImage(value))
            
            case .userInfo(let value):
                externalPublisher.send(.userInfo(value))
            
            case .alert(_):
                router?.internalEventPublisher.send(.output(.exit))
            
            case .notify(let type):
                router?.internalEventPublisher.send(.transition(.notify(type)))
        }
    }

}

// MARK: - ProfileRootViewModelInternalEvent
enum ProfileRootViewModelInternalEvent {
    case dataRequest
    case setupNavigationBar
    case select(ProfileRootViewModelSelectEvent)
}

// MARK: - ProfileRootViewModelSelectEvent
enum ProfileRootViewModelSelectEvent {
    case userImage(ProfileRootHeaderViewExternalEvent)
    case userInfo(ProfileRootCenterViewExternalEvent)
}

// MARK: - ProfileRootViewModelExternalEvent
enum ProfileRootViewModelExternalEvent {
    case view(ProfileRootViewData)
    case userImage(UIImage?)
    case userInfo(ProfileRootCenterData)
}
