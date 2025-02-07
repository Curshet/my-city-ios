import UIKit
import Combine

class AppTapGestureRecognizer: UITapGestureRecognizer {
    
    var tapPublisher: AnyPublisher<Void?, Never> {
        tapDataPublisher.eraseToAnyPublisher()
    }
    
    private let tapDataPublisher: PassthroughSubject<Void?, Never>

    init(target: Any?) {
        self.tapDataPublisher = PassthroughSubject<Void?, Never>()
        super.init(target: target, action: #selector(tapAction))
    }
    
    @objc private func tapAction() {
        tapDataPublisher.send(nil)
    }
    
}
