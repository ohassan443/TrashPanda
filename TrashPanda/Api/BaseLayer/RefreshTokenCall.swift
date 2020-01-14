//
//  RefreshTokenCall.swift
//  TrashPanda
//
//  Created by Omar Hassan  on 1/11/20.
//  Copyright © 2020 Omar Hassan. All rights reserved.
//

import Foundation
public struct RefreshTokenCall {

	let url            	: String
	let body            	: [String:Any]
	let headers         	: [String:String]
	let method          	: ApiMethod
	private let onSuccess   	: (Data)->()

	public init(url:String,body:[String:Any],headers: [String:String],
				method : ApiMethod?,
				onSuccess: @escaping (Data)->()) {
		self.url                   	= url
		self.body               	    = body
		self.headers              		= headers
		self.method               	    = method ?? .post
		self.onSuccess     	  	  		= onSuccess
	}


	func executeOnSuccess(data:Data,completion:()->()) -> Void {
		onSuccess(data)
		completion()
	}
}

