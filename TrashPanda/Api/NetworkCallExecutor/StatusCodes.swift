//
//  StatusCodes.swift
//  TrashPanda
//
//  Created by Omar Hassan  on 1/20/20.
//  Copyright © 2020 Omar Hassan. All rights reserved.
//

import Foundation
enum StatusCodes : Int {
	case success 				= 200
	case badRequest				= 400
	case notFound			 	= 404
	case failedAuthentication  	= 401
	case internalServerError 		= 500
}
