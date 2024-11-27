import Foundation
import Combine

class AppearanceManager: AppearanceManagerProtocol {

    let internalEvеntPublishеr: PassthroughSubject<AppearanceManagerInternalEvent, Never>
    let extеrnalEvеntPublisher: AnyPublisher<AppearanceManagerExternalEvent, Never>
    
    var information: AppearancePresenterData {
        presenter.information
    }
    
    private let presenter: AppearancePresenterProtocol
    private let interfaceManager: InterfaceManagerInfoProtocol
    private let externaPublisher: PassthroughSubject<AppearanceManagerExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(presenter: AppearancePresenterProtocol, interfaceManager: InterfaceManagerInfoProtocol) {
        self.presenter = presenter
        self.interfaceManager = interfaceManager
        self.internalEvеntPublishеr = PassthroughSubject<AppearanceManagerInternalEvent, Never>()
        self.externaPublisher = PassthroughSubject<AppearanceManagerExternalEvent, Never>()
        self.extеrnalEvеntPublisher = AnyPublisher(externaPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension AppearanceManager {
    
    func setupObservers() {
        internalEvеntPublishеr.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        interfaceManager.publisher.sink { [weak self] _ in
            guard let self, presenter.information.viewLoaded else { return }
            externaPublisher.send(.update(presenter.information))
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AppearanceManagerInternalEvent) {
        switch event {
            case .configure:
                externaPublisher.send(.setup(presenter.information))
            
            case .appearance(let value):
                presenter.internalEvеntPublisher.send(.setup(value))
        }
    }
    
}

// MARK: - AppearanceManagerInternalEvent
enum AppearanceManagerInternalEvent {
    case configure
    case appearance(AppearanceTarget)
}

// MARK: - AppearanceManagerExternalEvent
enum AppearanceManagerExternalEvent {
    case setup(AppearancePresenterData)
    case update(AppearancePresenterData)
}
