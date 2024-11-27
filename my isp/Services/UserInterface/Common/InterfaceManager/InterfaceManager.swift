import UIKit
import Combine

final class InterfaceManager: NSObject, InterfaceManagerControlProtocol {
    
    static let entry = InterfaceManager()
    
    /// User interface style switching publisher
    let publisher: AnyPublisher<UIUserInterfaceStyle, Never>
    
    /// User interface style information
    let information: InterfaceManagerDataProtocol
    
    /// User interface style model
    let model: InterfaceManagerModel
    
    fileprivate private(set) var userStyle: UIUserInterfaceStyle {
        get {
            .unspecified
        }
        
        set {
            storage.saveInfo(key: "InterfaceManagerUserStyle", value: newValue)
        }
    }
    
    private let screen: ScreenProtocol
    private let storage: DataStorageControlProtocol
    private var appStyle: UIUserInterfaceStyle
    private let externalPublisher: PassthroughSubject<UIUserInterfaceStyle, Never>
    
    private override init() {
        self.screen = UIScreen.main
        self.storage = DataStorage.entry
        self.appStyle = screen.systemStyle
        self.externalPublisher = PassthroughSubject<UIUserInterfaceStyle, Never>()
        self.publisher = AnyPublisher(externalPublisher)
        self.information = InterfaceManagerData()
        self.model = InterfaceManagerModel()
        super.init()
    }
    
    /// User interface style setup
    func setup(_ style: UIUserInterfaceStyle) {
        guard userStyle != style else { return }
        
        userStyle = style
        
        logger.console(event: .any(info: "User interface style was changed by user to \(appStyle.description) mode"))
        
        switch style {
            case .light, .dark:
                guard appStyle != style else { return }
                appStyle = style
                externalPublisher.send(appStyle)
            
            default:
                guard appStyle != screen.systemStyle else { return }
                appStyle = screen.systemStyle
                externalPublisher.send(appStyle)
        }
    }
    
    /// User interface style update
    func update() {
        guard userStyle == .unspecified, appStyle != screen.systemStyle else { return }
        
        appStyle = screen.systemStyle
        
        logger.console(event: .any(info: "User interface style was changed by system to \(appStyle.description) mode"))
        externalPublisher.send(appStyle)
    }
    
}

// MARK: - InterfaceManagerData
fileprivate struct InterfaceManagerData: InterfaceManagerDataProtocol {
    var systemStyle: UIUserInterfaceStyle {
        UIScreen.main.systemStyle
    }
    
    var userStyle: UIUserInterfaceStyle {
        InterfaceManager.entry.userStyle
    }
    
    var isLightMode: Bool {
        switch userStyle {
            case .unspecified:
                UIScreen.main.systemStyle == .light
            
            default:
                userStyle == .light
        }
    }
}

// MARK: - InterfaceManagerDataProtocol
protocol InterfaceManagerDataProtocol {
    var systemStyle: UIUserInterfaceStyle { get }
    var userStyle: UIUserInterfaceStyle { get }
    var isLightMode: Bool { get }
}

// MARK: - InterfaceManagerModel
struct InterfaceManagerModel {
    let color = InterfaceManagerColor()
    let gradient = InterfaceManagerGradient()
    let effect = InterfaceManagerEffect()
    let size = InterfaceManagerSize()
    let image = InterfaceManagerImage()
    let font = InterfaceManagerFont()
}

// MARK: - InterfaceManagerColor
struct InterfaceManagerColor {}

// MARK: - InterfaceManagerGradient
struct InterfaceManagerGradient {}

// MARK: - InterfaceManagerEffect
struct InterfaceManagerEffect {}

// MARK: - InterfaceManagerSize
struct InterfaceManagerSize {}

// MARK: - InterfaceManagerImage
struct InterfaceManagerImage {}

// MARK: - InterfaceManagerFont
struct InterfaceManagerFont {}
