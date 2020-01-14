//
//  UrlSessionWrapper.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 12/21/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation


protocol UrlSessionWrapperProtocol {
    func makeRequest (callDetails:ApiCallDetails,completion : @escaping (ServerCallErrorTranslator.Translation)->())
}

class UrlSessionWrapperMock : UrlSessionWrapperProtocol{
	struct Parameters {
		var apiCall : ApiCallDetails
		var callBack : (ServerCallErrorTranslator.Translation)->()
	}


	private var mockResponse : (Parameters) -> ()

	init(mockResponse : @escaping (Parameters) -> ()) {
		self.mockResponse = mockResponse
	}

	func makeRequest(callDetails: ApiCallDetails, completion: @escaping (ServerCallErrorTranslator.Translation) -> ()) {
		let parameters = Parameters(apiCall: callDetails, callBack: completion)
		mockResponse(parameters)
	}
}

class UrlSessionWrapper: UrlSessionWrapperProtocol {

	static var shared = UrlSessionWrapper()

    func makeRequest(callDetails:ApiCallDetails , completion: @escaping  (ServerCallErrorTranslator.Translation) -> ()) {
        
        
        
        
        var modifiedUrl = callDetails.requestUrl // url with queryStrings
        if callDetails.queryStrings.isEmpty == false {
            modifiedUrl = addQueryStringParams(url: callDetails.requestUrl, dictionary: callDetails.queryStrings)
        }
        
        

        guard let url = URL(string: modifiedUrl)  else {
			completion(.fail(error:.localError(ErrorBase.Api(.apiCallError(.loginRequired))) ))
            return
        }
        var urlRequest = URLRequest(url: url)
        
        if let body = callDetails.body{
            guard let bodyData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
				completion(.fail(error:.localError(ErrorBase.Api(.apiCallError(.bodyEncoding)))))
                return
            }
            
            urlRequest.httpBody = bodyData
        }
        
        
        urlRequest.httpMethod = callDetails.method.rawValue
        urlRequest.addValue("application/json",forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 60
        sessionConfiguration.httpAdditionalHeaders = callDetails.headers
		sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: sessionConfiguration)
        
        
        let dataTask = session.dataTask(with: urlRequest, completionHandler: {data,response,error in

			let statusCode = ( response as? HTTPURLResponse )?.statusCode
			let result =  ServerCallErrorTranslator(error: error as NSError?, data: data, statusCode: statusCode).translate()
			completion(result)
        })
        dataTask.resume()
    }
}
