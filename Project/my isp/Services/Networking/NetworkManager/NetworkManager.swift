import UIKit
import Alamofire

class NetworkManager: NSObject {
    
    private let decoder: JSONDecoderProtocol
    
    init(decoder: JSONDecoderProtocol) {
        self.decoder = decoder
        super.init()
    }
    
}

// MARK: Private
private extension NetworkManager {
    
    func isCorrect(path: String, _ request: HTTPMethod, _ file: String, _ line: Int) -> Bool {
        guard !path.isEmpty(), path.hasPrefix(NetworkManagerInfo.pathPrefix) else {
            path.isEmpty() ? loggerEvent(type: .emptyPath(request), path, true, true, file, line) : loggerEvent(type: .lostPrefix(request), path, true, true, file, line)
            return false
        }
    
        return true
    }
                                
    func loggerEvent(type: NetworkManagerEvent, _ path: String, _ isPrintable: Bool, _ isSendable: Bool, _ file: String, _ line: Int) {
        switch type {
            case .start(let request, let headers, let parameters):
                logger.console(event: .any(info: "Network session is starting for URL: \(path), request type: \(request.rawValue), headers: \(headers), parameters: \(parameters)"), isPrintable: isPrintable, isSendable: isSendable, file: file, line: line)
            
            case .success(let request, let code, let data):
                logger.console(event: .success(info: "Network data request succeed for URL: \(path), request type: \(request.rawValue), status code: \(String(code)) -> ⚡️ \(String.create(data: data, encoding: .utf8, options: .fragmentsAllowed))"), isPrintable: isPrintable, isSendable: isSendable, file: file, line: line)
            
            case .failure(let request, let code, let description):
                logger.console(event: .error(info: "Network data request failed for URL: \(path), request type: \(request.rawValue), status code: \(String(code)) -> ⚡️ \(description)"), isPrintable: isPrintable, isSendable: isSendable, file: file, line: line)
            
            case .error(let request, let error):
                logger.console(event: .error(info: "Network data request error for URL: \(path), request type: \(request.rawValue) -> ⚡️ \(error)"), isPrintable: isPrintable, isSendable: isSendable, file: file, line: line)
            
            case .emptyPath(let request):
                logger.console(event: .error(info: "Network data request error for empty URL, request type: \(request.rawValue)"), isPrintable: isPrintable, isSendable: isSendable, file: file, line: line)
            
            case .lostPrefix(let request):
                logger.console(event: .error(info: "Network data request error for lost <\(NetworkManagerInfo.pathPrefix)> prefix of URL: \(path), request type: \(request.rawValue)"), isPrintable: isPrintable, isSendable: isSendable, file: file, line: line)
        }
    }
    
    func createSession(type: HTTPMethod, path: String, headers: NetworkManagerHeaders, parameters: NetworkManagerParameters, encoding: URLEncoding) -> DataRequest {
        let configuration = createConfiguration(headers: headers, parameters: parameters)
        let session = AF.request(path, method: type, parameters: configuration.parameters, encoding: encoding, headers: configuration.headers)
        return session
    }
    
    func createConfiguration(headers: NetworkManagerHeaders, parameters: NetworkManagerParameters) -> (headers: HTTPHeaders, parameters: Parameters) {
        let requestHeaders: HTTPHeaders
        let requestParameters: Parameters

        switch headers {
            case .empty:
                requestHeaders = [:]
            
            case .required:
                requestHeaders = Alamofire.HTTPHeaders(NetworkManagerInfo.requiredHeaders)
            
            case .additional(let value):
                requestHeaders = createAdditionalHeaders(value)
            
            case .value(let value):
                requestHeaders = Alamofire.HTTPHeaders(value)
        }
        
        switch parameters {
            case .empty:
                requestParameters = [:]
            
            case .value(let value):
                requestParameters = value
        }
        
        return (headers: requestHeaders, parameters: requestParameters)
    }
    
