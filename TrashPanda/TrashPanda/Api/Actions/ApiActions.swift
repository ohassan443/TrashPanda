//
//  ApiActions.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//


import Foundation


public protocol NestableActions {
     var description : String {get}
}

/// this enum holds the main categories of apis in the app and each category holds subActions , for example (user holds  subActions like `getUserDetails`,`editUserDetails`,....)
///
/// - user: the actions relating to the user such as login/register/editUser ,....
/// - notification: actions relating to notifications such as getAllNotifications,registerDeviceToken,...
/// - product:  actions relating to products such as getAllProducts,changeProduct,...
/// - creditCard: credit card actions such as addNewCreditCard,deleteCreditCard,....
/// - defaultCase: at the func getSubAction() this case is used as a placeholder before exctracting the subActions
public enum ActionType : CustomStringConvertible{
    
    case Nestable(ExtendableActions)

    
    case defaultCase(defaultSubAction)
    
    public var description : String {
        
        switch self {
        case .Nestable(let Nestable):
            return  "Nestable" + Nestable.description
            
        case .defaultCase(let defaultSubAction):
            return "userAction" + defaultSubAction.description // default temp value
        }
    }
    

    
    
    
   
   
     ///placeHolder case in the main categories
    public enum defaultSubAction: String,NestableActions {
        case defaultSubAction = "defaultSubAction"
        public var description: String {
            return self.rawValue
        }
    }
}


