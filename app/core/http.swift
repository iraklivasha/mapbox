//
//  http.swift
//  app
//
//  Created by Irakli Vashakidze on 12.04.22.
//

import Alamofire
import Foundation

fileprivate struct HttpConsts {
    static let uploadTimeout: TimeInterval                  = 3600 * 24 // 1 day
    static let requestTimeout: TimeInterval                 = 60        // 60 seconds
    static let waitUntilNextRetrySecs: TimeInterval         = 900       // 15 minutes
    static let notifyIntervalSec                            = 0.1
    static let maxHttpRequests                              = 20
}

protocol CIErrorProtocol: Error {
    var code: Int { get }
    var message: String { get }
    var nsError: NSError { get }
    var userInfo: [String: Any]? { get }
}

struct MessageSendFailedError: CIErrorProtocol {
    
    private let error: NSError
    
    init(error: NSError) {
        self.error = error
    }
    
    var code: Int {
        return self.error.code
    }
    
    var nsError: NSError {
        return error
    }
    
    var userInfo: [String : Any]? {
        self.error.userInfo
    }
    
    var message: String {
        return self.error.localizedDescription
    }
}

enum CIError: Error, CIErrorProtocol {

    case unknown
    case notfound
    case forbidden
    case server
    case uploadFailed
    case userCancelled
    case unauthorized
    case invalidContent
    case missingLocation
    case sparkReceiverNotFound
    case sparkBalance
    case invalidChannelOperation
    case channelShareFailed
    
    init(rawValue: Int) {
        self = CIError.error(from: rawValue)
    }
    
    private static func error(from code: Int) -> CIError {
        switch code {
        case CIError.notfound.code: return CIError.notfound
        case CIError.forbidden.code: return CIError.forbidden
        case CIError.server.code: return CIError.server
        case CIError.userCancelled.code: return CIError.userCancelled
        case CIError.unauthorized.code: return CIError.unauthorized
        case CIError.invalidContent.code: return CIError.invalidContent
        case CIError.missingLocation.code: return CIError.missingLocation
        case CIError.uploadFailed.code: return CIError.uploadFailed
        case CIError.sparkReceiverNotFound.code: return CIError.sparkReceiverNotFound
        case CIError.invalidChannelOperation.code: return CIError.invalidChannelOperation
        case CIError.channelShareFailed.code: return CIError.channelShareFailed
        case CIError.sparkBalance.code: return CIError.sparkBalance
        default: return CIError.unknown
        }
    }
    
    var message: String {
        switch self {
        case .unknown:          return "General error occured"
        case .notfound:         return "Resource not found"
        case .forbidden:        return "Upload failed, please try again or contact support"
        case .server:           return "Server error"
        case .userCancelled:    return "Operation cancelled"
        case .unauthorized:     return "Unauthorized"
        case .invalidContent:     return "Invalid content"
        case .missingLocation:   return "Please tell us where you are ..."
        case .uploadFailed:     return "Upload failed"
        case .sparkReceiverNotFound:   return "Specify distance !"
        case .invalidChannelOperation: return "Invalid channel operation."
        case .channelShareFailed: return "Channel has not been shared yet."
        case .sparkBalance: return "You daily sparks limit exceeded."
        }
    }

    var code: Int {
        switch self {
        case .unknown:          return 1000
        case .notfound:         return 400
        case .forbidden:        return 403
        case .server:           return 500
        case .userCancelled:    return 999
        case .unauthorized:     return 401
        case .invalidContent:   return 998
        case .missingLocation:   return 1001
        case .uploadFailed:   return 1002
        case .sparkReceiverNotFound: return 1003
        case .sparkBalance: return 1004
        case .invalidChannelOperation: return 2001
        case .channelShareFailed: return 2002
        }
    }

    var userInfo: [String: Any]? {
        return ["code": code, "description": message]
    }
    
    var nsError: NSError {
        return NSError(domain: "com.demo.app", code: code, userInfo: userInfo)
    }
}

extension Error {
    var message: String {
        return (self as? CIError)?.message ?? ""
    }
    
    var code: Int {
        return (self as? CIError)?.code ?? 0
    }
    
    func isCIError(_ e: CIError) -> Bool {
        return (self as? CIError) == e
    }
}

struct HttpCode {
    static let forbidden    = 403
    static let notfound     = 404
    static let server       = 500
    static let unauthorized = 401
}

