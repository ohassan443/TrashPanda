//
//  NetworkCallerProtocol.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation


public typealias failHandlerResponse =  (_ failResponseObject : ServerFailResponseObject) -> ()
public typealias successHandlerResponse<T> =  (_ response:T,_ serverDetailResponse: ServerDetailResponse) -> ()


/// middle layer between the objects that requests a call and the base layer that executes the call , mock values for dependencies can be injected to mock server response
public protocol NetworkCallerProtocol {
    /// middle layer between the object that requested the call and the base layer that executes the call
    ///
    /// - Parameters:
    ///   - callDetails: the api call with its expected parsing Type and the closure that returns that Type as a result
    ///   - successHandler: the success callback
    ///   - failHandler: the fail callback
    func makeCall<T>(callDetails:BaseApiCall<T>,successHandler: @escaping successHandlerResponse<T>,failHandler: @ escaping failHandlerResponse) -> Void
}



