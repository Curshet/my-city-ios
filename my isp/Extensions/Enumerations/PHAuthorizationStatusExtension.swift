import Foundation
import Photos

extension PHAuthorizationStatus {
    
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
            
            case .limited:
                "limited"
            
            default:
                "unknown"
        }
    }
    
}