enum CIHttpMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"

    var alamofireConverted : HTTPMethod {
        return HTTPMethod(rawValue: self.rawValue)
    }
}

/// Main interface for Http request manager
protocol HttpAPI: AnyObject {
    func send(for url: URL,
              method: CIHttpMethod,
              params: [String : Any]?,
              headers: [String : String]?,
              completion: @escaping (Swift.Result<Data?, Error>) -> Void)
}

/// Implements HttpRequestManager interface and is responsible for sending http requests,
/// uploads files and provides completions callbacks
final class HttpAPIImpl : NSObject, HttpAPI {

    private var sessionManager: Alamofire.Session!
    private var backgroundSessionManager: Alamofire.Session!
    private lazy var uploadRequests = [String : DataRequest]()

    override init() {
        super.init()
        self.configureDefaultSessionManager()
    }

    // MARK: - Configuration

    private func configureDefaultSessionManager() {
        let defaultConfiguration = URLSessionConfiguration.default
        defaultConfiguration.timeoutIntervalForRequest = HttpConsts.requestTimeout
        defaultConfiguration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        defaultConfiguration.httpMaximumConnectionsPerHost = HttpConsts.maxHttpRequests
        self.sessionManager = Alamofire.Session(configuration: defaultConfiguration)
    }

    // MARK: - API

    /// Sends http request to the specified `url` with `method`, `parameters` and `headers`
    ///
    /// - parameter url:        The URL.
    /// - parameter method:     The HTTP method.
    /// - parameter parameters: The parameters.
    /// - parameter headers:    The HTTP headers.
    ///
    /// - returns: Void.
    func send(for url: URL,
              method: CIHttpMethod,
              params: [String : Any]?,
              headers: [String : String]?,
              completion: @escaping (Swift.Result<Data?, Error>) -> Void) {

        self.createRequest(for: url, method: method, params: params, headers: headers).validate().responseData {[weak self] response in

            if let e = response.error {
                self?.handleError(error: e,
                                  request: response.request,
                                  response: response.response,
                                  completion: completion)
            } else {
                completion(.success(response.data))
            }
        }
    }

    // MARK: - Helper funcs - request send, pending requests, uploads, callbacks

    /// Creates Alamofire DataRequest object
    ///
    /// - parameter url:        The URL.
    /// - parameter method:     The HTTP method.
    /// - parameter parameters: The parameters.
    /// - parameter headers:    The HTTP headers.
    ///
    /// - returns: DataRequest.
    private func createRequest(for url: URL, method: CIHttpMethod, params: [String : Any]? = nil, headers: [String : String]? = nil) -> DataRequest {

        var _headers = ["Content-Type":"application/json"]
        headers?.forEach({ kv in
            _headers[kv.key] = kv.value
        })
        
        return self.sessionManager.request(url,
                                           method: method.alamofireConverted,
                                           parameters: params,
                                           encoding: URLEncoding(),
                                           headers: HTTPHeaders(_headers))
    }

    // MARK: - Error handling

    private func handleError(id: String? = nil,
                            error: Error,
                            request:URLRequest? = nil,
                            response: HTTPURLResponse? = nil,
                            completion: @escaping (Swift.Result<Data?, Error>) -> Void) {

        if (error as NSError).code == NSURLErrorCancelled { // Cancelled
            completion(.failure(CIError.userCancelled))
            return
        }

        if let err = self.error(from: response) {
            completion(.failure(err))
            return
        }

        if let e = error as? CIError {
            completion(.failure(e))
            return
        }

        completion(.failure(CIError.unknown))
    }

    private func debugMessage(_ type: CIError, _ error: Error, _ request: URLRequest? = nil) -> String {
        var requestStr = ""
        if let req = request?.description { requestStr = "\nRequest: \(req)" }

        return "Error type - \(type): \(type.code), \nError: \(error)\(requestStr)"
    }

    private func error(from response: HTTPURLResponse?) -> CIError? {

        guard let httpResponse = response else { return nil }
        
        switch httpResponse.statusCode {
        case HttpCode.forbidden: return .forbidden
        case HttpCode.notfound: return .notfound
        case HttpCode.server: return .server
        case HttpCode.unauthorized: return .unauthorized
        default:  return .unknown
        }
    }
}
