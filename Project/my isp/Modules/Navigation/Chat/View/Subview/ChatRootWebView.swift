import UIKit
import Combine
import WebKit
import SnapKit

class ChatRootWebView: WKWebView, ChatRootWebViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<ChatRootViewModelExternalEvent, Never>
    let externalEventPublisher: AnyPublisher<ChatRootViewModelRequestType, Never>
    
    override var inputAccessoryView: UIView? {
        nil
    }
    
    private let refreshControl: AppRefreshControlProtocol
    private let externalPublisher: PassthroughSubject<ChatRootViewModelRequestType, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(refreshControl: AppRefreshControlProtocol, configuration: WKWebViewConfiguration) {
        self.refreshControl = refreshControl
        self.internalEventPublisher = PassthroughSubject<ChatRootViewModelExternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<ChatRootViewModelRequestType, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: .zero, configuration: configuration)
        self.scrollView.refreshControl = refreshControl
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        hideKeyboard()
    }
    
}

// MARK: Private
private extension ChatRootWebView {
    
    func startConfiguration() {
        setupConfiguration()
        setupObservers()
    }
    
    func setupConfiguration() {
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        refreshControl.publisher.sink { [weak self] in
            guard $0 == .valueChanged else { return }
            self?.externalPublisher.send(.data)
        }.store(in: &subscriptions)
        
        keyboardPublisher.filter {
            $0 == .willHide
        }.sink { [weak self] _ in
            guard let self, isVisible else { return }
            layoutIfNeeded()
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: ChatRootViewModelExternalEvent) {
        switch event {
            case .view(let value):
                setupConfiguration(value)
                
            case .layout(let value):
                setupLayout(value.webview)
        }
    }
    
    func setupConfiguration(_ data: ChatRootViewData) {
        refreshControl.endRefreshing()
        
        guard let request = data.webview.request else {
            logger.console(event: .error(info: "URL request doesn't exist"))
            externalPublisher.send(.error)
            return
        }
        
        guard !data.webview.script.isEmpty() else {
            logger.console(event: .error(info: "View script doesn't exist"))
            externalPublisher.send(.error)
            return
        }
        
        load(request)
        evaluateJavaScript(data.webview.script)
        setupLayout(data.layout.webview)
        setupConstraints(data.layout.webview)
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func setupLayout(_ value: ChatRootWebViewLayout) {
        tintColor = value.tintColor
        scrollView.backgroundColor = value.backgroundColor
    }
    
    func setupConstraints(_ value: ChatRootWebViewLayout) {
        guard constraints.isEmpty, let safeArea = value.safeArea else { return }

        snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(value.constraints.left)
            $0.trailing.equalToSuperview().inset(value.constraints.right)
            $0.bottom.equalTo(safeArea.snp.bottom).inset(value.constraints.bottom)
        }
    }
    
}

// MARK: - ChatRootWebViewLayout
struct ChatRootWebViewLayout {
    let safeArea: UILayoutGuide?
    let constraints: UIEdgeInsets
    let tintColor = UIColor.interfaceManager.themeChatTint()
    let backgroundColor = UIColor.clear
}
