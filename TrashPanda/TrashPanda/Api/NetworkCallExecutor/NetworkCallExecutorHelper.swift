//
//  NetworkCallExecutorHelper.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation


/// enum to mask http methods instead of using raw strings
public enum ApiMethod : String{
    case get                = "GET"
    case post               = "POST"
    case update             = "UPDATE"
    case delete             = "DELETE"
    
}


/// adds a dictionary of query string parameters (keys & values) to a url
///
/// - Remark: spaces in the result url will be replaced by the string "%20"
/// - Parameters:
///   - url: the api call url to query strings parameters to
///   - dictionary: query string parameters in a string key an value format
/// - Returns: returns the url with the added query string parameters to the url
func addQueryStringParams(url:String,dictionary:[(String,String)]) -> String {
    var resultUrl = url
    
    guard dictionary.count > 0 else {return url}
    
    guard dictionary.count > 1 else {
        let modifiedUrl = url + "?" + "\(dictionary.first!.0)" + "=" + "\(dictionary.first!.1)"
        return modifiedUrl
        
    }
    for (index,element) in dictionary.enumerated() {
        guard index != 0 else {
            resultUrl += "?" + "\(element.0)" + "=" + "\(element.1)"
            continue
        }
        
        let key = element.0
        let value = element.1
        
        resultUrl += "&" + "\(key)" + "=" + "\(value)"
    }
    
    resultUrl = resultUrl.replacingOccurrences(of: " ", with: "%20")
    return resultUrl
}



