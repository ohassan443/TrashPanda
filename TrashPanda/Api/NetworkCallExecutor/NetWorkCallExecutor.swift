//
//  BaseNetworkCallExecutor.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

/// concrete implemntation of NetworkCallExecutorObj that handles executing api calls and parsing server response into data(Data)/statusCode(Int)/errorCode(String)/error(Error) , report network connectivity errors such as unavaliable network and weak or lossy internet connection
class NetWorkCallExecutor: NetworkCallExecutorProtocol {
    

    private var urlSession 						: UrlSessionWrapperProtocol
	private var reAuthenticationRetry				: ReAuthenticationRetryProtocol
	private var startInternetMonitoringNotificationName	: Notification.Name
    
    init(
		urlSessionWrapper : UrlSessionWrapperProtocol,
		reAuthenticationRetry : ReAuthenticationRetryProtocol,
		startInternetMonitoringNotificationName:Notification.Name) {
        self.urlSession = urlSessionWrapper
		self.reAuthenticationRetry = reAuthenticationRetry
		self.startInternetMonitoringNotificationName = startInternetMonitoringNotificationName
    }
    
    /**
     ececutes the api call and
    
     - Parameters:
       - callDetails: api call details object that includes url,body,rest method(get/post,...),parsing closure
       - completionHandler: call back to be executed with the parsed response
    */
    
	func execute(callDetails:ApiCallDetails,completionHandler : @escaping baseClassCompletionHandler) -> Void {

		DispatchQueue.global().async { [weak self] in
			guard let self = self else {return}

			if case AuthenticationState.ReAuthenticating = callDetails.authentication.state {
				completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.apiCallError(.currentlyReAuthenticating)), statusCode: nil, errorCode: nil))
				return
			}

			switch callDetails.authentication.state {
			case .useTokens:
				guard let tokens = callDetails.authentication.createTokens?() else {return}
				callDetails.update(headers: tokens)
				break
			case .ReAuthenticating:
				return
			case .noneRequired:
				break
			case .failedToReAuthenticate :
				completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.apiCallError(.loginRequired)), statusCode: nil, errorCode: nil))
				return
			}


			globalLastServiceCall = callDetails

			self.urlSession.makeRequest(callDetails: callDetails, completion: { result in





				let debugTempCall = callDetails



				switch result{

				case .fail(error: let translationError):
					switch translationError{
					case .serverConnectivity(let connectivityIssue):
						switch connectivityIssue{
						case .internet:
							completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.serverConnectivityIssue(.internet)), statusCode: nil, errorCode: nil))
							NotificationCenter.default.post(Notification(name: self.startInternetMonitoringNotificationName))
							return
						case.network:
							completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.serverConnectivityIssue(.network)), statusCode: nil, errorCode: nil))
							return
						}


					case .nilStatusCode:
						completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.apiCallError(.nilStatusCode)), statusCode: nil, errorCode: nil))
						return

					case .nilData :
						completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.apiCallError(.nilData)), statusCode: nil, errorCode: nil))
						return

					case .localError(let localError):
						completionHandler(ServerApiResponse.fail(error: localError, statusCode: nil, errorCode: nil))
					case .other(let otherError):
						let defaultErrorMessage = ApiMessages.Issues.somethingWentWrong.rawValue
						completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.apiCallError(.gerneralError(serverError:otherError , errorMsg: defaultErrorMessage))), statusCode: nil, errorCode: nil))

					}




				case .success(let successData):


					let errorCode = self.parseErrorCode(responseData: successData.data,action: callDetails.action)
					let errorMsg = self.parseServerErrorMsg(responseData: successData.data, action: callDetails.action, statusCode: successData.statusCode)


					switch successData.statusCode{
					case StatusCodes.success.rawValue :
						completionHandler(ServerApiResponse.success(ServerApiResponse.DataType.data(data: successData.data)))
						return

					case StatusCodes.failedAuthentication.rawValue :
						self.reAuthenticate(callDetails: callDetails, completionHandler: completionHandler)
						return

					default :
						completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.apiCallError(.gerneralError(serverError:nil ,errorMsg: errorMsg))), statusCode: successData.statusCode, errorCode: errorCode))
						return
					}
				}



			})
		}
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
        
        let errorMsg = jsonDic[ApiConstants.Keys.detailMessage.rawValue] as? String ?? defaultErrorMsg
        return errorMsg
        
    }

	fileprivate func reAuthenticate(callDetails: ApiCallDetails,completionHandler : @escaping baseClassCompletionHandler) {
		if case  .ReAuthenticating = callDetails.authentication.state {return}
		if case  .failedToReAuthenticate = callDetails.authentication.state {return}

		let preReAuthenticateState = callDetails.authentication.state
			callDetails.authentication.state = .ReAuthenticating
			self.reAuthenticationRetry.runReAuthentication(apiCall: callDetails, completion: {[weak self] result in
				guard let self = self else {return}
				switch result{
				case .ReExecute :
					callDetails.authentication.state = preReAuthenticateState
					self.execute(callDetails: callDetails, completionHandler: completionHandler)
				case .fail :
					callDetails.authentication.state = .failedToReAuthenticate
					completionHandler(ServerApiResponse.fail(error: ErrorBase.Api(.apiCallError(.expiredAuthToken)), statusCode: StatusCodes.failedAuthentication.rawValue, errorCode: nil))
				}
			})
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
