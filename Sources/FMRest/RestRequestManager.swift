
import Foundation

extension FMRest {
    
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case patch = "PATCH"
        case put = "PUT"
    }
    
    public struct Header {
        let value: String
        let field: String
        
        public init(value: String, field: String) {
            self.value = value
            self.field = field
        }
    }
    
    private enum DataType {
        case json(data: Data)
        case container(data: ContainerFile)
        case nothing
    }
    
    public struct ContainerFile {
        
        public let fileName: String
        public let mimeType: String
        public let data: Data
        
        public init(fileName: String, mimeType: String, data: Data) {
            self.fileName = fileName
            self.mimeType = mimeType
            self.data = data
        }
         
    }
    
    public static func createRequest(
        credentials: FMRestCredentials,
        host: String,
        config: FMRestConfig,
        method: HTTPMethod,
        endpoint: EndpointPath,
        queryParameters: [URLQueryItem] = [],
        data: ContainerFile
    ) -> URLRequest {
        self.createRequest(credentials: credentials, host: host, config: config, method: method, endpoint: endpoint, queryParameters: queryParameters, data: .container(data: data))
    }
    
    public static func createRequest(
        credentials: FMRestCredentials,
        host: String,
        config: FMRestConfig,
        method: HTTPMethod,
        endpoint: EndpointPath,
        queryParameters: [URLQueryItem] = []
    ) -> URLRequest {
        self.createRequest(credentials: credentials, host: host, config: config, method: method, endpoint: endpoint, queryParameters: queryParameters, data: .nothing)
    }
    
    public static func createRequest<T: Encodable>(
        credentials: FMRestCredentials,
        host: String,
        config: FMRestConfig,
        method: HTTPMethod,
        endpoint: EndpointPath,
        queryParameters: [URLQueryItem] = [],
        data: T
    ) throws -> URLRequest {
        let jsonData: Data
        do {
            jsonData = try config.encoder.encode(data)
            return self.createRequest(credentials: credentials, host: host, config: config, method: method, endpoint: endpoint, queryParameters: queryParameters, data: .json(data: jsonData))
        } catch {
            throw FMRest.APIError.encodingError(error: error)
        }
    }
    
    
    private static func createRequest(
        credentials: FMRestCredentials,
        host: String,
        config: FMRestConfig,
        method: HTTPMethod,
        endpoint: EndpointPath,
        queryParameters: [URLQueryItem],
        data: DataType
    ) -> URLRequest {
        let urlComponents = createURLComponents(
            scheme: config.scheme,
            host: host,
            rootPath: config.rootPath,
            version: config.version,
            path: endpoint.path,
            queryParameters: queryParameters
        )
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = method.rawValue
        switch data {
        case .json(data: let data):
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        case .container(data: let container):
            print("container data --------")
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = convertFileData(fileName: container.fileName, mimeType: container.mimeType, fileData: container.data, using: boundary)
        case .nothing:
            break
        }
        credentials.headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.field)
        }
        return request
    }
    
    static func createURLComponents(
        scheme: String,
        host: String,
        rootPath: String,
        version: String,
        path: String,
        queryParameters: [URLQueryItem]?
    ) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "\(rootPath)\(version)\(path)"
        if let queryParams = queryParameters {
            if queryParams.count > 0 {
                urlComponents.queryItems = queryParams
            }
        }
        return urlComponents
    }
    
    private static func convertFileData(fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"upload\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        data.appendString("--\(boundary)--")
        return data as Data
    }
    
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

