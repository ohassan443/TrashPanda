//
//  NetworkMock.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation


public class NetworkCallerMock: NetworkCallerProtocol {
    
 
    private let delay    : TimeInterval
    private var onResponse : (_ action:ActionType) -> ServerApiResponse
    private var networkResponseAdapter : NetworkResponseAdapter
    
    
    init(onResponse : @escaping (_ action:ActionType) -> ServerApiResponse ,delay:TimeInterval,networkResponseAdapter: NetworkResponseAdapter) {
        self.onResponse       = onResponse
        self.delay          = delay
        self.networkResponseAdapter = networkResponseAdapter
    }
    
    func set(onResponse: @escaping (_ action:ActionType) -> ServerApiResponse) -> Void {
        self.onResponse = onResponse
    }
    public func makeCall<T>(callDetails:BaseApiCall<T>) -> Void{
        
        
        
        let actionSpecificResponse = self.onResponse(callDetails.call.action)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { [weak self] in
                guard let mock = self else {return}
				mock.networkResponseAdapter.relayResponseToVc(callDetails: callDetails, response: actionSpecificResponse, successHandler: callDetails.handlers.success, failHandler: callDetails.handlers.fail)
            })
        }
}