    func createAdditionalHeaders(_ values: [String : String]) -> HTTPHeaders {
        var headers = Alamofire.HTTPHeaders(NetworkManagerInfo.requiredHeaders)
        
        guard !values.isEmpty else {
            return headers
        }
    
        for key in values.keys {
            guard let header = values[key] else { continue }
            headers.add(name: key, value: header)
        }
        
        return headers
    }
    
    func errorHandler<D: Decodable, E: Error>(input: DataResponse<D, E>, _ path: String) -> (error: NSError, description: String)? {
        let statusCode = String(input.response?.statusCode)
        
        switch statusCode {
            case NetworkManagerInfo.successCode:
                return nil
            
            default:
                let error: NSError
            
                guard let response = input.response, let data = input.data, let json = try? JSONSerialization.jsonObject(with: data) as? [String : String], let errorDescription = json[NetworkManagerInfo.errorKey] else {
                        error = NSError(text: .localized.unknownError, domain: path)
                        return (error, error.localizedDescription)
                    }
            
                error = NSError(text: errorDescription, code: response.statusCode, domain: path)
                return (error, errorDescription)
        }
    }
    
}

// MARK: Public
extension NetworkManager {
    
    /// Returns the server data
    func request(_ value: NetworkManagerRequest, errorHandling: Bool = true, printable: Bool = true, sendable: Bool = true, file: String = #file, line: Int = #line, completion: ((Result<Data?, NSError>) -> Void)?) {
        guard isCorrect(path: value.path, value.type, file, line) else { return }
        
        let session = createSession(type: value.type, path: value.path, headers: value.headers, parameters: value.parameters, encoding: value.encoding ?? .default)
        loggerEvent(type: .start(value.type, value.headers, value.parameters), value.path, printable, sendable, file, line)

        session.response(queue: value.queue ?? .main) { [weak self] in
            switch $0.error as? NSError {
                case .some(let error):
                    self?.loggerEvent(type: .error(value.type, error), value.path, printable, sendable, file, line)
                    completion?(.failure(error))
                
                case nil:
                    let failure = self?.errorHandler(input: $0, value.path)
                    let statusCode = $0.response?.statusCode
            
                    guard let failure, errorHandling else {
                        self?.loggerEvent(type: .success(value.type, statusCode, $0.data), value.path, printable, sendable, file, line)
                        completion?(.success($0.data))
                        return
                    }
                
                    self?.loggerEvent(type: .failure(value.type, statusCode, failure.description), value.path, printable, sendable, file, line)
                    completion?(.failure(failure.error))
            }
        }
    }
    
    /// Returns the decoded server data
    func request<T: Decodable>(_ value: NetworkManagerRequest, dataModel: T.Type, errorHandling: Bool = true, printable: Bool = true, sendable: Bool = true, file: String = #file, line: Int = #line, completion: ((Result<T?, NSError>) -> Void)?) {
        guard isCorrect(path: value.path, value.type, file, line) else { return }
        
        let session = createSession(type: value.type, path: value.path, headers: value.headers, parameters: value.parameters, encoding: value.encoding ?? .default)
        loggerEvent(type: .start(value.type, value.headers, value.parameters), value.path, printable, sendable, file, line)

        session.responseDecodable(of: dataModel, queue: value.queue ?? .main, decoder: decoder) { [weak self] in
            switch $0.error as? NSError {
                case .some(let error):
                    self?.loggerEvent(type: .error(value.type, error), value.path, printable, sendable, file, line)
                    completion?(.failure(error))
                
                case nil:
                    let failure = self?.errorHandler(input: $0, value.path)
                    let statusCode = $0.response?.statusCode
                
                    guard let failure, errorHandling else {
                        self?.loggerEvent(type: .success(value.type, statusCode, $0.data), value.path, printable, sendable, file, line)
                        completion?(.success($0.value))
                        return
                    }
                    
                    self?.loggerEvent(type: .failure(value.type, statusCode, failure.description), value.path, printable, sendable, file, line)
                    completion?(.failure(failure.error))
            }
        }
    }
    
