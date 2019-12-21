//
//  ApiConstants.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 12/20/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

class ApiConstants {
    
    enum Keys :String{
        case errorMsg            = "detail"
        case errorCode           = "errorCode"
    }
    
    static let baseHeaders = ["content-type":"application/json"]
    
    
}
