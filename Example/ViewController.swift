//
//  ViewController.swift
//  Example
//
//  Created by Omar Hassan  on 1/15/20.
//  Copyright © 2020 Omar Hassan. All rights reserved.
//


import UIKit
import TrashPanda

class ViewController: UIViewController {

   struct EmployeeModel : Codable {
        var id       : String
        var name      : String
        var photoUrl   : String
		var age 		: String
        var salary 	: String

        enum CodingKeys : String,CodingKey {
            case id
            case name = "employee_name"
            case photoUrl = "profile_image"
			case age  = "employee_age"
            case salary = "employee_salary"
        }
    }


    let networkCaller = NetworkCallerBuilder().defaultImp()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

     let call = createCall()
		call.setHandlers(success: {
			resultArray in
			let result = resultArray
			print(resultArray)
		}, fail: {
			failResponse in
			print(failResponse)
		})

		networkCaller.makeCall(callDetails: call)
    }



    func createCall() -> BaseApiCall<[EmployeeModel]> {

		let authenticationType = Authentication(state: .useTokens, reAuthenticationCall: {reAuthOnComplete in
			/// check for the validity of the current tokens , maybe another api just refreshed them

			/// if they are not valid then refresh them  here and if successfull execute the 'reAuthOnComplete' with .ReExecute and if not then execute it with .fail in the callBack of the ReAuthentication Api



			reAuthOnComplete(.ReExecute)

		}, createTokens: {
			let tokens = ["authToken":"last updated auth token"]
			return tokens
		})


		let call = ApiCallDetails(requestUrl: Urls.baseUrl.rawValue + Urls.employees.rawValue
			, headers: [:]
			, body: nil, action: ActionType.defaultCase(.defaultSubAction)
			, method: .get
			, authentication: authenticationType
			, specialErrorMsgs: nil
			, queryStrings: [])


		let getFoodItemsListCall = BaseApiCall<[EmployeeModel]>(call: call, parsingClosure: {
			data in
			return  Parser().Decode(decodable: [EmployeeModel].self, data: data,keyedBy: "data")
		},getFromCache: {
			return nil
		})

		return getFoodItemsListCall
    }

}

