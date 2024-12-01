//
//  NetworkHelper.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation

class NetworkHelper {
    static let shared = NetworkHelper()
    
    private init() {}

    func executeRequest(_ request: URLRequest, completion: @escaping (String?) -> Void) {
       
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10
        sessionConfig.timeoutIntervalForResource = 10
        let session = URLSession(configuration: sessionConfig)

        // Perform the request with the custom session
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            if let jsonStr = String(data: data, encoding: .utf8) {
                let responseHandler = OpenAIResponseHandler()
                if let responseText = responseHandler.decodeJson(jsonString: jsonStr)?.choices.first?.message.content {
                    DispatchQueue.main.async {
                        completion(responseText)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
