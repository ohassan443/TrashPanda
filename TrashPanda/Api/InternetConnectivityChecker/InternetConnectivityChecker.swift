//
//  NetworkAndInternetRetry.swift
//  TrashPanda
//
//  Created by Omar Hassan  on 1/14/20.
//  Copyright © 2020 Omar Hassan. All rights reserved.
//

import Foundation
import Reachability


class  InternetConnectivityChecker {

	private var pingUrl 					: URL
	private var internetIsAvaliableNotification	: Notification.Name
	private var currentlyChecking 				= false
	private var reachability 				 	: Reachability
	private var connectable 					: Reachability.Connection = .unavailable
	private var internetCHeckingSem 			= DispatchSemaphore(value: 1)
	private var urlSessionWrapper				: UrlSessionWrapperProtocol


	private var internetBingRetryInterval		: TimeInterval = 2
	private var reachabilityRecheckInterval		: TimeInterval = 1


	/// max interval to keep binging the internet
	private var maxRetryInterval : TimeInterval
	/// marking each time monitoring the internet start , to stop after a certain interva;
	private var monitoringStartDate : Date? = nil

	init(
		pingUrl:URL,
		maxRetryInterval : TimeInterval,
		startMonitoringNotification:Notification.Name,
		internetIsAvaliableNotification:Notification.Name
		,urlSessionWrapper: UrlSessionWrapperProtocol) {
		self.pingUrl = pingUrl
		self.internetIsAvaliableNotification = internetIsAvaliableNotification
		self.maxRetryInterval = maxRetryInterval
		self.reachability = try! Reachability(hostname: pingUrl.absoluteString)
		self.urlSessionWrapper = urlSessionWrapper

		NotificationCenter.default.addObserver(self, selector: #selector(MonitorReachabailityStatus), name: Notification.Name.reachabilityChanged , object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(startInternetMonitoring), name: startMonitoringNotification , object: nil)
		try? self.reachability.startNotifier()
	}

	deinit {
		self.reachability.stopNotifier()
		internetCHeckingSem.signal()
		NotificationCenter.default.removeObserver(self)
	}


	/// if the network is avaliable then bing internet , and if no network is avaliable then check again after 1 second
	@objc private func startInternetMonitoring() {
		switch connectable {
		case .unavailable,.none:
			DispatchQueue.global().asyncAfter(deadline: .now() + reachabilityRecheckInterval, execute: {[weak self] in
				self?.startInternetMonitoring()
			})
			return
		case .cellular,.wifi :
			monitoringStartDate = Date()
			bingInternet()
		}
	}


	//MARK:- internet monitoring
	@objc private func MonitorReachabailityStatus() -> Void {
		connectable = reachability.connection
	}

	/**
	- if nettwork is avaliable then bingInternet to check internet connectivity
	- only one Internet bing at a time
	*/
	private func bingInternet() {
		/// verify that the internet checkr has not been running more than the max interval
		guard let monitoringStartDate = monitoringStartDate else {return}
		guard Date().timeIntervalSince1970 - monitoringStartDate.timeIntervalSince1970 > maxRetryInterval else {
			self.monitoringStartDate = nil
			return
		}

		internetCHeckingSem.wait()
		guard currentlyChecking == false else{
			return
		}
		currentlyChecking = true
		internetCHeckingSem.signal()


		let apiCall = ApiCallDetails()
			.with(requestUrl: pingUrl.absoluteString)
			.with(method: .get)
			.with(action: .Nestable(ExtendableActions.bingInternet))

		urlSessionWrapper.makeRequest(callDetails: apiCall, completion: {[weak self]
			result in
			guard let self = self else {return}
			guard
				case .success(let successData) = result ,
				successData.statusCode == 200  else {
					self.bingHandler(success: false)
					return
			}
			self.bingHandler(success: true)
		})

	}



	/**
	- in case of binging the internet successfully then inform all the delegates and remove the weak refrences of delegates that were destroyed
	- in case of failure then retry binging the internet again after a certain interval
	*/
	private func bingHandler(success:Bool)  {

		guard success else {
			currentlyChecking = false
			DispatchQueue.global().asyncAfter(deadline: .now() + internetBingRetryInterval, execute: {[weak self] in
				self?.bingInternet()
			})
			return
		}

		/// reset the monitor start date , send notification and
		monitoringStartDate = nil
		NotificationCenter.default.post(name: internetIsAvaliableNotification, object: nil)
		currentlyChecking = false
	}
}
