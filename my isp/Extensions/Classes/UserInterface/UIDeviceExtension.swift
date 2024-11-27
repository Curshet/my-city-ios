import UIKit
import CoreTelephony
import LocalAuthentication

extension UIDevice: DeviceProtocol {
    
    var isAirplaneMode: Bool {
        let telephonyInfo = CTTelephonyNetworkInfo()
        
        if let currentAccess = telephonyInfo.serviceCurrentRadioAccessTechnology {
            let isActivated = currentAccess.values.first == nil
            return isActivated
        }
        
        return true
    }
    
    var isUsingFaceID: Bool {
        let context = LAContext()
        return context.biometryType == .faceID
    }
    
    var modelName: String {
        guard let deviceModel = deviceModels[modelIdentifier], !deviceModel.isEmpty() else { return modelIdentifier }
        return deviceModel
    }
    
    var modelIdentifier: String {
        var utsName = utsname()
        uname(&utsName)
        
        let deviceIdentifier = withUnsafePointer(to: &utsName.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String.init(validatingUTF8: $0)
            }
        }
        
        guard let deviceIdentifier, !deviceIdentifier.isEmpty() else { return "N/A" }
        return deviceIdentifier
    }

}

fileprivate let deviceModels = ["i386" : "Software Device Simulator", "x86_64" : "Software Device Simulator", "arm64" : "Software Device Simulator", "iPhone8,1" : "Apple iPhone 6S", "iPhone8,2" : "Apple iPhone 6S Plus", "iPhone8,4" : "Apple iPhone SE (2016)", "iPhone9,1" : "Apple iPhone 7", "iPhone9,3" : "Apple iPhone 7", "iPhone9,2" : "Apple iPhone 7 Plus", "iPhone9,4" : "Apple iPhone 7 Plus", "iPhone10,1" : "Apple iPhone 8", "iPhone10,4" : "Apple iPhone 8", "iPhone10,2" : "Apple iPhone 8 Plus", "iPhone10,5" : "Apple iPhone 8 Plus", "iPhone10,3" : "Apple iPhone X", "iPhone10,6" : "Apple iPhone X", "iPhone11,2" : "Apple iPhone XS", "iPhone11,4" : "Apple iPhone XS Max", "iPhone11,6" : "Apple iPhone XS Max", "iPhone11,8" : "Apple iPhone XR", "iPhone12,1" : "Apple iPhone 11", "iPhone12,3" : "Apple iPhone 11 Pro", "iPhone12,5" : "Apple iPhone 11 Pro Max", "iPhone12,8" : "Apple iPhone SE (2020)", "iPhone13,1" : "Apple iPhone 12 mini", "iPhone13,2" : "Apple iPhone 12", "iPhone13,3" : "Apple iPhone 12 Pro", "iPhone13,4" : "Apple iPhone 12 Pro Max", "iPhone14,1" : "Apple iPhone 13 mini", "iPhone14,2" : "Apple iPhone 13", "iPhone14,3" : "Apple iPhone 13 Pro", "iPhone14,4" : "Apple iPhone 13 Pro Max", "iPhone14,6" : "Apple iPhone SE (2022)", "iPhone14,7" : "Apple iPhone 14", "iPhone14,8" : "Apple iPhone 14 Plus", "iPhone15,2" : "Apple iPhone 14 Pro", "iPhone15,3" : "Apple iPhone 14 Pro Max", "iPhone15,4" : "Apple iPhone 15", "iPhone15,5" : "Apple iPhone 15 Plus", "iPhone16,1" : "Apple iPhone 15 Pro", "iPhone16,2" : "Apple iPhone 15 Pro Max", "iPhone17,3" : "iPhone 16", "iPhone17,4" : "iPhone 16 Plus", "iPhone17,1" : "iPhone 16 Pro", "iPhone17,2" : "iPhone 16 Pro Max"]
