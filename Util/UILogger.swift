//
//  UILogger.swift
//  QiscusUI
//
//  Created by Qiscus on 17/09/18.
//

import Foundation

class UILogger {
    static func debugPrint(_ text: String) {
        if QiscusUI.enableDebugPrint {
            print("[QiscusCore] \(text)")
        }
    }
    
    static func errorPrint(_ text: String) {
        if QiscusUI.enableDebugPrint {
            print("[QiscusCore] Error: \(text)")
        }
    }
    
    static func networkLogger(request: URLRequest) {
        if !QiscusUI.enableDebugPrint {
            return
        }
        
        print("\n ====================> REQUEST <============ \n")
        defer { print("\n ====================> END REQUEST <============ \n") }
        
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)
        
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"
        
        var logOutput = """
        \(urlAsString) \n\n
        \(method) \(path)?\(query) HTTP/1.1 \n
        HOST: \(host)\n
        """
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            logOutput += "\(key): \(value) \n"
        }
        if let body = request.httpBody {
            logOutput += "\n \(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
        }
        
        print(logOutput)
    }
    
    static func networkLogger(request: URLRequest, response: Data?) {
        if !QiscusUI.enableDebugPrint {
            return
        }
        
        print("\n ====================> RESPONSE <============ \n")
        defer { print("\n ====================> END RESPONSE <============ \n") }
        
        let urlAsString = request.url?.absoluteString ?? ""
        var responseMessage = ""
        if let responseData = response {
            responseMessage = responseData.toJsonString()
        }
        let logOutput = """
        URL: \(urlAsString) \n
        Response: \(responseMessage)
        """
        print(logOutput)
    }
}

extension Data {
    func toJsonString() -> String {
        guard let jsonString = String(data: self, encoding: .utf8) else {return "invalid json data"}
        
        return jsonString
    }
}

