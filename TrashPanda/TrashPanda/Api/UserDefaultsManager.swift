//
//  UserDefaultsManager.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 12/20/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation
protocol UserDefaultsManagerProtocol {

    func setValueFor(value: String, key: UserDefaultsManager.Keys)
    func getValueFor(key: UserDefaultsManager.Keys) -> String?
    func updateValueFor(value: String, key: UserDefaultsManager.Keys) -> Bool
    func deleteValueForKey(key: UserDefaultsManager.Keys)
}



class UserDefaultsManager: UserDefaultsManagerProtocol{
    
    static let shared = UserDefaultsManager()
    
    
    
    enum Keys: String{
         case userToken      = "USER_TOKEN"
    }
    
    
    
    //////////////////
    func getValueFor(key: Keys) -> String?{
        return UserDefaults.standard.value(forKey: key.rawValue) as? String
    }
    func setValueFor(value: String, key: Keys){
        UserDefaults.standard.setValue(value, forKey: key.rawValue)
    }
    func updateValueFor(value: String, key: Keys) -> Bool{
        guard UserDefaults.standard.value(forKey: key.rawValue) != nil else {
            return false
        }
        setValueFor(value: value, key: key)
        return true
    }

    func deleteValueForKey(key: Keys){
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key.rawValue)
    }
    
}
