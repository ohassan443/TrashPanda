//
//  AppError.swift
//  Omar Hassan
//
//  Created by omarHassan on 4/11/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

protocol UserRespresentableError {
	var userRespresentableMessage : String {get}
}



public enum ParsingResult<T>{
	case success(T)
	case fail(ParsingError)
}


public enum ErrorBase : UserRespresentableError, Error {
	
	
	case Api(ApiError)
	case UI (UIError)
	case none
	
	var userRespresentableMessage: String {
		switch self {
		case .Api(let apiError):
			return apiError.userRespresentableMessage
		case .UI(let uiError) :
			return uiError.userRespresentableMessage
		case .none :
			return ""
		}
	}
	
}

public enum ApiError : UserRespresentableError {
	case parsing(ParsingError)
	case serverConnectivityIssue(ServerConnectivityIssue)
	case apiCallError(ApiCallError)
	case reAuthenticate(ReAuthenticationError)
	
	var userRespresentableMessage: String {
		switch self {
		case .parsing(let parsingError):
			return parsingError.userRespresentableMessage
		case .serverConnectivityIssue(let connectivityError) :
			return connectivityError.userRespresentableMessage
		case .apiCallError(let apiCallError):
			return apiCallError.userRespresentableMessage
		case .reAuthenticate(let reAuthenticationError) :
			return reAuthenticationError.userRespresentableMessage
		}
	}
	
}





// MARK: - Api Errors
public enum ParsingError : Error ,LocalizedError, UserRespresentableError{
	case decodingError(error:DecodingError,keys:[String])
	case keysNotAvaliable(keys:[String])
	case invalidRootDataKey(key:String)
	case valueNotFound(attemptedType:String)
	case undefined
	
	var userRespresentableMessage: String {
		return ApiMessages.Issues.DecodingError.rawValue
	}
	
	public var errorDescription: String? {
		
		switch self{
		case .decodingError(let error ,let keys) :
			return " parsingError / decodingError / \(error) / keys = \(keys)"
		case .keysNotAvaliable(let keys):
			return " parsingError / keysNotAvaliable / \(keys)"
		case .invalidRootDataKey(let key):
			return " parsingError / invalidRootDataKey / \(key)"
		case .valueNotFound(attemptedType: let attemptedType):
			return " parsingError / valueNotFound for attempted Type / \(attemptedType)"
		case .undefined:
			return " parsingError / undefined / )"
		}
	}
}


public enum ServerConnectivityIssue : Error,LocalizedError,UserRespresentableError{
	case network
	case internet
	
	var userRespresentableMessage: String {
		switch self{
		case .network :  return  ApiMessages.Issues.networkNotReachAble.rawValue
		case .internet : return  ApiMessages.Issues.NoInternet.rawValue
		}
	}
	
	
	public var errorDescription: String? {
		switch self{
		case .network :  return " ServerConnectivityIssue / network "
		case .internet : return " ServerConnectivityIssue / internet "
		}
	}
}


public enum ReAuthenticationError : Error,LocalizedError,UserRespresentableError {
	
	case expiredRefreshToken
	case reAuthenticationFailed
	case connectionError
	
	
	var userRespresentableMessage : String {
		
		switch self {
		case .expiredRefreshToken						: return  ApiMessages.Issues.sessionExpiredPleaseLogin.rawValue
		case .reAuthenticationFailed					: return  ApiMessages.Issues.sessionExpiredPleaseLogin.rawValue
		case .connectionError						: return  ApiMessages.Issues.UnIdentified.rawValue
		}
	}
	
	
	public var errorDescription: String? {
		
		switch self{
		case .expiredRefreshToken :
			return "ReAuthenticationError / expiredRefreshToken "
		case .reAuthenticationFailed:
			return "ReAuthenticationError /  reAuthenticationFailed"
		case .connectionError:
			return "ReAuthenticationError / connectionError "
		}
	}
	
}



public enum ApiCallError : Error,LocalizedError,UserRespresentableError{
	case nilData
	case nilStatusCode
	case loginRequired
	case invalidUrl
	case gerneralError(serverError:Error?,errorMsg:String?)
	case defaultError
	case bodyEncoding
	case expiredAuthToken
	case currentlyReAuthenticating
	
	var userRespresentableMessage : String {
		
		switch self {
		case .nilData ,.nilStatusCode ,.bodyEncoding ,.invalidUrl,.currentlyReAuthenticating	 : return ApiMessages.Issues.serverCommunicationError.rawValue

		case .loginRequired									 : return ApiMessages.Issues.loginRequired.rawValue
		case .expiredAuthToken								 : return ApiMessages.Issues.sessionExpiredPleaseLogin.rawValue
		case .gerneralError(_,let errorMsg)					 : return  errorMsg ?? ApiMessages.Issues.UnIdentified.rawValue
		case .defaultError									 : return ApiMessages.Issues.UnIdentified.rawValue
		}
	}
	
	
	public var errorDescription: String? {
		
		switch self{
		case .nilData :
			return " ApiCallError / nilData "
		case .nilStatusCode :
			return " ApiCallError / nilStatusCode "
		case .loginRequired :
			return " ApiCallError / loginRequired "
		case .invalidUrl :
			return " ApiCallError / invalidUrl "
		case .bodyEncoding:
			return " ApiCallError / decodingBodyError "
		case .gerneralError(let serverError,let errorMsg) :
			return " ServerConnectivityIssue / gerneralError / serverError = \(serverError?.localizedDescription ?? "defaultError" ) , errorMsg = \(String(describing: errorMsg)) "
		case .expiredAuthToken :
			return " ApiCallError / expiredAuthToken "
		case .currentlyReAuthenticating :
			return " ApiCallError / currentlyReAuthenticating "
		case .defaultError:
			return ApiMessages.Issues.UnIdentified.rawValue
		}
	}
}

// MARK: - UI Errors
public enum UIError : Error , LocalizedError ,UserRespresentableError{
	case invalidVcStoryboard(id:String)
	case invalidCell(identifier:String)
	case invalidNib(name:String)
	
	
	var userRespresentableMessage: String{
		return "invalid initialization"
	}
	
	public var errorDescription: String? {
		
		switch self{
		case .invalidVcStoryboard(id: let id) :
			return "invalid vc storyboard id  = \(id)"
		case .invalidCell(identifier: let cellId):
			return "invalid cell id \(cellId)"
		case .invalidNib(let name):
			return "invalid nib name \(name)"
		}
	}
}











public extension Error {
	func log(file: String = #file, function: String = #function, line: Int = #line) -> Error {
		//print(self.localizedDescription)
		return self
	}
}
