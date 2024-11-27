import UIKit
import Combine

class AppPageControl: UIPageControl {
    
    var pagePublisher: AnyPublisher<Int, Never> {
        pageDataPublisher.eraseToAnyPublisher()
    }
    
    private let pageDataPublisher: PassthroughSubject<Int, Never>
    
    init(event: UIControl.Event = .valueChanged) {
        self.pageDataPublisher = PassthroughSubject<Int, Never>()
        super.init(frame: .zero)
        addNotification(event: event)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didAction() {
        pageDataPublisher.send(currentPage)
    }
    
    func addNotification(_ target: Any? = nil, event: UIControl.Event) {
        addTarget(target ?? self, action: #selector(didAction), for: event)
    }
    
    func removeNotification(_ target: Any? = nil, event: UIControl.Event) {
        removeTarget(target ?? self, action: #selector(didAction), for: event)
    }
    
}
