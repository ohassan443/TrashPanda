//
//  AlternativeNameParsing.swift
//  Omar Hassan
//
//  Created by Omar Hassan  on 3/17/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//


import Foundation




/// this class will be used for custom parsing cases for codable objects
/// current functionality :
///     - parse a property  with multiple keys -> the key could be different in two apis , if all the passed keys are not found an error will be thrown
///     - parse a property  with multiple keys  that could be optional , if all the passed keys are not found a nil value will be returned
class AlternativeNameParser {
    
    
    
    /// parse a property  with multiple keys -> the key could be different in two apis , if all the passed keys are not found an error (ParsingError.keysNotAvaliable(keys: stringKeys)) will be thrown
    ///
    /// - Parameters:
    ///   - targetType: the target parsing type
    ///   - container: the KeyedDecodingContainer found in the custom codable init
    ///   - keys: the desired keys to search for
    /// - Returns: the desired type for the first matching key , if two keys are avaliable the value of the first key will be returned and the second will be discarded
    /// - Throws: decoding errors (valueNotFound,typeMismatch,dataCorrupted,ParsingError.keysNotAvaliable(keys: stringKeys))
    func parse<target:Codable,codingKey:CodingKey>(targetType: target.Type ,container:KeyedDecodingContainer<codingKey>,keys:[codingKey]) throws -> target {
        
        for key in keys {
            do {
                let responseModel = try container.decode(targetType, forKey: key)
                //print(responseModel)
                return responseModel
                
            }catch DecodingError.keyNotFound(let key, let context) {
                // continue to try next key if current key is not avaliable
                //print("key not found \(key.stringValue), \n context = \(context)")
                continue
            }
            catch DecodingError.valueNotFound(let type, let context){
                //print("not found")
                //print("type: \(type) ,\n context: \(context)")
                        
                throw ParsingError.decodingError(error: DecodingError.valueNotFound(type, context), keys: keys.map(){return $0.stringValue} ).log()
                
            }catch DecodingError.typeMismatch(let type , let context){
                //print("mismatch")
                //print("type: \(type) , \ncontext: \(context)")
                throw  ParsingError.decodingError(error: DecodingError.typeMismatch(type, context), keys: keys.map(){return $0.stringValue}).log()
                
                
            }catch DecodingError.dataCorrupted(let context) {
                //print("corrupted context is \(context)")
                throw  ParsingError.decodingError(error: DecodingError.dataCorrupted(context), keys: keys.map(){return $0.stringValue}).log()
            }
        }
        
        // throw error 'keys not found' only if all keys fail
        let stringKeys = keys.map(){return $0.stringValue}
        throw  ParsingError.keysNotAvaliable(keys: stringKeys).log()
    }
    
    
    /// parse a property  with multiple keys -> the key could be different in two apis , if all the passed keys are not found then a nil value will be returned
    ///
    /// - Parameters:
    ///   - targetType: the target parsing type
    ///   - container: the KeyedDecodingContainer found in the custom codable init
    ///   - keys: the desired keys to search for
    /// - Returns: the value of desired type for the first matching key if found , if two keys are avaliable the value of the first key will be returned and the second will be discarded
    func parseOptional<target:Codable,codingKey:CodingKey>(targetType: target.Type ,container:KeyedDecodingContainer<codingKey>,keys:[codingKey])throws -> target? {
        
        for key in keys {
            do {
                let responseModel = try container.decode(targetType, forKey: key)
                //print(responseModel)
                return responseModel
                
            } catch DecodingError.valueNotFound(_,_) {
                // return nil if key was found but it has a null value
                return nil
                //throw  ApiError.ParsingError.decodingError(error: DecodingError.valueNotFound(type, context))
                
            }catch DecodingError.keyNotFound(_,_){
                //in case key is not avaliable, try the next key
                continue
            }
            catch DecodingError.typeMismatch(let type , let context){
                //print("mismatch")
                //print("type: \(type) , context: \(context)")
                
                throw  ParsingError.decodingError(error: .typeMismatch(type, context), keys: keys.map(){return $0.stringValue}).log()
                
            }catch DecodingError.dataCorrupted(let context) {
                //print("corrupted context is \(context)")
                throw  ParsingError.decodingError(error: .dataCorrupted(context), keys: keys.map(){return $0.stringValue}).log()
            }
        }
        
        // return nil  if all keys were tried and no key was avaliable
        return nil
    }
}


