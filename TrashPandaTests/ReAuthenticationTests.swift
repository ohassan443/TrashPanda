//
//  ReAuthenticationTests.swift
//  TrashPandaTests
//
//  Created by Omar Hassan  on 1/20/20.
//  Copyright © 2020 Omar Hassan. All rights reserved.
//


var maxDelay : TimeInterval = 10000
import XCTest
@testable import TrashPanda
class ReAuthenticationTests: XCTestCase {



	func createApiCallWith<T>(authentication : Authentication,parsingClosure: @escaping (Data)->(ParsingResult<T>),successHandler : @escaping successHandlerResponse<T>, failHandler : @escaping failHandlerResponse ) -> BaseApiCall<T> {

		let call = ApiCallDetails(requestUrl: Urls.baseUrl.rawValue + Urls.items.rawValue
			, headers: [:]
			, body: nil, action: ActionType.defaultCase(.defaultSubAction)
			, method: .get
			, authentication: authentication
			, specialErrorMsgs: nil
			, queryStrings: [])


		let apiCall = BaseApiCall<T>(call: call, parsingClosure: parsingClosure ,getFromCache: {
			return nil
		})
		apiCall.setHandlers(success: successHandler, fail: failHandler)
		return apiCall
	}


	func createApiCallToBeReAuthenticated(authentication : Authentication ) -> BaseApiCall<String>{
		return createApiCallWith(authentication: authentication
			, parsingClosure: {_ in return ParsingResult.success("")}
			, successHandler: {_ in }
			, failHandler: {_ in})
	}


	/**
	- test that reAuthentication module works correctly
		* if the reAuthentication closure provided by the api returnes . reExecute of fail then it will propgate the correct value to NetworkCallExecutor
	*/

	func testReAuthentication() {


		/// Create api call - this part usually will be placed in a factory class

		let authentication = Authentication.init(state: .ReAuthenticating, reAuthenticationCall: nil, createTokens: nil)

		let apiCall = createApiCallToBeReAuthenticated(authentication: authentication)



		authentication.reAuthenticationCall = {reAuthenticationOnComplete in
			reAuthenticationOnComplete(.ReExecute)
		}


		let reAuthenticationRetry = ReAuthenticationRetry()
		let expFirstReAuthentication = expectation(description: "reAuthentication module ran the reAuthentication closure provided by the api call and .ReExecute was returned")
		reAuthenticationRetry.runReAuthentication(apiCall: apiCall.call, completion: {
			result in
			(result == .ReExecute).assert()
			expFirstReAuthentication.fulfill()
		})
		wait(for: [expFirstReAuthentication], timeout: 1)




		authentication.reAuthenticationCall = {reAuthenticationOnComplete in
			reAuthenticationOnComplete(.fail)
		}
		let expSecondReAuthentication = expectation(description: "reAuthentication module ran the reAuthentication closure provided by the api call and .fail was returned")
		reAuthenticationRetry.runReAuthentication(apiCall: apiCall.call, completion: {
			result in
			(result == .fail).assert()
			expSecondReAuthentication.fulfill()
		})

		waitForExpectations(timeout: 1, handler: nil)


	}


	func testNetworkCallerExecutorDoesNotExcuteCallThatAreCurrentllyReAuthenticating() {
		let authentication = Authentication.init(state: .ReAuthenticating, reAuthenticationCall: nil, createTokens: nil)

		let apiCall = createApiCallToBeReAuthenticated(authentication: authentication)

		let expCallFailedToExecute = expectation(description: "network caller did not execute that call as it is already ReAuthenticating ")
		apiCall.setHandlers(success: {
			successString in
			XCTFail()
		}, fail: {
			failResponse in
			guard case ErrorBase.Api(.apiCallError(.currentlyReAuthenticating)) = failResponse.error else {
				XCTFail("wrong error returned")
				return
			}
			expCallFailedToExecute.fulfill()
		})

		authentication.reAuthenticationCall = {reAuthenticationOnComplete in
			reAuthenticationOnComplete(.ReExecute)
		}

		let networkCaller = NetworkCallerBuilder().defaultImp()
		networkCaller.makeCall(callDetails: apiCall)

		waitForExpectations(timeout: 1, handler: nil)
	}




