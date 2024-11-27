import UIKit
import Combine

final class InterfaceManager {
    
    static let entry = InterfaceManager()
    
    var switchPublisher: AnyPublisher<Void?, Never> {
        switchDataPublisher.eraseToAnyPublisher()
    }
    
    private(set) var userStyle: StyleInfo
    private var storedStyle: UIUserInterfaceStyle
    private let switchDataPublisher: PassthroughSubject<Void?, Never>
    
    private var currentStyle: UIUserInterfaceStyle {
        AppInfo.entry.interfaceStyle
    }
    
    private init() {
        self.userStyle = StyleInfo()
        self.storedStyle = AppInfo.entry.interfaceStyle
        self.switchDataPublisher = PassthroughSubject<Void?, Never>()
    }
    
    func update(file: String = #file, line: Int = #line) {
        guard currentStyle != storedStyle else { return }
        storedStyle = currentStyle
        LoggingManager.entry.console(event: .any(info: "User interface style was changed to \(storedStyle.description) value"), file: file, line: line)
        switchDataPublisher.send(nil)
    }
    
}

// MARK: StyleInfo
struct StyleInfo {
    let color = StyleColor()
    let image = StyleImage()
    let gradient = StyleGradient()
    let font = StyleFont()
}

// MARK: StyleColor
struct StyleColor {}

// MARK: StyleImage
struct StyleImage {}

// MARK: StyleGradient
struct StyleGradient {}

// MARK: StyleFont
struct StyleFont {}
