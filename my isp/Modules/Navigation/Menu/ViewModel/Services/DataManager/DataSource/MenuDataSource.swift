import UIKit
import Combine

class MenuDataSource: MenuDataSourceProtocol {
    
    let internalEventPublisher: PassthroughSubject<MenuDataSourceInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MenuDataSourceExternalEvent, Never>
    
    private let screen: ScreenProtocol
    private let device: DeviceProtocol
    private let externalPublisher: PassthroughSubject<MenuDataSourceExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(screen: ScreenProtocol, device: DeviceProtocol) {
        self.screen = screen
        self.device = device
        self.internalEventPublisher = PassthroughSubject<MenuDataSourceInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MenuDataSourceExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension MenuDataSource {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MenuDataSourceInternalEvent) {
        switch event {
            case .login:
                let value = login()
                externalPublisher.send(.login(value))
            
            case .navigation:
                let value = navigation()
                externalPublisher.send(.navigation(value))
            
            case .tabBarData(let frame):
                let value = tabBarData(frame)
                externalPublisher.send(.tabBarData(value))
            
            case .tabBarApperance(let frame):
                let value = tabBarAppearance(frame)
                externalPublisher.send(.tabBarApperance(value))

            case .biometrics, .password:
                break
        }
    }
    
    func login() -> MenuLoginShift {
        let duration = 0.75
        let screen = screen.bounds
        let viewFrameOne = CGRect(x: screen.width, y: screen.minY, width: screen.width, height: screen.height)
        let keyViewFrame = CGRect(x: -screen.width, y: screen.minY, width: screen.width, height: screen.height)
        let keyViewBrightness = -0.3
        let message = String.localized.authorizationSuccess
        let value = MenuLoginShift(duration: duration, viewFrameOne: viewFrameOne, viewFrameTwo: screen, keyViewFrame: keyViewFrame, keyViewBrightness: keyViewBrightness, message: message)
        return value
    }
    
    func navigation() -> MenuNavigationShift {
        let duration = 0.5
        let alpha = 0.0
        let value = MenuNavigationShift(duration: duration, alpha: alpha)
        return value
    }
    
    func tabBarData(_ bounds: CGRect) -> MenuPresenterSetupData {
        let appearance = tabBarAppearance(bounds)
        let shapeLаyer: CAShapeLayer? = device.isUsingFaceID ? shapeLayer(bounds, appearance) : nil
        let borderLаyer: CALayer? = device.isUsingFaceID ? nil : borderLayer(bounds, appearance)
        let data = MenuPresenterSetupData(shapeLayer: shapeLаyer, borderLayer: borderLаyer, appearance: appearance)
        return data
    }
    
    func shapeLayer(_ bounds: CGRect, _ appearance: MenuPresenterAppearance) -> CAShapeLayer {
        let positionX = 17.0
        let positionY = 16.5
        let width = bounds.width - positionX * 2
        let height = bounds.height + positionY * 2
        let roundedRect = CGRect(x: positionX, y: bounds.minY - positionY, width: width, height: height)
        let cornerRadius = height / 2.8
        let bezierPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.shadowOpacity = appearance.shadowOpacity
        shapeLayer.shadowRadius = appearance.shadowRadius
        shapeLayer.shadowOffset = appearance.shadowOffset
        return shapeLayer
    }
    
    func borderLayer(_ bounds: CGRect, _ appearance: MenuPresenterAppearance) -> CALayer {
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0.26)
        layer.backgroundColor = appearance.borderColor
        return layer
    }
    
    func tabBarAppearance(_ bounds: CGRect) -> MenuPresenterAppearance {
        let tintColor = UIColor.interfaceManager.themeMenuTabBarTint()
        let borderColor = UIColor.interfaceManager.themeMenuTabBarBorder().withAlphaComponent(0.4.fitWidth).cgColor
        let unselectedItemTintColor = UIColor.interfaceManager.lightGray()
        let itemWidth = bounds.width / 7
        let backgroundColor = UIColor.interfaceManager.themeMenuTabBarBackground()
        let backgroundImage = UIImage.clear
        let shadowImage = UIImage.clear
        let shadowOpacity = Float(0.15)
        let shadowRadius = 6.0
        let shadowOffset = CGSize.zero
        let appearance = MenuPresenterAppearance(isUsingFaceID: device.isUsingFaceID, tintColor: tintColor, borderColor: borderColor, unselectedItemTintColor: unselectedItemTintColor, itemWidth: itemWidth, backgroundColor: backgroundColor, backgroundImage: backgroundImage, shadowImage: shadowImage, shadowOpacity: shadowOpacity, shadowRadius: shadowRadius, shadowOffset: shadowOffset)
        return appearance
    }
    
}

// MARK: - MenuDataSourceInternalEvent
enum MenuDataSourceInternalEvent {
    case login
    case navigation
    case tabBarData(CGRect)
    case tabBarApperance(CGRect)
    case biometrics
    case password
}

// MARK: - MenuDataSourceExternalEvent
enum MenuDataSourceExternalEvent {
    case login(MenuLoginShift)
    case navigation(MenuNavigationShift)
    case tabBarData(MenuPresenterSetupData)
    case tabBarApperance(MenuPresenterAppearance)
    case biometrics
    case password
}
