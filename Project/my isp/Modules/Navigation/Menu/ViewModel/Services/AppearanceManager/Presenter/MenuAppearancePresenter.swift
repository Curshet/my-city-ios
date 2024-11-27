import UIKit
import Combine

class MenuAppearancePresenter: NSObject, MenuAppearancePresenterProtocol {
    
    let internalEventPublisher: PassthroughSubject<MenuAppearancePresenterInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MenuAppearancePresenterExternalEvent, Never>
    
    private weak var tabBar: UITabBar?
    private weak var shapeLayer: CAShapeLayer?
    private weak var borderLayer: CALayer?
    private let externalPublisher: PassthroughSubject<MenuAppearancePresenterExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    override init() {
        self.internalEventPublisher = PassthroughSubject<MenuAppearancePresenterInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<MenuAppearancePresenterExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
}

// MARK: Private
private extension MenuAppearancePresenter {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: MenuAppearancePresenterInternalEvent) {
        switch event {
            case .inject(let value):
                guard tabBar == nil else { return }
                tabBar = value
                externalPublisher.send(.setup(value.bounds))
            
            case .setup(let value):
                setupTabBar(value)
            
            case .update:
                externalPublisher.send(.update(tabBar?.bounds ?? .zero))
        }
    }
    
    func setupTabBar(_ value: MenuPresenterData) {
        guard let tabBar else {
            logger.console(event: .error(info: MenuAppearancePresenterMessage.tabBarError))
            return
        }
        
        switch value {
            case .setup(let value):
                setupAppearance(tabBar, value)
            
            case .update(let value):
                updateAppearance(tabBar, value)
        }
    }
    
    func setupAppearance(_ tabBar: UITabBar, _ value: MenuPresenterSetupData) {
        switch value.appearance.isUsingFaceID {
            case true:
                setupTabBarAppearance(tabBar, value)
            
            case false:
                setupLegacyTabBarAppearance(tabBar, value)
        }
    }
    
    func setupTabBarAppearance(_ tabBar: UITabBar, _ value: MenuPresenterSetupData) {
        guard shapeLayer == nil, let layer = value.shapeLayer else { return }
        
        shapeLayer = layer
        tabBar.itemPositioning = .centered
        tabBar.itemWidth = value.appearance.itemWidth
        tabBar.layer.insertSublayer(layer, at: .zero)
        updateAppearance(tabBar, value.appearance)
    }
    
    func setupLegacyTabBarAppearance(_ tabBar: UITabBar, _ value: MenuPresenterSetupData) {
        guard borderLayer == nil, let layer = value.borderLayer else { return }
        
        borderLayer = layer
        tabBar.itemPositioning = .fill
        tabBar.backgroundColor = value.appearance.backgroundColor
        tabBar.layer.addSublayer(layer)
        updateAppearance(tabBar, value.appearance)
    }
    
    func updateAppearance(_ tabBar: UITabBar, _ value: MenuPresenterAppearance) {
        tabBar.tintColor = value.tintColor
        tabBar.unselectedItemTintColor = value.unselectedItemTintColor
        tabBar.backgroundImage = value.backgroundImage
        tabBar.shadowImage = value.shadowImage
        
        switch value.isUsingFaceID {
            case true:
                updateTabBarAppearance(tabBar, value)
            
            case false:
                updateLegacyTabBarAppearance(tabBar, value)
        }
    }
    
    func updateTabBarAppearance(_ tabBar: UITabBar, _ value: MenuPresenterAppearance) {
        guard let shapeLayer else {
            logger.console(event: .error(info: MenuAppearancePresenterMessage.shapeLayerError))
            return
        }
        
        shapeLayer.fillColor = value.backgroundColor.cgColor
    }
    
    func updateLegacyTabBarAppearance(_ tabBar: UITabBar, _ value: MenuPresenterAppearance) {
        guard let borderLayer else {
            logger.console(event: .error(info: MenuAppearancePresenterMessage.borderLayerError))
            return
        }
        
        tabBar.backgroundColor = value.backgroundColor
        borderLayer.backgroundColor = value.borderColor
    }
    
}

// MARK: - MenuAppearancePresenterMessage
fileprivate enum MenuAppearancePresenterMessage {
    static let tabBarError = "Navigation menu appearance presenter doesn't have a tab bar"
    static let shapeLayerError = "Navigation menu appearance presenter doesn't have a tab bar shape layer"
    static let borderLayerError = "Navigation menu appearance presenter doesn't have a tab bar border layer"
}

// MARK: - MenuAppearancePresenterInternalEvent
enum MenuAppearancePresenterInternalEvent {
    case inject(tabBar: UITabBar)
    case setup(MenuPresenterData)
    case update
}

// MARK: - MenuAppearancePresenterExternalEvent
enum MenuAppearancePresenterExternalEvent {
    case setup(CGRect)
    case update(CGRect)
}
