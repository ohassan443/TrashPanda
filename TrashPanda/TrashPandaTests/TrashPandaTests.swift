//
//  TrashPandaTests.swift
//  TrashPandaTests
//
//  Created by Omar Hassan  on 12/21/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import XCTest
@testable import TrashPanda

class TrashPandaTests: XCTestCase {
    
    
    enum AssertionResult<T> {
        case success( successCallBack :  (T)->Bool)
        case fail   (error:Error?,failCallBack     : (ServerFailResponseObject)->Bool)
    }
    /** abstract test initalization
     - creating
     + UrlSessionMock
     + concrete NetworkCalled
     + dummy ApiCall
     + base Api call generic wrapper
     + httpResponse
     + expectation
     + execution of assertion closure
     inject the success and fail assertion in the callBack
     */
    func testSuccessfullParsingAndDataReturn< T: Decodable >(mockResponse:Data,apiParsing: @escaping (Data) -> ParsingResult<T>,assertion:  AssertionResult<T>,keyedBy: String? = nil,statusCode:Int? ) -> Void {
        
        var serverMockError : Error?
        if case AssertionResult.fail(error: let error, failCallBack: _) = assertion{
            serverMockError = error
        }
        
        ///create url session wrapper mock and use it to create concrete instance of network caller
        let urlSessionWrapperMock = UrlSessionWrapperMock(mockResponse: .remoteResponse(Data(), URLResponse(), nil), delay: 0)
        let networkCaller = NetworkCallerBuilder()
            .with(urlSessionWrapper: urlSessionWrapperMock)
            .defaultImp()
        
        /// create the HttpResponse
        let httpResponseStatusCode200 =  HTTPURLResponse(url: URL(string: "https://www.google.com/")!, statusCode: statusCode ?? -100, httpVersion: kCFHTTPVersion2_0 as String, headerFields: nil)!
        urlSessionWrapperMock.change(response: .remoteResponse(mockResponse, statusCode == nil ? nil : httpResponseStatusCode200 , serverMockError))
        
        
        /// create dummy apiCalldetails (its details does not matter as here i am testing the 200 success and parsing and returning to the caller)
        /// bind the api call to baseApiCall with its parsing type
        let call = ApiCallDetails()
            .with(action: .defaultCase(.defaultSubAction))
        let baseApiCall = BaseApiCall<T>(call: call, parsingClosure: {
            data in
            return apiParsing(data)
        })
        
        
        /// create expectation to wait for callBack and execute the baseApi Call & run the assertion closure in the callBack and assert its true
        let expWaitForResponse = expectation(description: "waitForMockResponse")
        
        networkCaller.makeCall(callDetails: baseApiCall, successHandler: {
            returnedValue,_ in
            
            guard case AssertionResult.success(successCallBack: let successAssertion) = assertion else {
                XCTFail()
                return
            }
            
            XCTAssertTrue(successAssertion(returnedValue))
            expWaitForResponse.fulfill()
        }, failHandler: {
            failObj in
            guard case AssertionResult.fail(error:_,failCallBack: let failAssertion) = assertion else {
                XCTFail()
                return
            }
            
            XCTAssertTrue(failAssertion(failObj))
            expWaitForResponse.fulfill()
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
    
    func testSuccessSimpleString() {
        /// parsing simple string
        let mockResponseData = """
        "success"
        """.data(using: .utf8)!
        testSuccessfullParsingAndDataReturn(mockResponse: mockResponseData, apiParsing: {
            data in
            return Parser().Decode(decodable: String.self, data: data)
        }, assertion: .success(successCallBack: {
            resultString in
            return resultString == "success"
        }), statusCode: 200)
    }
    
    func testSuccessSimpleKeyAndValue() {
        /// test parsing simple key,value
        let response : [String:Any] = ["key":"value"]
        guard let mockResponseData = try? JSONSerialization.data(withJSONObject: response, options: []) else {
            XCTFail()
            return
        }
        testSuccessfullParsingAndDataReturn(mockResponse: mockResponseData, apiParsing: {
            data in
            return Parser().Decode(decodable: String.self, data: data, keyedBy: "key")
        }, assertion: .success(successCallBack: {
            resultString in
            return resultString == "value"
        }), keyedBy: "key", statusCode: 200)
        
    }
    
    /// parsing codable type
    fileprivate class CodableCalss: Codable{
        var id   :Int
        var name : String
    }
    
    
    /// parse json of codable compliant object
    func testsuccessCodablObject() {
        let mockResponseData = """
        {
        "id" : 50,
        "name" : "omar"
        }
        """.data(using: .utf8)!
        testSuccessfullParsingAndDataReturn(mockResponse: mockResponseData, apiParsing: {
            data in
            return Parser().Decode(decodable: CodableCalss.self, data: data)
        }, assertion: .success(successCallBack: {
            result in
            return result.id == 50 && result.name == "omar"
        }), keyedBy: nil, statusCode: 200)
        
    }
    
    /// parse json of codable compliant object keyed as a value for a key
    func testSuccessKeyedCodableObject() {
        let response = [
            "key" :[
                "id"    : 50,
                "name"  : "omar"
            ]
        ]
        guard let mockResponseData = try? JSONSerialization.data(withJSONObject: response, options: []) else {
            XCTFail()
            return
        }
        testSuccessfullParsingAndDataReturn(mockResponse: mockResponseData, apiParsing: {
            data in
            return Parser().Decode(decodable: CodableCalss.self, data: data,keyedBy: "key")
        }, assertion: .success(successCallBack: {
            result in
            return result.id == 50 && result.name == "omar"
        }), statusCode: 200)
        
        
    }
    
    /// parse a json of codable compliant objects
    func testSuccessKeyedCOdableObjectArray() {
        ///parsing codable type nested in a key
        let response = [
            "key" :[
                ["id"    : 50,
                 "name"  : "omar"],
                ["id"    : 51,
                 "name"  : "hassan"]
            ]
        ]
        guard let mockResponseData = try? JSONSerialization.data(withJSONObject: response, options: []) else {
            XCTFail()
            return
        }
        testSuccessfullParsingAndDataReturn(mockResponse: mockResponseData, apiParsing: {
            data in
            return Parser().Decode(decodable: [CodableCalss].self, data: data,keyedBy: "key")
        }, assertion:.success(successCallBack: {
            result in
            return result[0].id == 50 && result[0].name == "omar" &&
                result[1].id == 51 && result[1].name == "hassan"
        }), statusCode: 200)
    }
    
    
    
    /// a key for a value that is not optional not found
    func testKeyNotFound() -> Void {
        let response = [
            "id"    : 50,
        ]
        guard let mockResponseData = try? JSONSerialization.data(withJSONObject: response, options: []) else {
            XCTFail()
            return
        }
        testSuccessfullParsingAndDataReturn(mockResponse: mockResponseData, apiParsing: {
            data in
            return Parser().Decode(decodable: CodableCalss.self, data: data)
        }, assertion: .fail(error : nil,failCallBack: {
            failObj in
            guard case ErrorBase.Api(.parsing(ParsingError.keysNotAvaliable(keys: let missingKeys))) = failObj.error else {
                XCTFail()
                return false
            }
            
            (missingKeys.count == 1).assert()
            (missingKeys[0] == "name").assert()
            return true
        }), statusCode: 200)
        
        
    }
    
    /// value that is not optional not found
    func testValueNotFound() {
        let response = [
            "id"    : 50,
            "name"  : nil
        ]
        guard let mockResponseData = try? JSONSerialization.data(withJSONObject: response, options: []) else {
            XCTFail()
            return
        }
        testSuccessfullParsingAndDataReturn(mockResponse: mockResponseData, apiParsing: {
            data in
            return Parser().Decode(decodable: CodableCalss.self, data: data)
        }, assertion: .fail(error : nil,failCallBack: {
            failObj in
            guard case ErrorBase.Api(.parsing(ParsingError.valueNotFound(attemptedType: let attemptedType))) = failObj.error else {
                XCTFail()
                return false
            }
            
            (attemptedType == "String").assert()
            return true
        }), statusCode: 200)
    }
    
    
    /// parsing wrong type
    func testTypeMisMatch() {
        let response = [
            "id"    : 50,
            "name"  : 50
        ]
        guard let mockResponseData = try? JSONSerialization.data(withJSONObject: response, options: []) else {
            XCTFail()
            return
        }
        testSuccessfullParsingAndDataReturn(mockResponse: mockResponseData, apiParsing: {
            data in
            return Parser().Decode(decodable: CodableCalss.self, data: data)
        }, assertion: .fail(error : nil,failCallBack: {
            failObj in
            guard case ErrorBase.Api(.parsing(ParsingError.decodingError(error: let decodingError, keys: _ ))) = failObj.error else {
                XCTFail()
                return false
            }
            guard case DecodingError.typeMismatch(let type, let context) = decodingError else {
                XCTFail()
                return false
            }
            
            // expected string but found int
            (String(describing: type) == "String").assert()
            return true
        }), statusCode: 200)
    }
    
    
    /// netowek avaliable but not internet connection
    func testInternetError() {
        let response : [String:Any] = [
            "id"    : 50,
            "name"  : "name"
        ]
        
        let errorsDueToInternet = internetErrors
        
        
        
        guard let mockResponseData = try? JSONSerialization.data(withJSONObject: response, options: []) else {
            XCTFail()
            return
        }
        
        for error in errorsDueToInternet {
            testSuccessfullParsingAndDataReturn(mockResponse: mockResponseData, apiParsing: {
                data in
                return Parser().Decode(decodable: CodableCalss.self, data: data)
            }, assertion: .fail(error : URLError(URLError.Code(rawValue: error)),failCallBack: {
                failObj in
                
                
                guard case ErrorBase.Api(ApiError.serverConnectivityIssue(.internet)) = failObj.error else {
                    XCTFail()
                    return false
                }
                return true
            }), statusCode: nil)
        }
      }
    
    
    
    /// no network avaliable
    func testNetworkErrors() {
      let response : [String:Any] = [
          "id"    : 50,
          "name"  : "name"
      ]
      
      let errorsDueToInternet = networkErrors
      
      
      
      guard let mockResponseData = try? JSONSerialization.data(withJSONObject: response, options: []) else {
          XCTFail()
          return
      }
      
      for error in errorsDueToInternet {
          testSuccessfullParsingAndDataReturn(mockResponse: mockResponseData, apiParsing: {
              data in
              return Parser().Decode(decodable: CodableCalss.self, data: data)
          }, assertion: .fail(error : URLError(URLError.Code(rawValue: error)),failCallBack: {
              failObj in
              
              
              guard case ErrorBase.Api(ApiError.serverConnectivityIssue(.network)) = failObj.error else {
                  XCTFail()
                  return false
              }
              return true
          }), statusCode: nil)
      }
    }
    
 }
