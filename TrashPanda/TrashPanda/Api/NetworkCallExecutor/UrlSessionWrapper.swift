//
//  UrlSessionWrapper.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 12/21/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

enum UrlSessionResult {
    case localError(ErrorBase)
    case remoteResponse(Data?,URLResponse?,Error?)
}
protocol UrlSessionWrapperProtocol {
    func makeRequest (callDetails:ApiCallDetails,completion : @escaping (UrlSessionResult)->())
}

class UrlSessionWrapperMock : UrlSessionWrapperProtocol{
    
    private var mockResponse : UrlSessionResult
    private var delay : TimeInterval
    
    init(mockResponse : UrlSessionResult , delay : TimeInterval) {
        self.mockResponse = mockResponse
        self.delay = delay
    }
    
    func change(response:UrlSessionResult){
        self.mockResponse = response
    }
    func change(delay:TimeInterval) -> Void {
        self.delay = delay
    }
    func makeRequest(callDetails: ApiCallDetails, completion: @escaping (UrlSessionResult) -> ()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: {[weak self] in
            guard let mock = self else {return}
            completion(mock.mockResponse)
        })
    }
}

class UrlSessionWrapper: UrlSessionWrapperProtocol {

    func makeRequest(callDetails:ApiCallDetails , completion: @escaping  (UrlSessionResult) -> ()) {
        
        
        
        
        var modifiedUrl = callDetails.geturl // url with queryStrings
        if callDetails.getqueryStrings.isEmpty == false {
            modifiedUrl = addQueryStringParams(url: callDetails.geturl, dictionary: callDetails.getqueryStrings)
        }
        
        
        
        
        guard let url = URL(string: modifiedUrl)  else {
            completion(.localError(ErrorBase.Api(.apiCallError(.loginRequired))))
            return
        }
        var urlRequest = URLRequest(url: url)
        
        if let body = callDetails.getbody{
            guard let bodyData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
                completion(.localError(ErrorBase.Api(.apiCallError(.bodyEncoding))))
                return
            }
            
            urlRequest.httpBody = bodyData
        }
        
        
        urlRequest.httpMethod = callDetails.getmethod.rawValue
        urlRequest.addValue("application/json",forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 60
        sessionConfiguration.httpAdditionalHeaders = callDetails.getHeaders
        let session = URLSession(configuration: sessionConfiguration)
        
        
        let dataTask = session.dataTask(with: urlRequest, completionHandler: {data,response,error in
            completion(.remoteResponse(data, response, error))
        })
        dataTask.resume()
    }
}
