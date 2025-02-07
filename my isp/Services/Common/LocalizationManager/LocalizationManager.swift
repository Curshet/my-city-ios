import Foundation
import Combine

final class LocalizationManager: NSObject, LocalizationManagerControlProtocol {
    
    static let entry = LocalizationManager()
    
    /// User localization switching publisher
    let publisher: AnyPublisher<LocalizationManagerLanguage, Never>
    
    /// User localization information
    let information: LocalizationManagerDataProtocol
    
    /// User interface localized text
    let text: LocalizationManagerText
    
    private let locale: Locale
    private let storage: DataStorageControlProtocol
    private let externalPublisher: PassthroughSubject<LocalizationManagerLanguage, Never>

    private override init() {
        self.locale = Locale.autoupdatingCurrent
        self.storage = DataStorage.entry
        self.externalPublisher = PassthroughSubject<LocalizationManagerLanguage, Never>()
        self.publisher = AnyPublisher(externalPublisher)
        self.information = LocalizationManagerData()
        self.text = LocalizationManagerText()
        super.init()
        start()
    }
    
    private func start() {
        logger.console(event: .any(info: "Application started with \(information.appLanguage) localization \(information.appLanguage.symbol)"))
    }
    
    /// User interface localization setup
    func setup(_ target: LocalizationManagerLanguage) {
        guard information.appLanguage != target else { return }
    
        logger.console(event: .any(info: "User has chosen the application's language as \(target) \(target.symbol)"))
        
        switch target {
            case .russian:
                guard information.appLanguage != .russian else { return }
                storage.saveInfo(key: LocalizationManagerKey.preferred, value: [LocalizationManagerKey.russian])
            
            case .english:
                guard information.appLanguage != .english else { return }
                storage.saveInfo(key: LocalizationManagerKey.preferred, value: [LocalizationManagerKey.english])
        }
        
        externalPublisher.send(target)
    }
    
}

// MARK: - LocalizationManagerKey
fileprivate enum LocalizationManagerKey {
    static let preferred = "AppleLanguages"
    static let english = "en"
    static let russian = "ru"
}

// MARK: - LocalizationManagerData
fileprivate struct LocalizationManagerData: LocalizationManagerDataProtocol {
    var appLanguage: LocalizationManagerLanguage {
        Locale.autoupdatingCurrent.appLanguage
    }
    
    var appSupporting: Bool {
        systemLocale == LocalizationManagerKey.russian || systemLocale == LocalizationManagerKey.english
    }
    
    var systemLocale: String {
        Locale.autoupdatingCurrent.systemLocale
    }
    
    var systemRegion: String {
        Locale.autoupdatingCurrent.systemRegion
    }
}

// MARK: - LocalizationManagerDataProtocol
protocol LocalizationManagerDataProtocol {
    var appLanguage: LocalizationManagerLanguage { get }
    var appSupporting: Bool { get }
    var systemLocale: String { get }
    var systemRegion: String { get }
}

// MARK: - LocalizationManagerLanguage
enum LocalizationManagerLanguage {
    case english
    case russian

    fileprivate var symbol: String {
        switch self {
            case .english:
                "🇬🇧"
            
            case .russian:
                "🇷🇺"
        }
    }
}

// MARK: - LocalizationManagerText
struct LocalizationManagerText {
    var emptyContent: String {
        "N/A ⛱️"
    }
    
    var okay: String {
        "OK"
    }
}
