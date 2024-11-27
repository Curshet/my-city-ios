import Foundation
import AVFoundation
import Photos
import Combine

class PermissionManager: NSObject, PermissionManagerProtocol {
    
    let internalEventPublisher: PassthroughSubject<PermissionManagerInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<PermissionManagerExternalEvent, Never>
    
    private let externalPublisher: PassthroughSubject<PermissionManagerExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    override init() {
        self.internalEventPublisher = PassthroughSubject<PermissionManagerInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<PermissionManagerExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
}

// MARK: Private
private extension PermissionManager {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)

    }
    
    func internalEventHandler(_ event: PermissionManagerInternalEvent) {
        switch event {
            case .camera, .microphone:
                let target: AVMediaType = event == .camera ? .video : .audio
                mediaTypeRequest(target)
            
            case .photoLibrary:
                photoLibraryRequest()
        }
    }
    
    func mediaTypeRequest(_ target: AVMediaType) {
        AVCaptureDevice.requestAccess(for: target) { [weak self] in
            let event: PermissionManagerExternalEvent = target == .video ? .camera($0) : .microphone($0)
            self?.logger.console(event: .any(info: target == .video ? "Camera" : "Microphone" + " device permission has a status of \($0)"))
            self?.externalPublisher.send(event)
        }
    }
    
    func photoLibraryRequest() {
        PHPhotoLibrary.requestAuthorization { [weak self] in
            self?.logger.console(event: .any(info: "Photo library permission has a status of \($0.description)"))
            self?.externalPublisher.send(.photoLibrary($0))
        }
    }
    
}

// MARK: Protocol
extension PermissionManager {
    
    var information: PermissionManagerData {
        let camera = AVCaptureDevice.authorizationStatus(for: .video)
        let microphone = AVCaptureDevice.authorizationStatus(for: .audio)
        let photoLibrary = PHPhotoLibrary.authorizationStatus()
        let information = PermissionManagerData(camera: camera, microphone: microphone, photoLibrary: photoLibrary)
        return information
    }
    
}

// MARK: - PermissionManagerData
struct PermissionManagerData {
    let camera: AVAuthorizationStatus
    let microphone: AVAuthorizationStatus
    let photoLibrary: PHAuthorizationStatus
}

// MARK: - PermissionManagerInternalEvent
enum PermissionManagerInternalEvent {
    case camera
    case microphone
    case photoLibrary
}

// MARK: - PermissionManagerExternalEvent
enum PermissionManagerExternalEvent {
    case camera(Bool)
    case microphone(Bool)
    case photoLibrary(PHAuthorizationStatus)
}
