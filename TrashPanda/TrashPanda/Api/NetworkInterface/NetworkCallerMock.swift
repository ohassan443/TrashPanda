//
//  NetworkMock.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation


class NetworkCallerMock: NetworkCallerProtocol {
    
 
    private let delay    : TimeInterval
    private var onResponse : (_ action:ActionType) -> ServerApiResponse
    
    init(onResponse : @escaping (_ action:ActionType) -> ServerApiResponse ,delay:TimeInterval) {
        self.onResponse       = onResponse
        self.delay          = delay
    }
    
    func set(onResponse: @escaping (_ action:ActionType) -> ServerApiResponse) -> Void {
        self.onResponse = onResponse
    }
    func makeCall<T>(callDetails:BaseApiCall<T>,successHandler: @escaping successHandlerResponse<T>,failHandler: @ escaping failHandlerResponse) -> Void{
        
        
        
        let actionSpecificResponse = self.onResponse(callDetails.call.getAction)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                NetworkResponseAdapter().relayResponseToVc(callDetails: callDetails, response: actionSpecificResponse, successHandler: successHandler, failHandler: failHandler)
            })
        }
}