    /// Returns the information of server response
    func request<T: Decodable>(_ value: NetworkManagerRequest, dataType: T.Type, errorHandling: Bool = true, printable: Bool = true, sendable: Bool = true, file: String = #file, line: Int = #line, completion: ((DataResponse<T, AFError>) -> Void)?) {
        guard isCorrect(path: value.path, value.type, file, line) else { return }
        
        let session = createSession(type: value.type, path: value.path, headers: value.headers, parameters: value.parameters, encoding: value.encoding ?? .default)
        loggerEvent(type: .start(value.type, value.headers, value.parameters), value.path, printable, sendable, file, line)

        session.responseDecodable(of: dataType, queue: value.queue ?? .main, decoder: decoder) { [weak self] in
            switch $0.error as? NSError {
                case .some(let error):
                    self?.loggerEvent(type: .error(value.type, error), value.path, printable, sendable, file, line)
                
                case nil:
                    let failure = self?.errorHandler(input: $0, value.path)
                    let statusCode = $0.response?.statusCode
            
                    guard let failure, errorHandling else {
                        self?.loggerEvent(type: .success(value.type, statusCode, $0.data), value.path, printable, sendable, file, line)
                        break
                    }
                
                    self?.loggerEvent(type: .failure(value.type, statusCode, failure.description), value.path, printable, sendable, file, line)
            }
            
            completion?($0)
        }
    }
    
    /// Returns the result of server data handling
    func response<T: Decodable>(_ result: Result<T?, NSError>, path: String, file: String = #file, line: Int = #line) -> Result<T, NSError> {
        var data: T?
        
        switch result {
            case .success(let value):
                data = value
            
            case .failure(let error):
                return .failure(error)
        }
        
        guard let data else {
            let error = NSError.dataFailure(domain: path)
            logger.console(event: .error(info: error), file: file, line: line)
            return .failure(error)
        }

        return .success(data)
    }
    
}

// MARK: - NetworkManagerInfo
fileprivate enum NetworkManagerInfo {
    static let pathPrefix = URL.Service.prefix
    static let successCode = "200"
    static let errorKey = "error"

    static var requiredHeaders: [String : String] {
        let modelIdentifier = UIDevice.current.modelIdentifier
        let appVersion = Bundle.main.version
        let appIdentifier = Bundle.main.identifier
        let headers = ["Accept" : "application/json", "Content-Type" : "application/x-www-form-urlencoded", "x-cabinet" : "1", "x-device" : modelIdentifier, "x-app-version" : appVersion, "x-app-id" : appIdentifier, "x-app-platform" : "iOS"]
        return headers
    }
}

// MARK: - NetworkManagerEvent
fileprivate enum NetworkManagerEvent {
    case start(HTTPMethod, NetworkManagerHeaders, NetworkManagerParameters)
    case success(HTTPMethod, Int?, Data?)
    case error(HTTPMethod, NSError)
    case failure(HTTPMethod, Int?, String)
    case emptyPath(HTTPMethod)
    case lostPrefix(HTTPMethod)
}

// MARK: - NetworkManagerHeaders
enum NetworkManagerHeaders {
    case empty
    case required
    case additional([String : String])
    case value([String : String])
}

// MARK: - NetworkManagerParameters
enum NetworkManagerParameters {
    case empty
    case value([String : Any])
}

// MARK: - NetworkManagerRequest
struct NetworkManagerRequest {
    let type: HTTPMethod
    let path: String
    let headers: NetworkManagerHeaders
    let parameters: NetworkManagerParameters
    var encoding: URLEncoding?
    var queue: DispatchQueue?
}

// MARK: - NetworkManagerErrorType
enum NetworkManagerErrorType {
    case request(NSError)
    case system
}
