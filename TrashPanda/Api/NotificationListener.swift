//
//  NotificationListener.swift
//  TrashPanda
//
//  Created by Omar Hassan  on 1/16/20.
//  Copyright © 2020 Omar Hassan. All rights reserved.
//

import Foundation


public class NotificationListener {

	private var onNotificationRecieveCallBack : (()->())? = nil

	init(notificatioNameToListenTo:Notification.Name) {
		NotificationCenter.default.addObserver(self, selector: #selector(onNotificationRecieve), name: notificatioNameToListenTo, object: nil)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	func set(onNotificationRecieve:@escaping()->()) -> Void {
		onNotificationRecieveCallBack = onNotificationRecieve
	}
	@objc func onNotificationRecieve() -> Void {
		onNotificationRecieveCallBack?()
	}
}
