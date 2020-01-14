//
//  ReAuthenticationProtocol.swift
//  TrashPanda
//
//  Created by Omar Hassan  on 1/20/20.
//  Copyright © 2020 Omar Hassan. All rights reserved.
//

import Foundation


protocol ReAuthenticationRetryProtocol {
	func runReAuthentication(apiCall:ApiCallDetails,completion:@escaping (_ result : ReAuthenticationResult)->())
}

public enum ReAuthenticationResult {
	case ReExecute
	case fail
}

