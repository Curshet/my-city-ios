import Foundation
import Combine

final class DisplayViewModel: DisplayViewModelProtocol {
    
    let internalEventPublisher: PassthroughSubject<DisplayViewModelInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<DisplayViewModelExternalEvent, Never>

    private let dataSource: DisplayDataSourceViewProtocol
    private let externalPublisher: PassthroughSubject<DisplayViewModelExternalEvent, Never>
    private var customized: Bool
    private var subscriptions: Set<AnyCancellable>
    
    init(dataSource: DisplayDataSourceViewProtocol) {
        self.dataSource = dataSource
        self.internalEventPublisher = PassthroughSubject<DisplayViewModelInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<DisplayViewModelExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.customized = false
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension DisplayViewModel {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: DisplayViewModelInternalEvent) {
        switch event {
            case .overlay:
                let layout = dataSource.layout(customized: nil)
                let event: DisplayViewModelExternalEvent = customized ? .custom(layout) : .overlay(layout)
                customized = false
                externalPublisher.send(event)
            
            case .custom(let value):
                let layout = dataSource.layout(customized: value)
                customized = true
                externalPublisher.send(.overlay(layout))
        }
    }
    
}

// MARK: - DisplayViewModelInternalEvent
enum DisplayViewModelInternalEvent {
    case overlay
    case custom(DisplayViewLayout)
}

// MARK: - DisplayViewModelExternalEvent
enum DisplayViewModelExternalEvent {
    case overlay(AppOverlayViewLayout)
    case custom(AppOverlayViewLayout)
}
