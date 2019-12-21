//
//  NetworkCallerBuilder.swift
//  Omar Hassan
//
//  Created by omarHassan on 8/5/19.
//  Copyright © 2019 omar hammad. All rights reserved.
//

import Foundation
/// NetworkCallerProtocol Builder that returns concrete implementation or a mock
public class NetworkCallerBuilder {
    public init() {}
    
    private var delay : TimeInterval = 0
    private var mockOnResponse : ((ActionType) ->  ServerApiResponse) = {_ in return ServerApiResponse.fail(error: ErrorBase.none, statusCode: nil, errorCode: nil)}
    private var headersFactory : HeadersFactory = HeadersFactory()
    private var urlsessionWrapper : UrlSessionWrapperProtocol = UrlSessionWrapper()
    
    // default implementation
    public func defaultImp() -> NetworkCallerProtocol  {
        
        
        let networkCallExecutor         = NetWorkCallExecutor(headersFactory: headersFactory, urlSessionWrapper: urlsessionWrapper)
        let serverResponseAdapter       = NetworkResponseAdapter()
        
        return NetworkCaller(networkCallExecutor: networkCallExecutor,serverResponseAdapter: serverResponseAdapter)
    }
    
    func mock() -> NetworkCallerMock{
        return NetworkCallerMock(onResponse: mockOnResponse, delay: delay)
    }
    
    func with(headersFactory:HeadersFactory) -> NetworkCallerBuilder{
        self.headersFactory = headersFactory
        return self
    }
    func with(urlSessionWrapper:UrlSessionWrapperProtocol) -> NetworkCallerBuilder{
        self.urlsessionWrapper = urlSessionWrapper
        return self
    }
    
    func with(delay:TimeInterval) -> NetworkCallerBuilder {
        self.delay = delay
        return self
    }
    
    func with(onResponse:@escaping ((ActionType) ->  ServerApiResponse))-> NetworkCallerBuilder {
        self.mockOnResponse = onResponse
        return self
    }
}
