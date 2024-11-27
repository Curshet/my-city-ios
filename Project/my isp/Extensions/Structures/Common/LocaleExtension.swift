import Foundation

extension Locale {
    
    var appLanguage: LocalizationManagerLanguage {
        guard let userAppLocalization = Bundle.main.preferredLocalizations.first else {
            return systemLocale.hasPrefix("ru") ? .russian : .english
        }
        
        return userAppLocalization.hasPrefix("ru") ? .russian : .english
    }
    
    var systemLocale: String {
        String(Self.preferredLanguages.first)
    }
    
    var systemRegion: String {
        identifier
    }
    
}
