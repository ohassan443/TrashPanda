//
//  ServerCallErrorTranslator.swift
//  TrashPanda
//
//  Created by Omar Hassan  on 1/11/20.
//  Copyright © 2020 Omar Hassan. All rights reserved.
//

import Foundation
struct ServerCallErrorTranslator {

	struct successData {
		var statusCode	: Int
		var data 		: Data
	}

    enum Translation {
        case success(successData)
        case fail (error:TranslationError)
    }
	enum TranslationError {
		case serverConnectivity(ServerConnectivityIssue)
		case nilData
		case nilStatusCode
		case localError(ErrorBase)
		case other(NSError)
	}
    
    
    private (set) var error : NSError?
    private (set) var data : Data?
    private (set) var statusCode : Int?
    
    
    
    func translate() -> Translation {
		if let error = error {
			guard !networkErrors.contains(error.code) else {
				return .fail(error: .serverConnectivity(.network))
			}
			guard !internetErrors.contains(error.code) else {
				return .fail(error: .serverConnectivity(.internet))
			}
			return .fail(error: .other(error))
		}

		guard let statusCode = statusCode else {
            return .fail(error: .nilStatusCode)
        }
        guard let data = data else{
            return .fail(error: .nilData)
        }
        

        
        return .success(successData(statusCode: statusCode, data: data))

    }
}
