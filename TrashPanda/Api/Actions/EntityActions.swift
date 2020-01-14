//
//  Entity.swift
//  Omar Hassan
//
//  Created by omarHassan on 8/5/19.
//  Copyright © 2019 omar hammad. All rights reserved.
//

import Foundation

public enum ExtendableActions : NestableActions {

	case bingInternet

	public var description: String {
		switch self {
		case .bingInternet : return "bingInternet"
		}
	}

}






