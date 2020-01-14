//
//  InternetMonitoringTests.swift
//  TrashPandaTests
//
//  Created by Omar Hassan  on 1/20/20.
//  Copyright © 2020 Omar Hassan. All rights reserved.
//

import XCTest
@testable import TrashPanda
class InternetMonitoringTests: XCTestCase {



	 func testStartInternetMonitorNotificationPosted()  {

		 let startInternetMonitoringNotificationName = Notification.Name("\(Date().timeIntervalSince1970)")

		let urlSessionWrapperMock = UrlSessionWrapperMock(mockResponse: {
			parameters in
			let mockInternetFailedResponse =  ServerCallErrorTranslator.Translation.fail(error:  .serverConnectivity(.internet))
			parameters.callBack(mockInternetFailedResponse)
		})

		 let networkCaller = NetworkCallerBuilder()
		 .with(urlSessionWrapper: urlSessionWrapperMock)
		 .with(startInternetMonitionringNotificationName: startInternetMonitoringNotificationName)
		 .defaultImp()

		 let call = ApiCallDetails()
			 .with(action: .defaultCase(.defaultSubAction))
		 let baseApiCall = BaseApiCall<Int>(call: call, parsingClosure: {
			 data in
			 return ParsingResult.success(0)
		 }, getFromCache: {
			 return nil
		 })


		 let expIntrnetMonitoringShouldStart = expectation(description: "the notification for internet checker to start monitoring the internet has been posted")
		 let expNetworkCallFailedWithCorrectError = expectation(description: "the netwrok call failed and returned the correct error ")


		 /// an object to verify that the intended notification was sent
		 let startInternetMonitorListener = NotificationListener(notificatioNameToListenTo: startInternetMonitoringNotificationName)
		 startInternetMonitorListener.set(onNotificationRecieve: {
			 expIntrnetMonitoringShouldStart.fulfill()
		 })

		 baseApiCall.setHandlers( success: {
			 _ in
			 XCTFail()
		 }, fail: {
			 failed in

			 guard case ErrorBase.Api(ApiError.serverConnectivityIssue(ServerConnectivityIssue.internet)) = failed.error else {
				 XCTFail("wrong type of error returned")
				 return
			 }
			 expNetworkCallFailedWithCorrectError.fulfill()

		 })


		 networkCaller.makeCall(callDetails: baseApiCall)

		 waitForExpectations(timeout: 3, handler: nil)
	 }


}
