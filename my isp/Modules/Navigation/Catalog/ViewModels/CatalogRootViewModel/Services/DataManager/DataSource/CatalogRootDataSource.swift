import UIKit
import Combine

class CatalogRootDataSource: CatalogRootDataSourceProtocol {
    
    let internalEventPublisher: PassthroughSubject<CatalogRootDataSourceInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<CatalogRootDataSourceExternalEvent, Never>
    
    private let device: DeviceProtocol
    private let externalPublisher: PassthroughSubject<CatalogRootDataSourceExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(device: DeviceProtocol) {
        self.device = device
        self.internalEventPublisher = PassthroughSubject<CatalogRootDataSourceInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<CatalogRootDataSourceExternalEvent, Never>()
        self.externalEventPublisher =  AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        setupObservers()
    }
    
}

// MARK: Private
private extension CatalogRootDataSource {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: CatalogRootDataSourceInternalEvent) {
        switch event {
            case .view:
                let value = CatalogRootViewLayout()
                externalPublisher.send(.view(value))
            
            case .navigationBar(let frame):
                let value = navigationBar(frame)
                externalPublisher.send(.appearance(.navigationBar(value)))
            
            case .systemInfo(let userInfo, let permission):
                let value = systemInfoRequest(userInfo, permission)
                externalPublisher.send(.request(.systemInfo(value)))
            
            case .firebase(let userInfo):
                let value = firebaseInfoRequest(userInfo)
                externalPublisher.send(.request(.firebaseInfo(value)))
        }
    }
    
    func navigationBar(_ frame: CGRect) -> NavigationBarAppearance {
        let title = String.localized.menuCatalog
        let model = NavigationBarAppearanceModel(title: title)
        let standardNavigationBarAppearance = UINavigationBarAppearance()
        standardNavigationBarAppearance.configureWithTransparentBackground()
        standardNavigationBarAppearance.shadowColor = .clear
        standardNavigationBarAppearance.titleTextAttributes = [.foregroundColor : UIColor.clear]
        let compactNavigationBarAppearance = UINavigationBarAppearance()
        compactNavigationBarAppearance.configureWithOpaqueBackground()
        compactNavigationBarAppearance.titleTextAttributes = [.font : UIFont.boldSystemFont(ofSize: 14.fitWidth), .foregroundColor : UIColor.interfaceManager.white()]
        compactNavigationBarAppearance.backgroundImage = UIImage.interfaceManager.themeNavigationBar(frame: frame)
        compactNavigationBarAppearance.backgroundImageContentMode = .scaleAspectFill
        compactNavigationBarAppearance.shadowColor = .clear
        let appearance = NavigationBarAppearance(model: model, standard: compactNavigationBarAppearance, compact: nil, scrollEdge: standardNavigationBarAppearance)
        return appearance
    }
    
    func systemInfoRequest(_ userInfo: AppUserInfo?, _ permission: CatalogRootPermissionData) -> CatalogRootRequest {
        let deviceInfo = deviceInfoRequest(userInfo, permission)
        let firebaseInfo = firebaseInfoRequest(userInfo)
        let request = CatalogRootRequest(deviceInfo: deviceInfo, firebaseInfo: firebaseInfo)
        return request
    }
    
    func deviceInfoRequest(_ userInfo: AppUserInfo?, _ permission: CatalogRootPermissionData) -> NetworkManagerRequest {
        let jwt = String(userInfo?.jsonWebToken)
        let phoneModel = device.modelName.replacingOccurrences(of: "Apple ", with: "")
        let platformVersion = device.systemVersion
        let notificationsPermission = permission.settings.notificationCenterSetting != .disabled ? "Push notifications - \(permission.settings.notificationCenterSetting.description)" : .clear
        let cameraPermission = permission.information.camera != .denied ? "Camera - \(permission.information.camera.description)" : .clear
        let microphonePermission = permission.information.microphone != .denied ? "Microphone - \(permission.information.microphone.description)" : .clear
        let photoLibraryPermission = permission.information.photoLibrary != .denied ? "Photo library - \(permission.information.photoLibrary.description)" : .clear
        let permissions = [notificationsPermission, cameraPermission, microphonePermission, photoLibraryPermission]
        let grantedPermissions = permissions.filter { !$0.isEmpty }.joined(separator: ", ")
        let path = URL.Server.deviceInformation
        let headers = ["JWT" : jwt]
        let parameters = ["phone_manufacturer" : "Apple", "phone_model" : phoneModel, "platform_version" : platformVersion, "webview_name" : "Safari", "webview_version" : platformVersion, "build_type" : platformVersion, "granted_permissions" : grantedPermissions]
        let request = NetworkManagerRequest(type: .post, path: path, headers: .additional(headers), parameters: .value(parameters))
        return request
    }
    
    func firebaseInfoRequest(_ userInfo: AppUserInfo?) -> NetworkManagerRequest {
        let jwt = String(userInfo?.jsonWebToken)
        let id = String(userInfo?.firebaseToken)
        let path = URL.Server.pushTokenRegister
        let headers = ["JWT" : jwt]
        let parameters = ["id" : id, "type" : "FCM"]
        let request = NetworkManagerRequest(type: .post, path: path, headers: .additional(headers), parameters: .value(parameters))
        return request
    }
    
}

// MARK: - CatalogRootDataSourceInternalEvent
enum CatalogRootDataSourceInternalEvent {
    case view
    case navigationBar(CGRect)
    case systemInfo(userInfo: AppUserInfo?, permission: CatalogRootPermissionData)
    case firebase(AppUserInfo?)
}

// MARK: - CatalogRootDataSourceExternalEvent
enum CatalogRootDataSourceExternalEvent {
    case view(CatalogRootViewLayout)
    case appearance(AppearanceTarget)
    case request(CatalogRootNetworkInternalEvent)
}
