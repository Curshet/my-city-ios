import UIKit
import Combine

class AppButton: UIButton {
    
    var tapPublisher: AnyPublisher<Void?, Never> {
        tapDataPublisher.eraseToAnyPublisher()
    }
    
    private let tapDataPublisher: PassthroughSubject<Void?, Never>
    
    init(event: UIControl.Event = .touchUpInside) {
        self.tapDataPublisher = PassthroughSubject<Void?, Never>()
        super.init(frame: .zero)
        addNotification(event: event)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapAction() {
        tapDataPublisher.send(nil)
    }
    
    func addNotification(_ target: Any? = nil, event: UIControl.Event) {
        addTarget(target ?? self, action: #selector(tapAction), for: event)
    }
    
    func removeNotification(_ target: Any? = nil, event: UIControl.Event) {
        removeTarget(target ?? self, action: #selector(tapAction), for: event)
    }
    
}
