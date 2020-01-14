//
//  ServerFailResponseObject.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
/**
 object to map server response to app expected format in case of failure
 - Components :
    + statusCode
    + errorMsg
    + serverErrorCode
    + error
*/
public struct ServerFailResponseObject : Equatable{
 
    public var statusCode : Int?
    public var userRepresentableMessage : String
    public var serverErrorCode : String?
    public var error : ErrorBase
    
   
    
    public static func == (lhs: ServerFailResponseObject, rhs: ServerFailResponseObject) -> Bool {
        return   lhs.statusCode == rhs.statusCode && lhs.serverErrorCode == rhs.serverErrorCode
    }
}
