//
//  FBConfig.swift
//  drawer
//
//  Created by ChanCyrus on 2/3/16.
//  Copyright © 2016 ChanCyrus. All rights reserved.
//

import Foundation
import Firebase

class FBConfig: NSObject {
  static let baseURL = "https://drawer-test.firebaseio.com"
  
  static func getBaseRef() -> Firebase {
    return Firebase(url: baseURL)
  }
  
  // categories
  static func getCategoryRef() -> Firebase {
    return Firebase(url: baseURL).childByAppendingPath("categories")
  }
  
  // categories/key
  static func getCategoryWithKeyRef(key: String) -> Firebase {
    return Firebase(url: baseURL).childByAppendingPath("categories").childByAppendingPath(key)
  }
  
  // users/uid
  static func getUserRef(key: String) -> Firebase {
    return Firebase(url: baseURL).childByAppendingPath("users").childByAppendingPath(key)
  }

  // users/uid/categories
  static func getUserCategoryRef(key: String) -> Firebase {
    return getUserRef(key).childByAppendingPath("categories")
  }
}