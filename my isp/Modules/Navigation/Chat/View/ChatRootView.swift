import UIKit
import Combine

class ChatRootView: UIView, ChatRootViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<ChatRootViewModelExternalEvent, Never>
    let externalEventPublisher: AnyPublisher<ChatRootViewModelRequestType, Never>
    
    private let webview: ChatRootWebViewProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(webview: ChatRootWebViewProtocol) {
        self.webview = webview
        self.internalEventPublisher = PassthroughSubject<ChatRootViewModelExternalEvent, Never>()
        self.externalEventPublisher = webview.externalEventPublisher
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: .zero)
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension ChatRootView {
    
    func startConfiguration() {
        setupObservers()
        addSubview(webview)
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: ChatRootViewModelExternalEvent) {
        webview.internalEventPublisher.send(event)
        
        switch event {
            case .view(let value):
                backgroundColor = value.layout.backgroundColor
                
            case .layout(let value):
                backgroundColor = value.backgroundColor
        }
    }
    
}

// MARK: - ChatRootViewLayout
struct ChatRootViewLayout {
    let webview: ChatRootWebViewLayout
    let backgroundColor = UIColor.interfaceManager.themeBackgroundOne()
}
