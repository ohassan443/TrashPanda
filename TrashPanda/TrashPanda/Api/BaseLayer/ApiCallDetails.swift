//
//  ApiCallDetails.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
var globalLastServiceCall : ApiCallDetails?

public enum AuthenticationType{
    case basic
    case refreshable
    case noneRequired
}


public struct SpecialApiErrorMsg {
    var statusCode : Int
    var serverErrorCode : String
    var overridedMessage : String
}


/// this class holds the basic structre of any crud api call such as url,headers,body,query strings ,.....
public class ApiCallDetails {
   
    private var requestUrl : String
    private var headers : [String:String]
    private var body : [String:Any]?
    private var action : ActionType
    private var method : ApiMethod
    private var authenticationType : AuthenticationType
    private var specialErrorMsgs : [SpecialApiErrorMsg]?
    private var queryStrings : [(String,String)]
    
    
    public var geturl                : String                     {return requestUrl}
    public var getbody               : [String:Any]?              {return body}
    public var getqueryStrings       : [(String,String)]          {return queryStrings}
    public var getHeaders            : [String:String]            {return headers}
    public var getmethod             : ApiMethod  	              {return method}
    public var getAction             : ActionType 	              {return action}
    public var getAuthenticationType : AuthenticationType         {return authenticationType}
    public var getSpecialErrorMsgs   : [SpecialApiErrorMsg]?      {return specialErrorMsgs}
    public func set(headers          : [String:String]){
        self.headers = headers
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
        self.authenticationType = .noneRequired
        self.specialErrorMsgs = nil
        self.queryStrings = []
    }
    
    public init(requestUrl : String
    ,headers : [String:String]
    ,body : [String:Any]?
    ,action : ActionType
    ,method : ApiMethod
    ,authenticationType : AuthenticationType
    ,specialErrorMsgs : [SpecialApiErrorMsg]?
    ,queryStrings : [(String,String)]
    ) {
        self.requestUrl             = requestUrl
        self.headers                = headers
        self.body                   = body
        self.action                 = action
        self.method                 = method
        self.authenticationType     = authenticationType
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
    func with(authenticationType:AuthenticationType) -> ApiCallDetails {
        self.authenticationType = authenticationType
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
        
        url = \(requestUrl)\n
        headers = \n \(headersString)\n
        body = \n \(body ?? [:])\n
        action = \(action.description)\n
        method = \(method.rawValue)\n
        loginRequired = \(authenticationType)
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
