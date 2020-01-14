//
//  ReAuthenticationRetryMock.swift
//  TrashPanda
//
//  Created by Omar Hassan  on 1/20/20.
//  Copyright © 2020 Omar Hassan. All rights reserved.
//

import Foundation

class ReAuthenticationRetryMock: ReAuthenticationRetryProtocol {

	struct ParamWrapper {
		var apiCall : ApiCallDetails
		var callBack : (ReAuthenticationResult)->()
	}


	private var response : ((ParamWrapper) -> ())? = nil
	init(response : @escaping (ParamWrapper)->()) {
		self.response = response
	}
	func runReAuthentication(apiCall: ApiCallDetails, completion: @escaping (ReAuthenticationResult) -> ()) {

		let parameters = ParamWrapper(apiCall: apiCall, callBack: completion)
		response?(parameters)

	}
}
