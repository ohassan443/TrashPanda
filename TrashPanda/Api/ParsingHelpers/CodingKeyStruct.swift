//
//  CodingKeyStruct.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation



/// turn a string into a coding key to use in parsing Codable objects
struct CodingKeysStruct: CodingKey {
    
    var stringValue: String
    var intValue: Int?
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        self.intValue = intValue
        stringValue = "\(intValue)"
    }
    
    static func key(named name: String) -> CodingKeysStruct? {
        return CodingKeysStruct(stringValue: name)
    }
    
}



extension Array where Element == String {
    func codingKeys() -> [CodingKeysStruct] {
        return compactMap{
            return CodingKeysStruct.init(stringValue: $0)
        }
    }
}
extension Array where Element == CodingKeysStruct {
    func  stringKeys() -> [String] {
        return self.map(){return $0.stringValue}
    }
}

extension String {
    func asCodingKey()->CodingKeysStruct {
        return CodingKeysStruct(stringValue: self)
    }
}
