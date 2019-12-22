//
//  ServerApiResponse.swift
//  Omar Hassan
//
//  Created by omarHassan on 8/5/19.
//  Copyright © 2019 omar hammad. All rights reserved.
//

import Foundation

/**
 completion handler type  which take 'ServerApiResponse' as a parameter
 */
typealias baseClassCompletionHandler = (_ completionObject : ServerApiResponse) -> ()



/**
 an enum to model server response into two case
 - success: the api call  was successful (associated value is response Data)
 - fail: the api call has failed and as an associated value are parameters that detail the fail reason (associated value is 'error,statusCode,errorCode')
 */
 enum ServerApiResponse {
    
     enum DataType {
        case data(data:Data)
        case any(any:Any)
    }
    
    
    /**
     - parameters :
     - data : the data returned from the server  of type `Json`
     */
    case success(_ : DataType)
    
    /**
     - parameters :
     - error        : A custom error of type `Error` that holds cases such as nilData,nilStatusError,etc...
     - statusCode   : Int statusCode
     - errorCoed    : A `String` value to indicate a specific server error , to add more resolution to server errors as in handle more cases
     */
    case fail(error:ErrorBase,statusCode:Int?,errorCode:String?)
    
    func getData() -> Data? {
        switch self {
        case .success(let dataType):
            switch dataType{
            case .data(data: let data):
                return data
            default :
                return nil
            }
        default:
            return nil
        }
    }
    func getCodes() -> (statusCode: Int? , errorCode : String?) {
        switch self {
        case .success(_):
            return (200 , nil)
        case .fail(error: _ , statusCode: let statusCode, errorCode: let errorCode):
            return (statusCode,errorCode)
            }
       }
    }

