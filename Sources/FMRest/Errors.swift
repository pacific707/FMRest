
import Foundation

extension FMRest {
 
    public enum APIError: Error {
        case requestError(error: Error)
        case responseError(message: String)
        case fileMakerError(code: Int, messages: MessageResponse)
        case status(code: Int)
        case decodingError(error: Error)
        case serverError
        case badRequest
        case apiError(message: String)
        case unauthorized(code: Int, text: String)
        case forbidden
        case methodNotAllowed
        case notFound
        case authTypeError(message: String)
        case unsupported
        case unknown(error: Error)
        case encodingError(error: Error)
    }
    
}

extension FMRest.Agent {
    
    public enum AgentError: Error {
        case loaded(code: Int, data: Data)
        case status(code: Int)
    }

}
