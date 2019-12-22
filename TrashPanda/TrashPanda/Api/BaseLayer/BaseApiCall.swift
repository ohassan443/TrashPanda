//
//  BaseApiCall.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

/**
 - Type to bind api call to its expected return type
 - T indicates the resulting parsing type of the api call return
    example if the api 'x' return a 'String', then 'x' should have T as String
 - api call facotires will subclass this type to provide different types of api calls
     * create an api call factory for user api calls such as login/registeration/forgetpassword,...
     * in this class api call will be asigned a function that takes parameters depending on the api and the return function of the call will be the call and with its expected parsing type (class/struct/array of class ,int ,....) to bind the type statically at the place of the call

 */
public class BaseApiCall<T>{
    public typealias parsingType = (_ params: Data)  -> ParsingResult<T>
    public typealias getFromCacheType =  ()->(T?)
    /// the api call object the hold the call details such as url,http method , query strings ,....
    var call : ApiCallDetails
    
    
    /// a closure that takes the server response Data and return the expected return type from this api
    /// this call back is unique for every call and will be asigned at the call creatinon in the factory class
    /// this call back will be executed if the server returns
    var parsing         : parsingType
    var getFromCache    : getFromCacheType
    
    
    
    public init(call:ApiCallDetails,parsingClosure: @escaping parsingType,getFromCache: @escaping getFromCacheType) {
        self.call = call
        parsing = parsingClosure
        self.getFromCache = getFromCache
    }
    
    func update(queryString:String,newValue:String) -> Bool {
       
         guard let index = call.getqueryStrings.firstIndex(where: {
            element in
            return element.0 == queryString
         }) else {
            return false
        }
        
        call.updateQueryStringAt(index: index, newValue: newValue)
        return true
    }
}
