//
//  OllamaAPI.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import Alamofire
import Foundation

enum OllamaAPI {
    case root
    case models
    case generate(message: Message)
    
    var baseURL: URL {
        URL(string: "http://localhost:11434")!
    }
    
    var path: String {
        switch self {
        case .root:
            return "/"
        case .models:
            return "/api/tags"
        case .generate:
            return "/api/generate"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .root:
            return .get
        case .models:
            return .get
        case .generate:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .generate(let message):
            return message.asParameters()
        default:
            return nil
        }
    }
}

extension OllamaAPI: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        
        var request = URLRequest(url: url)
        request.method = method
        
        switch self {
        case .generate:
            request = try JSONEncoding.default.encode(request, with: parameters)
        default:
            break
        }
        
        return request
    }
}
