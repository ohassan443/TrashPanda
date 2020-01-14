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

	private var urlsessionWrapper : UrlSessionWrapperProtocol = UrlSessionWrapper()
	private var reAuthenticationRetry : ReAuthenticationRetryProtocol = ReAuthenticationRetry()
	private var shouldFetchFromCache  = true
	private var startInternetMonitionringNotificationName = InternetConnectivityCheckerBuilder().defaultAvaliableInternetNotificatioName

	// default implementation
	public func defaultImp() -> NetworkCallerProtocol  {


		let networkCallExecutor         = NetWorkCallExecutor(urlSessionWrapper: urlsessionWrapper, reAuthenticationRetry: reAuthenticationRetry, startInternetMonitoringNotificationName: startInternetMonitionringNotificationName)
		let serverResponseAdapter       = NetworkResponseAdapter(fetchFromCacheIfAvaliable: shouldFetchFromCache)

		return NetworkCaller(networkCallExecutor: networkCallExecutor,serverResponseAdapter: serverResponseAdapter)
	}

	func mock(onResponse:@escaping ((ActionType) ->  ServerApiResponse)) -> NetworkCallerMock{
		self.mockOnResponse = onResponse
		let serverResponseAdapter       = NetworkResponseAdapter(fetchFromCacheIfAvaliable: shouldFetchFromCache)
		return NetworkCallerMock(onResponse: mockOnResponse, delay: delay, networkResponseAdapter: serverResponseAdapter)
	}


	func with(urlSessionWrapper:UrlSessionWrapperProtocol) -> NetworkCallerBuilder{
		self.urlsessionWrapper = urlSessionWrapper
		return self
	}

	public func with(delay:TimeInterval) -> NetworkCallerBuilder {
		self.delay = delay
		return self
	}

	func with(fetchFromCache:Bool) -> NetworkCallerBuilder {
		self.shouldFetchFromCache = fetchFromCache
		return self
	}

	func with(reAuthenticationRetry: ReAuthenticationRetryProtocol) -> NetworkCallerBuilder {
		self.reAuthenticationRetry = reAuthenticationRetry
		return self
	}
	func with(startInternetMonitionringNotificationName:Notification.Name)-> NetworkCallerBuilder {
		self.startInternetMonitionringNotificationName = startInternetMonitionringNotificationName
		return self
	}
}
