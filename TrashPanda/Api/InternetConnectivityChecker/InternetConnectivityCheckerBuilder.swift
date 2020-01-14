//
//  InternetConnectivityCheckerBuilder.swift
//  TrashPanda
//
//  Created by Omar Hassan  on 1/15/20.
//  Copyright © 2020 Omar Hassan. All rights reserved.
//

import Foundation

public class InternetConnectivityCheckerBuilder {

	public  let defaultAvaliableInternetNotificatioName 	= Notification.Name("TrashPandaInternetIsAvaliableNotificatioName")

	private var pingUrl 							= URL(string: "www.google.com")!
	private var maxRetryInterval  					= Double(180)
	private var startMonitoringNotificationName 		= Notification.Name("TrashPandaStartMonitoringNotificationName")
	private var internetIsAvaliableNotificationName 	: Notification.Name
	private var urlSessionWrapper					: UrlSessionWrapperProtocol = UrlSessionWrapper()

	init() {
		internetIsAvaliableNotificationName = defaultAvaliableInternetNotificatioName
	}

	func concrete()-> InternetConnectivityChecker {
		return InternetConnectivityChecker(pingUrl: pingUrl
			, maxRetryInterval: maxRetryInterval
			, startMonitoringNotification: startMonitoringNotificationName
			, internetIsAvaliableNotification: internetIsAvaliableNotificationName, urlSessionWrapper: urlSessionWrapper)
	}

	func with(pingUrl:URL) -> InternetConnectivityCheckerBuilder {
		self.pingUrl = pingUrl
		return self
	}
	func with(maxRetryInterval: Double) -> InternetConnectivityCheckerBuilder {
		self.maxRetryInterval = maxRetryInterval
		return self
	}
	func with(startMonitoringNotificationName:Notification.Name) -> InternetConnectivityCheckerBuilder {
		self.startMonitoringNotificationName = startMonitoringNotificationName
		return self
	}
	func with(internetIsAvaliableNotificationName:Notification.Name) -> InternetConnectivityCheckerBuilder {
		self.internetIsAvaliableNotificationName = internetIsAvaliableNotificationName
		return self
	}
	func with(urlSessionWrapper:UrlSessionWrapperProtocol) -> InternetConnectivityCheckerBuilder {
		self.urlSessionWrapper = urlSessionWrapper
		return self
	}
}
