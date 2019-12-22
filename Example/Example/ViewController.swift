//
//  ViewController.swift
//  Example
//
//  Created by Omar Hassan  on 12/21/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import UIKit
import TrashPanda

class ViewController: UIViewController {

   struct FoodItemModel : Codable {
        var id          : Int
        var name        : String
        var photoUrl    : String
        var description : String
        
        enum CodingKeys : String,CodingKey {
            case id
            case name
            case photoUrl
            case description
        }
    }

    
    let networkCaller = NetworkCallerBuilder().defaultImp()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
     let call = createCall()
        
        networkCaller.makeCall(callDetails: call, successHandler: {  response,details in
            print(response.first)
        }, failHandler: {
            failObj in
            failObj.userRepresentableMessage
        })
        
        
        
    }


    
    func createCall() -> BaseApiCall<[FoodItemModel]> {
          
                let call = ApiCallDetails(requestUrl: Urls.baseUrl.rawValue + Urls.getFoodItemList.rawValue
                    , headers: [:]
                    , body: nil, action: ActionType.defaultCase(.defaultSubAction)
                    , method: .get
                    , authenticationType: .noneRequired
                    , specialErrorMsgs: nil
                    , queryStrings: [])
        
        
                let getFoodItemsListCall = BaseApiCall<[FoodItemModel]>(call: call, parsingClosure: {
                    data in
                    return  Parser().Decode(decodable: [FoodItemModel].self, data: data,keyedBy: "items")
                },getFromCache: {
                    return nil
                })
        
        return getFoodItemsListCall
    }
    
}

