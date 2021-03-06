
import Foundation
import Combine

public enum FMRest {
    
    public struct Agent {
        
        public static func run<T: Decodable>(_ request : URLRequest, config: FMRestConfig) -> AnyPublisher<Response<T>, APIError> {
            printDebugRequest(request: request, options: config.options)
            var token: String?
            return URLSession.shared.dataTaskPublisher(for: request)
                .printForDebugging(config.options)
                .mapError { error -> APIError in
                    APIError.requestError(error: error)
                }
                .tryMap { result -> Data in
                    guard let response = result.response as? HTTPURLResponse else {
                        throw APIError.responseError(message: "response was not HTTPURLResponse")
                    }
                    switch response.statusCode {
                    case 200:
                        // if there is ever a header with a token it gets saved and added to the package downstream
                        if let responseToken = response.value(forHTTPHeaderField: "X-FM-Access-Token") {
                            token = responseToken
                        }
                        if let responseToken = response.value(forHTTPHeaderField: "X-FM-Data-Access-Token") {
                            token = responseToken
                        }
                        return result.data
                    default:
                        if result.data.isEmpty {
                            throw AgentError.status(code: response.statusCode)
                        } else {
                            throw AgentError.loaded(code: response.statusCode, data: result.data)
                        }
                    }
                }
                .mapError{ error -> APIError in
                    switch error {
                    case AgentError.status(code: let status):
                        switch status {
                        case 400:
                            return APIError.badRequest
                        case 401:
                            return APIError.unauthorized(code: 401, text: "Unauthorized")
                        case 403:
                            return APIError.forbidden
                        case 404:
                            return APIError.notFound
                        case 405:
                            return APIError.methodNotAllowed
                        case 415:
                            return APIError.unsupported
                        case 500:
                            return APIError.serverError
                        default:
                            return APIError.status(code: status)
                        }
                    case AgentError.loaded(code: let status, data: let data):
                        do {
                            let messages = try JSONDecoder().decode(MessageResponse.self, from: data)
                            return APIError.fileMakerError(code: status, messages: messages)
                        } catch {
                            return APIError.decodingError(error: error)
                        }
                    default:
                        if let nError = error as? APIError {
                            return nError
                        } else {
                            return APIError.unknown(error: error)
                        }
                    }
                }
                .decode(type: Response<T>.self, decoder: config.decoder)
                .mapError {
                    $0 as? APIError ?? APIError.decodingError(error: $0)
                }
                .map {
                    var package = $0
                    if let responseToken = token {
                        package.authToken = responseToken
                    }
                    return package
                }
                .eraseToAnyPublisher()
            
        }

    }
    
    static func printDebugRequest(request: URLRequest, options: ServerOptions) {
        
        if case .print(let label) = options.printDebug.request {
            print("\(label ?? "") \(request)")
        }
        
        if case .print(let label) = options.printDebug.requestMethod {
            print("\(label ?? "") \(request.httpMethod ?? "None")")
        }
        
        if case .print(let label) = options.printDebug.requestURL {
            print("\(label ?? "") \(request.url?.absoluteString ?? "None")")
        }
        
        if case .print(let label) = options.printDebug.requestBody {
            if let data = request.httpBody {
                print("\(label ?? "") \(String(decoding: data, as: UTF8.self))")
            } else {
                print("\(label ?? "") no body")
            }
        }
        
        if case .print(let label) = options.printDebug.requestHeader {
            if let headers = request.allHTTPHeaderFields {
                print("\(label ?? "") \(headers)")
            }
        }
        
    }

}
