//
//  ReAuthenticationFunctions.swift
//  TrashPanda
//
//  Created by Omar Hassan  on 1/11/20.
//  Copyright © 2020 Omar Hassan. All rights reserved.
//

import Foundation

public struct Tokens {
    var auth : String
    var refresh: String
}

func refreshToken(call:RefreshTokenCall,completion: @escaping (Result<Data,ReAuthenticationError>)->()) -> Void {
    DispatchQueue.global(qos: .default).async {
        
        var request = URLRequest(url: URL(string: call.url)! as URL)
        request.httpBody = try? JSONSerialization.data(withJSONObject: call.body, options: [])
        request.httpMethod = call.method.rawValue
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        config.httpAdditionalHeaders = call.headers
        let session = URLSession(configuration: config)
        
        
        session.dataTask(with: request){data,response,error in
            let translator = ServerCallErrorTranslator(error: error as NSError?, data: data, statusCode:( response as? HTTPURLResponse )?.statusCode)
            
            switch translator.translate(){
            case .fail(error: let apiError):
				switch apiError {
				case .nilData,.nilStatusCode,.other(_),.localError(_) : completion(.failure(.reAuthenticationFailed))
				case .serverConnectivity(_)  : completion(.failure(.connectionError))
			}

            case .success(let success):
                
				if success.statusCode == 400 {
					completion(.failure(.expiredRefreshToken))
                    return
                }
                
                guard success.statusCode == 200 else {
					completion(.failure(.reAuthenticationFailed))
                    return
                }
                

				completion(.success(success.data))
            }
        }.resume()
    }
}

