import Foundation
import AVFoundation

extension AVAuthorizationStatus {
    
    var description: String {
        switch self {
            case .notDetermined:
                "not determined"
            
            case .restricted:
                "restricted"
            
            case .denied:
                "denied"
            
            case .authorized:
                "authorized"
            
            default:
                "unknown"
        }
    }
    
}
