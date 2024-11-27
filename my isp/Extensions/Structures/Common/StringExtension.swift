import Foundation

extension String {
    
    static var localized: LocalizationManagerText {
        LocalizationManager.entry.text
    }
    
    static var clear: String {
        ""
    }
    
    static var unique: String {
        UUID().uuidString
    }
    
    static func create(data: Data?, encoding: String.Encoding = .utf8, options: JSONSerialization.WritingOptions = .prettyPrinted, file: String = #file, line: Int = #line) -> String {
        lazy var dеfault = "nil"
        
        guard let data, !data.isEmpty else {
            dеfault.logger.console(event: .error(info: "Creating string is failure for unavalible data"), file: file, line: line)
            return dеfault
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data)
            return Self.create(json: json, encoding: encoding, options: options)
        } catch {
            dеfault.logger.console(event: .error(info: "Creating string is failure with error: \(error)"), file: file, line: line)
            return dеfault
        }
    }
    
    static func create(json: Any?, encoding: String.Encoding = .utf8, options: JSONSerialization.WritingOptions = .prettyPrinted, file: String = #file, line: Int = #line) -> String {
        lazy var dеfault = "nil"
        
        guard let json, JSONSerialization.isValidJSONObject(json) else {
            dеfault.logger.console(event: .error(info: "Creating string is failure for unavalible JSON value"), file: file, line: line)
            return dеfault
        }
        
        do {
            let string = try String(data: JSONSerialization.data(withJSONObject: json, options: options), encoding: encoding)
            return string ?? dеfault
        } catch {
            dеfault.logger.console(event: .error(info: "Creating string is failure with error: \(error)"), file: file, line: line)
            return dеfault
        }
    }
    
    static func create(seconds: Double, file: String = #file, line: Int = #line) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        let string = formatter.string(from: Double(seconds)) ?? .clear
        guard string.isEmpty else { return string }
        formatter.logger.console(event: .error(info: "Creating string from seconds value is failure"), file: file, line: line)
        return "00 : 00 : 00"
    }
    
    var localized: String {
        NSLocalizedString(self, comment: .clear)
    }
    
    var isEmptyContent: Bool {
        self == "nil" || self == .localized.emptyContent
    }
    
    var isNumeric: Bool {
        replacingOccurrences(of: "[0-9]", with: "", options: .regularExpression).isEmpty
    }
    
    init(_ optional: Any?) {
        switch optional {
            case .some(let value):
                let string = "\(value)"
                self = string.isEmpty() ? "nil" : string
            
            case nil:
                self = "nil"
        }
    }
    
    func isEmpty() -> Bool {
        self == .clear || removeSymbols(" ", "\n", "%n").isEmpty
    }
    
    func base64Decoded(file: String = #file, line: Int = #line) -> String {
        guard let data = Data(base64Encoded: self), let string = String(data: data, encoding: .utf8) else {
            self.logger.console(event: .error(info: "Decoding BASE-64 data to UTF-8 string is failure"), file: file, line: line)
            return .clear
        }
        
        return string
    }
    
    func htmlDecoded(file: String = #file, line: Int = #line) -> String {
        do {
            return try NSAttributedString(data: Data(self.utf8), options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil).string
        } catch {
            self.logger.console(event: .error(info: "Decoding HTML data to UTF-8 string is aborted with error: \(error)"), file: file, line: line)
            return .clear
        }
    }
    
    func phoneMask(withCode: Bool) -> String {
        let mask = withCode ? "+X XXX XXX-XX-XX" : "XXX XXX-XX-XX"
        let phone = replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var startIndex = phone.startIndex
        var result = ""
        
        for element in mask where startIndex < phone.endIndex {
            guard element == "X" else {
                result.append(element)
                continue
            }
            
            result.append(phone[startIndex])
            startIndex = phone.index(after: startIndex)
        }
        
        return result
    }
    
    func removeSymbols(_ characters: String..., to value: String = .clear) -> String {
        var result = ""
        
        for character in characters {
            guard !character.isEmpty else { continue }
            
            switch result.isEmpty {
                case true:
                    guard contains(character) else { continue }
                    result = replacingOccurrences(of: character, with: value)
                
                case false:
                    guard result.contains(result) else { continue }
                    result = result.replacingOccurrences(of: character, with: value)
            }
        }
        
        return result.isEmpty ? self : result
    }
    
}
