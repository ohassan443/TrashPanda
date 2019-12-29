//
//  Parser.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation





/// Server data Parser to local codable objects
public class Parser {
    
    public init(){}
    
    
    
    
    /// decode and return data as the requested Type
    ///
    /// - Parameters:
    ///   - decodable: the target type to parse the data to
    ///   - data: the server data
    ///   - key: optional value if the target json object is not on the first level and is nested inside another object in the response with this key
    /// - Returns: the target Type after parsing from the passed Data
    /// - Throws: ErrorBase.Api.ParsingError.decodingError
    public func Decode<T>(decodable: T.Type,data: Data, keyedBy key : String? = nil)  -> ParsingResult<T> where T : Decodable{
      
        guard let key = key else {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            return  wrapDecodingError(operation: { try jsonDecoder.decode(decodable, from: data) })
        }
        
        
        let operationResult : ParsingResult<T> = wrapDecodingError(operation: {
            // Pass the top level key to the decoder
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.userInfo[.jsonDecoderRootKeyName] = key
            
            let root = try decoder.decode(DecodableRoot<T>.self, from: data)
            return root.value
        })
        
            
        
        if case ParsingResult.fail(let parsingError) = operationResult {
            let _ = parsingError.log()
        }
        
        
        return operationResult
      }
    
    
    
    /// wrapper to docode a generic object of type T inside a json object keyed by the string inside `userInfo[.jsonDecoderRootKeyName]`
    struct DecodableRoot<T>: Decodable where T: Decodable {
        let value: T
        
        
        /// extract the codable type inside the keyed container for the key at `userInfo[.jsonDecoderRootKeyName] `
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeysStruct.self)
            guard
                let keyName = decoder.userInfo[.jsonDecoderRootKeyName] as? String,
                let key = CodingKeysStruct.key(named: keyName) else {
                    //throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: [], debugDescription: "Value not found at root level."))
                    throw ParsingError.invalidRootDataKey(key: decoder.userInfo[.jsonDecoderRootKeyName] as? String ?? "")
            }
            
            value = try container.decode(T.self, forKey: key)
        }
    }
    
    
    ///parse variable of generic Type from DecodingContainer
    public func parse<target:Codable,codingKey:CodingKey>(targetType: target.Type ,container:KeyedDecodingContainer<codingKey>,key:codingKey)  throws ->  target {
        
        
        let decodingResult = wrapDecodingError(operation: {
            try container.decode(targetType, forKey: key)
        }, codingKeyStringValue: key.stringValue)
        
        
        switch decodingResult {
        case .success(let result) :
            return result
        case .fail(let parsingError) :
            throw parsingError
        }
    }
    
    
     /// parse an optional variable of generic Type from DecodingContainer
     /// returns nil only if value = null and throws error if key is not found
    public func parseOptional<target:Codable,codingKey:CodingKey>(targetType: target.Type ,container:KeyedDecodingContainer<codingKey>,key:codingKey)throws -> target? {
        
        
        let decodingResult = wrapDecodingError(operation: {
            try container.decode(targetType, forKey: key)
        }, codingKeyStringValue:  key.stringValue)
        
        
        switch decodingResult{
        case .success(let result) :
            return result
        case .fail(let parsingError):
            if case ParsingError.valueNotFound(_) = parsingError{
            return nil
            }else {
                throw parsingError
            }
        }
    }
    
    func  wrapDecodingError<T>(operation: () throws ->(T),codingKeyStringValue:String? = nil) -> ParsingResult<T> {

        var keys = [codingKeyStringValue].compactMap({return $0})
        do {
            let responseModel = try operation()
            //////print(responseModel)
            return ParsingResult.success(responseModel)
            
        }catch DecodingError.keyNotFound(let attemptedKey,let context) {
            // continue to try next key if current key is not avaliable
            ////print("key not found \(key.stringValue), \n context = \(context)")
            print(attemptedKey)
            print(context)
            keys.append(attemptedKey.stringValue)
            let error = ParsingError.keysNotAvaliable(keys: keys)
            let _ = error.log()
            return .fail(error)
        }
        catch DecodingError.valueNotFound(let attemptedType,let context){
            ////print("not found")
            ////print("type: \(type) ,\n context: \(context)")
            print(context)
            let error = ParsingError.valueNotFound(attemptedType : String(describing: attemptedType))
            let _ = error.log()
            return .fail( error)
            
        }catch DecodingError.typeMismatch(let type , let context){
            ////print("mismatch")
            ////print("type: \(type) , \ncontext: \(context)")
            let error = ParsingError.decodingError(error: DecodingError.typeMismatch(type, context), keys: [])
            let _ = error.log()
            return .fail( error)
            
            
        }catch DecodingError.dataCorrupted(let context) {
            ////print("corrupted context is \(context)")
            let error = ParsingError.decodingError(error: DecodingError.dataCorrupted(context), keys: [])
            let _ = error.log()
            return .fail(error  )
        }
        catch {
            return .fail(.undefined)
        }
        
    }
    
    
    
    
    
    
    /// transfer value of type Data to [String:Any]
    /// - Remark : use for debuggng onyy
    ///
    /// - Parameter responseData: server Response Data
    /// - Returns: Result dictionary
    public func parseRequestResponseJson(responseData : Data?) -> [String:Any]? {
        guard let data = responseData else {return nil}
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
    }
}
extension CodingUserInfoKey {
    static let jsonDecoderRootKeyName = CodingUserInfoKey(rawValue: "rootKeyName")!
}


