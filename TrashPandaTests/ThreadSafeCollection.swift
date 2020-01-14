//
//  ThreadSafeCollection.swift
//  TrashPandaTests
//
//  Created by Omar Hassan  on 12/21/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import TrashPanda
import Foundation
class ThreadSafeCollection<T> {
      
      // Concurrent synchronization queue
      private let queue = DispatchQueue(label: "ThreadSafeCollection.queue", attributes: .concurrent)
      
      /// action(description as string representation) and its number of repition in the apiCalls dictionary
      private var actionsCount : [String:Int] = [:]
      
      /// action and its index of calling to the params and the callBack
      /// Ex : " login action description + 0 " : parameters of call , call back to respond to this call
      private var elements     : [String:T] = [:]
      
      
      
      func add(action:ActionType,call : T) -> Void {
         queue.async(flags: .barrier) {
          let count = self.actionsCount[action.description] ?? 0
          let id = self.createUniqueStringFor(action: action, index: count)
          self.actionsCount[action.description] = count + 1
          self.elements[id] = call
          }
      }
      
      func getCall(index:Int,action:ActionType) -> T? {
          var response : T? = nil
          queue.sync {
              let id = createUniqueStringFor(action: action, index: index)
              response = elements[id]
          }
          return response
      }
      
      
      private func createUniqueStringFor(action:ActionType,index:Int)-> String {
          return action.description + "/" + "\(index)"
      }
      func getAll() -> [String] {
           return elements.map(){return $0.key}
          
      }
      func getCountForApi(action:ActionType) -> Int {
          return actionsCount[action.description] ?? 0
      }
  }
