//
//  BaseNetworkCallExecutor.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation



var delay : DispatchTime = DispatchTime.now() + 3

/// concrete implemntation of NetworkCallExecutorObj that handles executing api calls and parsing server response into data(Data)/statusCode(Int)/errorCode(String)/error(Error) , report network connectivity errors such as unavaliable network and weak or lossy internet connection
class NetWorkCallExecutor: NetworkCallExecutorProtocol {
    
    
    
    private var headersFactory : HeadersFactoryProtocol
    private var urlSession : UrlSessionWrapperProtocol
    
    init(headersFactory:HeadersFactoryProtocol,urlSessionWrapper : UrlSessionWrapperProtocol) {
        self.headersFactory = headersFactory
        self.urlSession = urlSessionWrapper
    }
    
    /**
     ececutes the api call and 
    
     - Parameters:
       - callDetails: api call details object that includes url,body,rest method(get/post,...),parsing closure
       - completionHandler: call back to be executed with the parsed response
    */
    
    func execute(callDetails:ApiCallDetails,completionHandler : @escaping baseClassCompletionHandler) -> Void {
        
        
        let headers = headersFactory.createServiceHeaders(authentication: callDetails.getAuthenticationType)
        switch  headers {
        case .headers(let headers) :
            callDetails.set(headers: headers) 
        case .failedToFindAuthToken :
            completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.apiCallError(.loginRequired)), statusCode: nil, errorCode: nil))
            return
        }
        
        globalLastServiceCall = callDetails
        
        urlSession.makeRequest(callDetails: callDetails, completion: { result in
            switch result {
            case .localError(let errorBase) :
                completionHandler(ServerApiResponse.fail(error: errorBase, statusCode: nil, errorCode: nil))
            case .remoteResponse (let data,let response , let error):
                
                DispatchQueue.main.async {
                    
                    
                    let debugTempCall = callDetails
                    
                    let statusCode = ( response as? HTTPURLResponse )?.statusCode  ?? 500
                    let errorCode = self.parseErrorCode(responseData: data,action: callDetails.getAction)
                    
                    let errorMsg = self.parseServerErrorMsg(responseData: data, action: callDetails.getAction, statusCode: statusCode )
                    
                    switch (error,statusCode) {
                    case (.some(let serverError) ,_) :
                        
                        if internetErrors.contains( (serverError as NSError).code ) {
                            completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.serverConnectivityIssue(.internet)), statusCode: statusCode, errorCode: errorCode))
                            return
                        }
                        
                        
                        if networkErrors.contains( (serverError as NSError).code ) {
                            completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.serverConnectivityIssue(.network)), statusCode: statusCode, errorCode: errorCode))
                            return
                        }
                        
                        
                    case (nil,200) :
                        if let data = data {
                            completionHandler(ServerApiResponse.success(ServerApiResponse.DataType.data(data: data)))
                            return
                        }else {
                            completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.apiCallError(.nilData)), statusCode: statusCode, errorCode: errorCode))
                        }
                        
                    case (nil,401) :
                        completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.apiCallError(.authorizationRevoked)), statusCode: statusCode, errorCode: errorCode))
                        return
                    case (nil,500) :
                        completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.apiCallError(.gerneralError(statusCode: statusCode, errorCode: errorCode, errorMsg: errorMsg))), statusCode: statusCode, errorCode: errorCode))
                        return
                    default :
                        completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.apiCallError(.gerneralError(statusCode: statusCode, errorCode: errorCode, errorMsg: errorMsg))), statusCode: statusCode, errorCode: errorCode))
                        return
                    }
                }
                
            }
        })
    }
    
    
    
    
     /// parses error code in server response , this error code is optional and its meaning is api specific (depends on each api)
     /// login operation has no error code
     ///
     /// - Parameters:
     ///   - responseData: server response
     ///   - action: api type (login,register,getUserDetails,....etc)
     /// - Returns: optional string error code
     func parseErrorCode(responseData:Data?,action:ActionType) -> String? {
//        if case ActionType.user(let userAction) = action , case UserActions.login = userAction {
//            return nil
//        }
        
        
        
        let jsonDic = Parser().parseRequestResponseJson(responseData: responseData)
        let errorCode = jsonDic?[ApiConstants.Keys.errorCode.rawValue] as? String
        return errorCode
    }
    
    
     /// parse server error msg
     ///
     /// - Parameters:
     ///   - responseData: server respnse
     ///   - action: action type to check if api is login
     ///   - statusCode: server response status code
     /// - Returns: returns the server error message , but unAuthorized login message is overridden to a local message
     func parseServerErrorMsg(responseData:Data?,action:ActionType,statusCode:Int)-> String{
        let defaultErrorMsg = ApiMessages.Issues.somethingWentWrong.rawValue
        
        guard let jsonDic = Parser().parseRequestResponseJson(responseData: responseData) else {return defaultErrorMsg}
        
        let errorMsg = jsonDic[ApiConstants.Keys.errorMsg.rawValue] as? String ?? defaultErrorMsg
        return errorMsg
        
    }
    
    
    
}


 let networkErrors = [
    URLError.timedOut.rawValue
    ,URLError.cannotConnectToHost.rawValue
    ,URLError.cannotLoadFromNetwork.rawValue
    ,URLError.networkConnectionLost.rawValue
    ,URLError.callIsActive.rawValue
]
let internetErrors = [
    URLError.internationalRoamingOff.rawValue
    ,URLError.notConnectedToInternet.rawValue
]