	/**
	- Call is made and fails due to expired auth token
	- Reauthentication finishes successfully (refreshing the auth token)
	- Call is reexecuted and returns server response

	- Details :
		* setup the server mock to return 401 meaning expired token
		* make the reAuthentication return success , but before returning success (for reAuthentication) change the server response to return the success response (status code 200 & string response) simulating if the user saved the new tokens and is using them correctly in the closure that creates the headers for the api
		* then the server will be called again , verify that api success handler is executed
	*/
	func testCallReexecuteAfterSuccessfullReAuthentication() {


		let resultString 		= "success"
		/// create api Call

		let reAuthenticationCall : Authentication.ReAuthenticationCall = { reAuthCompletion  in
			/// here the creator of the api should reAuthenticate that api and then execute passed callBack 'reAuthCompletion' with the result of the reAuthentication
			print(5)
		}

		/// Create api call - this part usually will be placed in a factory class
		let tokens = ["authToken" : "current auth token that has expired"]
		let authentication = Authentication.init(state: .useTokens, reAuthenticationCall: reAuthenticationCall, createTokens: {return tokens})


		let expResponseReturnedSuccessfully = expectation(description: "response returned successfully after reauthentication")
		let apiCall = createApiCallWith(authentication: authentication
			, parsingClosure: {
				data in
				return  Parser().Decode(decodable: String.self, data: data)
		}
			, successHandler: {
				result in
				(result.response == resultString).assert()
				expResponseReturnedSuccessfully.fulfill()
		}
			, failHandler: {
				failObject in
				XCTFail()
		})




		/// Create mock server mock responses 401 unAuthorized and 200 success
		let mockFailedAuthResponse 	= ServerCallErrorTranslator.Translation.success(ServerCallErrorTranslator.successData(statusCode: StatusCodes.failedAuthentication.rawValue, data: Data()))
		let mockResponseData = """
			"\(resultString)"
			""".data(using: .utf8)!
		let mockSuccessResponse		= ServerCallErrorTranslator.Translation.success(ServerCallErrorTranslator.successData(statusCode: StatusCodes.success.rawValue, data: mockResponseData))

		/// Create UrlSessionWrapperMock and set its initial response with the 401 mock response
		let expServerRetruned401 = expectation(description: "server returned a 401 response indicating that the auth token has expired")
		var urlSessionResponse			 : (UrlSessionWrapperMock.Parameters) -> () = {parameters in
			parameters.callBack(mockFailedAuthResponse)
			expServerRetruned401.fulfill()
		}


		let expServerWasCalledTwice = expectation(description: "server was called twice , first time returns a 401 unAuthorized response and the second time returns a 200 success")
		expServerWasCalledTwice.expectedFulfillmentCount = 2
		let urlSessionWrapperMock = UrlSessionWrapperMock(mockResponse: {
			expServerWasCalledTwice.fulfill()
			urlSessionResponse($0)

		})


		/// Create reAuthenticationRetryMock and set its response to return successfull reAuthentication and to change the server response to return success 200 , so the next call succeeds
		let expServerCalledAgainAndReturnedSuccess = expectation(description: "server was called a second time after reAuthentication and returned a success (200)")
		let expReAuthenticatedSuccessfully = expectation(description: "reAuthentication module successfully retrieved the new tokens and is telling the NetworkCallExecutor to reExecute the call")
		/// the responsbility of using the new tokens is on the creator of the api as he provides 2 closures : the first is to parse the newly retrieved tokens and save them  and the second is to   use the last up to date tokens to create the correct header for the call
		let reAuthenticationRetryResponse : (ReAuthenticationRetryMock.ParamWrapper)->() = {parameters in
			urlSessionResponse = {parameters in
				parameters.callBack(mockSuccessResponse)
				expServerCalledAgainAndReturnedSuccess.fulfill()
			}

			parameters.callBack(.ReExecute)
			expReAuthenticatedSuccessfully.fulfill()
		}
		let reAuthenticationRetryMock = ReAuthenticationRetryMock(response: {reAuthenticationRetryResponse($0)})



		/// Create Network Called and inject the mock urlSessionWrapper and ReAuthentication components
		let networkCaller = NetworkCallerBuilder()
		.with(urlSessionWrapper: urlSessionWrapperMock)
		.with(fetchFromCache: false)
		.with(reAuthenticationRetry: reAuthenticationRetryMock)
		.defaultImp()


		networkCaller.makeCall(callDetails: apiCall)

		waitForExpectations(timeout: 1, handler: nil)
	}
}

