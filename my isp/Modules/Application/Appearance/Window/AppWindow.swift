import UIKit

final class AppWindow: UIWindow {
    
    private let interfaceManager: InterfaceManagerControlProtocol
    
    init(interfaceManager: InterfaceManagerControlProtocol, screen: ScreenProtocol) {
        self.interfaceManager = interfaceManager
        super.init(frame: screen.bounds)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        interfaceManager.update()
    }
    
}
