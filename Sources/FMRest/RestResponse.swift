
import Foundation

extension FMRest {
    
    public struct Response<T: Decodable>: Decodable {
        
        public var authToken: String?
        public let response: T?
        public let messages: [Message]
        
        public init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.messages = try container.decode([Message].self, forKey: .messages)
            self.response = try container.decodeIfPresent(T.self, forKey: .response)
            
        }
        
        public enum CodingKeys: String, CodingKey {
            
            case response
            case messages
            case plugins
            case result
            
        }
        
    }
    
    public struct EmptyResponse: Decodable {
        
        public let empty: String?
        
    }
    
    public struct Message: Decodable {
        
        public let code: Int
        public let text: String
        
        public init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let codeString = try container.decode(String.self, forKey: .code)
            code = Int(codeString)!
            if let fmMessage = try container.decodeIfPresent(String.self, forKey: .text) {
                text = fmMessage
            } else if let fmMessage = try container.decodeIfPresent(String.self, forKey: .message) {
                text = fmMessage
            } else {
                text = ""
            }
            
        }
        
        enum CodingKeys: String, CodingKey {
            
            case code
            case message
            case text
            
        }
        
    }
    
    public struct MessageResponse: Decodable {
        
        public let messages: [Message]
        
    }
    
}
