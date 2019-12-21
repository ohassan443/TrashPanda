//
//  Entity.swift
//  Omar Hassan
//
//  Created by omarHassan on 8/5/19.
//  Copyright © 2019 omar hammad. All rights reserved.
//

import Foundation

public enum ExtendableActions : NestableActions {
    
    
    case firstCategory(firstCategoryActions)
    case secondCategory(secondCategoryActions)
    
    public var description: String {

        switch self {
        case .firstCategory(let firstCategoryAction):
           return "firstCategoryActions" + firstCategoryAction.description
        case.secondCategory(let secondCategoryAction) :
           return  "secondCategoryActions" + secondCategoryAction.description
            
        }

    }
    
}

public enum firstCategoryActions :String,NestableActions {
        case dummyCase = "dummyCase"
    
    public var description: String {
        return "\(self.rawValue)"
    }
}

public enum secondCategoryActions : String,NestableActions{
    
    case dummyCase = "dummyCase"
    
    public var description: String {
        return "\(self.rawValue)"
    }
}


