
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
    
    public struct ServerOptions {
        
        public var printDebug: PrintSet
        
        public init(printDebug: PrintSet = PrintSet()) {
            self.printDebug = printDebug
        }
        
        public struct PrintSet {
            public var publisherReceiveSubscription: DebugEvent
            public var publisherReceiveOutput: DebugEvent
            public var publisherReceiveCompletion: DebugEvent
            public var publisherReceiveCancel: DebugEvent
            public var publisherReceiveRequest: DebugEvent
            public var requestHeader: DebugEvent
            public var requestBody: DebugEvent
            public var requestURL: DebugEvent
            public var requestMethod: DebugEvent
            public var request: DebugEvent
            
            
            public init(
                publisherReceiveSubscription: DebugEvent = .none,
                publisherReceiveOutput: DebugEvent = .none,
                publisherReceiveCompletion: DebugEvent = .none,
                publisherReceiveCancel: DebugEvent = .none,
                publisherReceiveRequest: DebugEvent = .none,
                requestHeader: DebugEvent = .none,
                requestURL: DebugEvent = .none,
                requestBody: DebugEvent = .none,
                requestMethod: DebugEvent = .none,
                request: DebugEvent = .none
            ) {
                self.publisherReceiveSubscription = publisherReceiveSubscription
                self.publisherReceiveOutput = publisherReceiveOutput
                self.publisherReceiveCompletion = publisherReceiveCompletion
                self.publisherReceiveCancel = publisherReceiveCancel
                self.publisherReceiveRequest = publisherReceiveRequest
                self.requestHeader = requestHeader
                self.requestBody = requestBody
                self.requestURL = requestURL
                self.requestMethod = requestMethod
                self.request = request
            }
            
        }
        
        public enum DebugEvent: Hashable {
            case print(_ label: String?)
            case none
            
        }
        
    }
    
}
