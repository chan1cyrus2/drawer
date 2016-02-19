//
//  UserData.swift
//  drawer
//
//  Created by ChanCyrus on 2/14/16.
//  Copyright © 2016 ChanCyrus. All rights reserved.
//

import Foundation
import Firebase

class UserData{
  static let URL = FBConfig.baseURL + "/users"
  static let REF = Firebase(url: URL)
  
  //Ref
  let ref: Firebase?
  let categoriesRef: Firebase?
  
  //Properties
  let uid: String //key
  var categoriesKeys = [String?]()
  
  // Initialize from Firebase Auth Data
  init(snapshot: FDataSnapshot) {
    uid = snapshot.key
    ref = snapshot.ref
    categoriesRef = ref?.childByAppendingPath("categories")
    
    // Add Categories
    if let categoriesSnapshot = snapshot.value["categories"] as? FDataSnapshot{
      for item in categoriesSnapshot.children {
        categoriesKeys.append(item.key)
      }
    }
  }
}
