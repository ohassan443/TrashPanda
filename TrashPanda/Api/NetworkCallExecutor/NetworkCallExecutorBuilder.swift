//
//  NetworkCallExecutorBuilder.swift
//  Omar Hassan
//
//  Created by omarHassan on 8/5/19.
//  Copyright © 2019 omar hammad. All rights reserved.
//

import Foundation
/**
 objects that implement this protocol will execute an api call of type 'ApiCallDetails' and will execute a completionHandler of type 'baseClassCompletionHandler' after parsing parameters like data(optional) / statusCode / errorCode(optional) / server error message(optional)
 */
protocol NetworkCallExecutorProtocol : AnyObject {
    func execute(callDetails:ApiCallDetails,completionHandler : @escaping baseClassCompletionHandler) -> Void
}


/**
 a mock for server that can be configured to return a response of type `ServerApiResponse`
 */
class NetworkCallExectuorMock: NetworkCallExecutorProtocol {
    private var response : ServerApiResponse
    private var delay    : TimeInterval
    
	init(response:ServerApiResponse,delay:TimeInterval) {
        self.response   = response
        self.delay      = delay
    }
    func execute(callDetails call: ApiCallDetails, completionHandler: baseClassCompletionHandler) -> Void {
        completionHandler(response)
    }
}
