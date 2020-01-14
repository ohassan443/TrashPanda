//
//  Network.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//


import Foundation



/// middle layer between the objects that requests a call and the base layer that executes the call , mock values for dependencies can be injected to mock server response
class NetworkCaller : NetworkCallerProtocol{
    
    
    /// the object the executes the call to the server
    var networkCallExecutor     : NetworkCallExecutorProtocol
  
    /// the object that handles parsing the data returned from the networkCallExecutor in case of success or handles returning the correct message as to why the call failed wether server call failed or parsing failed
    var networkResponseAdapter  : NetworkResponseAdapter
    
    
    
    init(networkCallExecutor:NetworkCallExecutorProtocol,serverResponseAdapter: NetworkResponseAdapter) {
        self.networkCallExecutor    = networkCallExecutor
        self.networkResponseAdapter = serverResponseAdapter
    }
    
    
     /// middle layer between the object that requested the call and the base layer that executes the call
     ///
     /// - Parameters:
     ///   - callDetails: the api call with its expected parsing Type and the closure that returns that Type as a result
     ///   - successHandler: the success callback
     ///   - failHandler: the fail callback
     func makeCall<T>(callDetails:BaseApiCall<T>) -> Void{
      
        networkCallExecutor.execute(callDetails: callDetails.call, completionHandler: {
            obj in
			self.networkResponseAdapter.relayResponseToVc(callDetails: callDetails, response: obj, successHandler: callDetails.handlers.success, failHandler: callDetails.handlers.fail)
        })
        
    }
}





