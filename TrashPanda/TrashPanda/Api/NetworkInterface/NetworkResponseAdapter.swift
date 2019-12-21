//
//  NetworkResponseAdapter.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation




class NetworkResponseAdapter {
    
    
    ///   relayes the NetWorkCallExecutor response to the vc Controller the requested the call after trying the parsing closure and if server call fails or parsing fails, then returns appropriate error message
    ///     - in case of success tries parsing the response data to the expected type and if this fails matches the appropriate error msg to the thrown DecodingError or custom Decoding errors @ ErrorBase.Api.ParsingError
    ///     - in case of failure from the server checks wether that api call has specific messages to override server error messages for certain ( errorCode & statusCode ) and if not then returns the server error message
    ///
    /// - Parameters:
    ///   - callDetails: app api call
    ///   - response: server response
    ///   - successHandler: the success handler to be executed after successfully parsing the server data to the type associated with api call
    ///   - failHandler: call back to execute in case the server returned an error or the the server returned Data but the parsing of the data didnot succeed
    func relayResponseToVc<T>(callDetails:BaseApiCall<T>,
                              response:ServerApiResponse,
                              successHandler: @escaping successHandlerResponse<T>,
                              failHandler:failHandlerResponse){
        
        
        switch response {
        case .success(data: let data) :
            
            switch data {
            case .data(data: let serverData) :
                
                let result      = callDetails.parsing(serverData)
                let json        = Parser().parseRequestResponseJson(responseData: serverData)
                let detail      = json?[ApiConstants.Keys.errorMsg.rawValue] as? String
                let errorCode   = json?[ApiConstants.Keys.errorCode.rawValue] as? String
                
                
                
                switch result {
                case .success(let parsedResponse):
                    successHandler(parsedResponse,ServerDetailResponse(detail: detail, code: errorCode))
                    
                case .fail(let parsingError):
                    failHandler(ServerFailResponseObject(statusCode: 200, userRepresentableMessage: ApiMessages.Issues.failedParsingApiData.rawValue, serverErrorCode: errorCode, error: ErrorBase.Api(ApiError.parsing(parsingError))))
                }
                
            // this case is used for mocking with objects and has no use for concrete server calls
            case .any(any: let stubResponse ) :
                successHandler(stubResponse as! T, ServerDetailResponse(detail: nil, code: nil))
            }
            
        case .fail( let error,let statusCode,let errorCode) :
            
            if let statusCode = statusCode , let errorCode = errorCode {
                let specialMessage = callDetails.call.errorMsgfor(statusCode: statusCode, serverErrorCode: errorCode)
                failHandler(ServerFailResponseObject(statusCode: statusCode, userRepresentableMessage: specialMessage ?? error.userRespresentableMessage, serverErrorCode: errorCode, error: error))
                return
            }
            
            failHandler(ServerFailResponseObject(statusCode: statusCode, userRepresentableMessage: error.userRespresentableMessage, serverErrorCode: errorCode, error: error))
            
        }
        
        
    }
}
