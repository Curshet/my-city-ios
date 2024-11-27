import UIKit
import Combine
import Swinject

final class LoggingManager {

    static let entry = LoggingManager()
    
    /// External event publisher
    let publisher: AnyPublisher<LoggingEvent, Never>
    
    private let isDebug: Bool
    private let locale: Locale
    private let bundle: BundleProtocol
    private let device: DeviceProtocol
    private let externalPublisher: PassthroughSubject<LoggingEvent, Never>
    
    private init() {
        self.isDebug = UIApplication.isDebug
        self.locale = Locale.autoupdatingCurrent
        self.bundle = Bundle.main
        self.device = UIDevice.current
        self.externalPublisher = PassthroughSubject<LoggingEvent, Never>()
        self.publisher = AnyPublisher(externalPublisher)
        startConfiguration()
    }
    
    /// Printing events in console
    func console(event: LoggingEvent, type: LoggingPrintType = .print, isPrintable: Bool = true, isSendable: Bool = true, file: String = #file, line: Int = #line) {
        isDebug ? testingLogging(event: event, isPrintable: isPrintable, type: type, file: file, line: line) : productLogging(event: event, isSendable: isSendable, file: file, line: line)
    }

}

// MARK: Private
private extension LoggingManager {
    
    func startConfiguration() {
        Container.loggingFunction = nil
        UserDefaults.standard.set(isDebug, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }

    func testingLogging(event: LoggingEvent, isPrintable: Bool, type: LoggingPrintType, file: String, line: Int) {
        guard isPrintable else { return }
        
        let eventMessage = createEventMessage(event: event, file: file, line: line)
        
        guard !eventMessage.isEmpty else {
            let errorMessage = createLoggingErrorMessage(isTesting: true, file: file, line: line)
            print(errorMessage)
            return
        }
        
        switch type {
            case .print:
                print(eventMessage)
            
            case .debug:
                debugPrint(eventMessage)
            
            case .dump:
                dump(eventMessage)
        }
    }
    
    func productLogging(event: LoggingEvent, isSendable: Bool, file: String, line: Int) {
        guard isSendable else { return }
        
        let eventMessage = createEventMessage(event: event, file: file, line: line)
        
        switch eventMessage.isEmpty {
            case true:
                let errorMessage = createLoggingErrorMessage(isTesting: false, file: file, line: line)
                let event = event[errorMessage]
                externalPublisher.send((event))
                
            case false:
                let message = eventMessage.unicodeScalars.filter { !$0.properties.isEmojiPresentation }.reduce("") { $0 + String($1) }
                let event = event[message]
                externalPublisher.send((event))
        }
    }
    
    func createEventMessage(event: LoggingEvent, file: String, line: Int) -> String {
        let date = Date().convert(to: .utf)
        let prefixMessage = "[\(date)] Logger message -> "
        let systemInfo = "[App version: \(bundle.version), build: \(bundle.build), application language: \(locale.appLanguage), system localization identifier: \(locale.systemLocale), iOS: \(device.systemVersion), device: \(device.modelName)] -> "
        let fileName = file.components(separatedBy: "/").last
        let fileNameProduct = "File: \(fileName ?? "Error filename..."), "
        let fileNameTesting = "📂 File: \(fileName ?? "❌ Error filename..."), "
        let lineNumber = "line: \(line) -> "
        let baseMessage = createBaseMessage(event: event)
        let emptyMessage = "There is no information"
        
        switch event {
            case .any(info: let data):
                let text = String(data).isEmpty() ? emptyMessage : data
                guard isDebug else { return prefixMessage + systemInfo + fileNameProduct + lineNumber + baseMessage + "\(text)" }
                let eventDescription = "✏️ \(baseMessage) ⚠️ \(text)"
                let eventMessage = prefixMessage + fileNameTesting + lineNumber + eventDescription
                return eventMessage
            
            case .error(info: let data):
                let text = String(data).isEmptyContent ? emptyMessage : data
                guard isDebug else { return prefixMessage + systemInfo + fileNameProduct + lineNumber + baseMessage + "\(text)" }
                let eventDescription = "🔴 \(baseMessage) ⚠️ \(text) ‼️"
                let eventMessage = prefixMessage + fileNameTesting + lineNumber + eventDescription
                return eventMessage

            case .success(info: let data):
                let text = String(data).isEmptyContent ? emptyMessage : data
                guard isDebug else { return prefixMessage + systemInfo + fileNameProduct + lineNumber + baseMessage + "\(text)" }
                let eventDescription = "🟢 \(baseMessage) ⚠️ \(text) ❕"
                let eventMessage = prefixMessage + fileNameTesting + lineNumber + eventDescription
                return eventMessage
            
            case .showScreen(info: let data):
                let text = String(data).isEmptyContent ? emptyMessage : data
                guard isDebug else { return prefixMessage + systemInfo + fileNameProduct + lineNumber + baseMessage + "\(text)" }
                let eventDescription = "🔺 \(baseMessage) ⚠️ \(text)"
                let eventMessage = prefixMessage + fileNameTesting + lineNumber + eventDescription
                return eventMessage
            
            case .closeScreen(info: let data):
                let text = String(data).isEmptyContent ? emptyMessage : data
                guard isDebug else { return prefixMessage + systemInfo + fileNameProduct + lineNumber + baseMessage + "\(text)" }
                let eventDescription = "🔻 \(baseMessage) ⚠️ \(text)"
                let eventMessage = prefixMessage + fileNameTesting + lineNumber + eventDescription
                return eventMessage
            
            case .userInteraction(info: let data):
                let text = String(data).isEmptyContent ? emptyMessage : data
                guard isDebug else { return prefixMessage + systemInfo +  fileNameProduct + lineNumber + baseMessage + "\(text)" }
                let eventDescription = "👆 \(baseMessage) ⚠️ \(text)"
                let eventMessage = prefixMessage + fileNameTesting + lineNumber + eventDescription
                return eventMessage
            
            case .userNotification(info: let data):
                let text = String(data).isEmptyContent ? emptyMessage : data
                guard isDebug else { return prefixMessage + systemInfo +  fileNameProduct + lineNumber + baseMessage + "\(text)" }
                let eventDescription = "💬 \(baseMessage) ⚠️ \(text)"
                let eventMessage = prefixMessage + fileNameTesting + lineNumber + eventDescription
                return eventMessage
            
            case .pushNotification(info: let data):
                let text = String(data).isEmptyContent ? emptyMessage : data
                guard isDebug else { return prefixMessage + systemInfo +  fileNameProduct + lineNumber + baseMessage + "\(text)" }
                let eventDescription = "🚀 \(baseMessage) ⚠️ \(text)"
                let eventMessage = prefixMessage + fileNameTesting + lineNumber + eventDescription
                return eventMessage
            
            case .metric(_, info: let data):
                let text = String(data).isEmptyContent ? emptyMessage : data
                guard isDebug else { return prefixMessage + systemInfo + fileNameProduct + lineNumber + baseMessage + "\(text)" }
                let eventDescription = "📌 \(baseMessage) ⚠️ \(text)"
                let eventMessage = prefixMessage + fileNameTesting + lineNumber + eventDescription
                return eventMessage
        }
    }
    
    func createBaseMessage(event: LoggingEvent) -> String {
        switch event {
            case .any:
                "Event ->"
        
            case .error:
                "Error event ->"
            
            case .success:
                "Success event ->"
        
            case .showScreen:
                "Showing screen event ->"
        
            case .closeScreen:
                "Closing screen event ->"
            
            case .userInteraction:
                "User interaction event ->"
            
            case .userNotification:
                "User notification event ->"
            
            case .pushNotification:
                "Push notification event ->"
            
            case .metric(let type, _):
                "\(type == .system ? "System" : "Yandex") metric data event ->"
        }
    }
    
    func createLoggingErrorMessage(isTesting: Bool, file: String, line: Int) -> String {
        let date = Date().convert(to: .utf)
        let prefixMessage = "[\(date)] Logger message -> "
        let systemInfo = "[Application version: \(bundle.version), build: \(bundle.build), application language: \(locale.appLanguage), system localization identifier: \(locale.systemLocale), iOS: \(device.systemVersion), device: \(device.modelName)] -> "
        let fileName = file.components(separatedBy: "/").last
        let lineNumber = "line: \(line) -> "
        let errorMessage: String
        
        switch isTesting {
            case true:
                let fileDescription = "📂 File: \(fileName ?? "🔴 Error filename..."), "
                errorMessage = prefixMessage + fileDescription + lineNumber + "🔴 Error logging... ‼️"
                
            case false:
                let fileDescription = "File: \(fileName ?? "Error filename..."), "
                errorMessage = prefixMessage + systemInfo + fileDescription + lineNumber + "Error logging..."
        }
        
        return errorMessage
    }
    
}

// MARK: - LoggerPrintType
enum LoggingPrintType {
    case print
    case debug
    case dump
}

// MARK: - LoggingEvent
enum LoggingEvent {
    case any(info: Any)
    case error(info: Any)
    case success(info: Any)
    case showScreen(info: Any)
    case closeScreen(info: Any)
    case userInteraction(info: Any)
    case userNotification(info: Any)
    case pushNotification(info: Any)
    case metric(_ type: LoggingMetricType, info: Any)
    
    fileprivate subscript(_ message: String) -> Self {
        switch self {
            case .any:
                .any(info: message)
            
            case .error:
                .error(info: message)
            
            case .success:
                .success(info: message)
            
            case .showScreen:
                .showScreen(info: message)
            
            case .closeScreen:
                .closeScreen(info: message)
            
            case .userInteraction:
                .userInteraction(info: message)
            
            case .userNotification:
                .userNotification(info: message)
            
            case .pushNotification:
                .pushNotification(info: message)
            
            case .metric(let type, _):
                .metric(type, info: message)
        }
    }
}

// MARK: - LoggingMetricType
enum LoggingMetricType {
    case system
    case yandex
}
