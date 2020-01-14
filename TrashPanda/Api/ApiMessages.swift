//
//  ApiMessages.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 12/20/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
class ApiMessages {
    
    enum Issues : String {
        
        case NoInternet                             = "Please check you Internet connection and try again"
        
        case UnIdentified                           = "UnIdentified Error"
        
        case networkNotReachAble                    = "Network not reachable"
        
        case networkReachableButNoInternet          = "Internet not reachable"
        
        case failedParsingApiData                   = "Failed to parse server data"
        
        case nilServerResponse                      = "NUll Server Response"
        
        case somethingWentWrong                     = "something went wrong"
        
        case loginRequired                          = "Login is required"
        
        case nilServerData                          = "Invalid server response"
        
        case nilStatusCode                          = "Invalid server code"
        
        case DecodingError                          = "Decoding Error"
        
        case invalidRootKey                         = "Parsing error : invalid root key"
        
        case parsingError                           = "Parsing error : invalid key"
        
        case parsingCorruptedData                   = "Parsing error : corrupted data"
        
        case parsingTypeMishMatch                   = "Parsing error : type mismatch"
        
        case invalidDecodingKeys                    = "Parsing error : invalid decoding keys"
        
        case nonOptionalValueNotFound               = "Parsing error : non optional value not found"
        
        case sessionExpiredPleaseLogin              = "Session expired please login"
        
        case invalidUrl                             = "Bad request"
        
        case bodyEncoding                           = "Encoding failed"
        
        case serverCommunicationError               = "Server Communication Error"
    }
}
