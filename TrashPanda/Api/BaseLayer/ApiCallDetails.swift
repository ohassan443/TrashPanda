//
//  ApiCallDetails.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
var globalLastServiceCall : ApiCallDetails?


public class Authentication {
	public typealias ReAuthenticationCall = (_ completion : (ReAuthenticationResult)->())-> ()

	var state 				: AuthenticationState
	var reAuthenticationCall 		: ReAuthenticationCall? /// the create of refresh token call is passed as a parameter so that the call details such as headers including the refresh token can be created when needed with correct values , say after a previous api refreshed the tokens
	private var createTokensCallback : (()->([String:String]))?

	var createTokens : (()->([String:String]))? {
		guard case .useTokens = state else {
			return nil
		}
		return createTokensCallback
	}


	public init(state :  AuthenticationState , reAuthenticationCall : ReAuthenticationCall?, createTokens : (()->([String:String]))? ){
		self.state = state
		self.reAuthenticationCall = reAuthenticationCall
		self.createTokensCallback = createTokens
	}
}


public enum AuthenticationState {
	/// this is to avoid refreshing a token multiple times if multiple api calls fail , if the first successfully refreshes the token then this closure should determine that the next apis should not refresh it again
	public typealias createHeadersCallBack = () -> [String:String]
	public typealias recentlyRefreshedHeaders = createHeadersCallBack


	case useTokens
	case noneRequired
	case ReAuthenticating
    case failedToReAuthenticate
}




public struct SpecialApiErrorMsg {
    var statusCode : Int
    var serverErrorCode : String
    var overridedMessage : String
}

extension Array where Element == (String,String){
	func reduceToString() -> String {
		return reduce("", {result,element in
			return result + element.0 + element.1
		})
	}
}

/// this class holds the basic structre of any crud api call such as url,headers,body,query strings ,.....
public class ApiCallDetails : Hashable {
	public static func == (lhs: ApiCallDetails, rhs: ApiCallDetails) -> Bool {
		
		
		return lhs.requestUrl == rhs.requestUrl &&
		lhs.headers  == rhs.headers &&
		lhs.queryStrings.reduceToString() == rhs.queryStrings.reduceToString() &&
		lhs.method  == rhs.method
	}
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.requestUrl)
		hasher.combine(self.queryStrings.reduceToString())
		hasher.combine(self.headers)
		hasher.combine(self.method.rawValue)
		
	}
   
    private (set) var requestUrl 		: String
    private (set) var headers 			: [String:String]
    private (set) var body 			: [String:Any]?
    private (set) var action 		: ActionType
    private (set) var method : ApiMethod
    private (set) var authentication : Authentication
    private (set) var specialErrorMsgs : [SpecialApiErrorMsg]?
    private (set) var queryStrings : [(String,String)]

    public func update(headers headersToAdd          : [String:String]){
        for header in headersToAdd {
            self.headers[header.key] = header.value
        }
    }
    public func updateQueryStringAt(index:Int,newValue:String){
        guard queryStrings.count  - 1 <= index else {return}
        queryStrings[index].1 = newValue
    }
    
    
    public init() {
        self.requestUrl = ""
        self.headers = [:]
        self.body = nil
        self.action = .defaultCase(.defaultSubAction)
        self.method = .get
		self.authentication = Authentication(state: .noneRequired, reAuthenticationCall: {_ in}, createTokens: nil)
        self.specialErrorMsgs = nil
        self.queryStrings = []
    }
    
    public init(requestUrl : String
    ,headers : [String:String]
    ,body : [String:Any]?
    ,action : ActionType
    ,method : ApiMethod
	,authentication : Authentication
    ,specialErrorMsgs : [SpecialApiErrorMsg]?
    ,queryStrings : [(String,String)]
    ) {
        self.requestUrl             = requestUrl
        self.headers                = headers
        self.body                   = body
        self.action                 = action
        self.method                 = method
        self.authentication     = authentication
        self.specialErrorMsgs       = specialErrorMsgs
        self.queryStrings           = queryStrings
        
    }
    final func errorMsgfor(statusCode:Int,serverErrorCode:String) -> String? {
        guard let errorMsgs = specialErrorMsgs else{return nil}
        
        guard let filteredError = errorMsgs.filter({return ($0.statusCode == statusCode) && ($0.serverErrorCode == serverErrorCode)}).first else {return nil}
        let msg = filteredError.overridedMessage
        return msg
    }
    
    
    func with(requestUrl:String) -> ApiCallDetails {
        self.requestUrl = requestUrl
        return self
    }
    
    func with(headers:[String:String]) -> ApiCallDetails {
        self.headers = headers
        return self
    }
    func with(body:[String:Any]?) -> ApiCallDetails {
        self.body = body
        return self
    }
    func with(action:ActionType) -> ApiCallDetails {
        self.action = action
        return self
    }
    func with(method:ApiMethod) -> ApiCallDetails {
        self.method = method
        return self
    }
	func with(authentication: Authentication) -> ApiCallDetails {
        self.authentication = authentication
        return self
    }
    func with(specialErrorMsgs:[SpecialApiErrorMsg]?) -> ApiCallDetails {
        self.specialErrorMsgs = specialErrorMsgs
        return self
    }
    func with(queryStrings:[(String,String)]) -> ApiCallDetails {
        self.queryStrings = queryStrings
        return self
    }
}






// //printing option - for debugging
extension ApiCallDetails : CustomStringConvertible {
	public var description: String {
		let temp = """
		--------------------------------
		url = \(requestUrl)\n
		headers = \n \(headersString)\n\n
		body = \n \(body ?? [:])\n\n
		action = \(action.description)\n\n
		method = \(method.rawValue)\n\n
		authentication = \(authentication)\n
		--------------------------------
		"""
		return temp

	}
    var headersString : String {
        var resultString = ""
        for element in headers {
            resultString += "\(element.key) = \(element.value)\n"
        }
        return resultString
    }
}
