//
//  UtilityExtenstions.swift
//  TrashPandaTests
//
//  Created by Omar Hassan  on 12/21/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
import XCTest
extension Bool{
	func assert() -> Void {
		XCTAssertTrue(self)
	}
	func assertFail() -> Void {
		XCTAssertFalse(self)
	}
}


