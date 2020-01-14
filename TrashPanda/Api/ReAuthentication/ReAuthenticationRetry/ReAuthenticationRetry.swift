//
//  AuthenticationRetry.swift
//  TrashPanda
//
//  Created by Omar Hassan  on 1/11/20.
//  Copyright © 2020 Omar Hassan. All rights reserved.
//

import Foundation


class ReAuthenticationRetry : ReAuthenticationRetryProtocol{

	private var reAuthenticateSem = DispatchSemaphore(value: 1)



	init() {}
	deinit {
		reAuthenticateSem.signal()
	}


	func runReAuthentication(apiCall:ApiCallDetails,completion:@escaping (_ result : ReAuthenticationResult)->()){
		reAuthenticateSem.wait()

		guard
			let reAuthenticationCall = apiCall.authentication.reAuthenticationCall,
			case .ReAuthenticating = apiCall.authentication.state else {
			completion(.fail)
			return
		}
		reAuthenticationCall({ [weak self] result in
			guard let self = self else {return}
			completion(result)
			self.reAuthenticateSem.signal()
		})
	}
}
