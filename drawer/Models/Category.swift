//
//  Category.swift
//  drawer
//
//  Created by ChanCyrus on 2/11/16.
//  Copyright © 2016 ChanCyrus. All rights reserved.
//

import Foundation
import Firebase

class Category {
  var ref: Firebase?
  var key: String?
  
  var name: String!
  var uid: String!
  var subcategoriesKeys: [String]?
  
  // Initialize from arbitrary data
  init(name: String, uid:String, key: String = "") {
    self.key = key
    self.name = name
    self.uid = uid
  }
  
  // Initialize from Firebase snapshot
  init(snapshot: FDataSnapshot) {
    ref = snapshot.ref
    key = snapshot.key
    name = snapshot.value["name"] as! String
    
    let subcategoriesKeysSnapshot = snapshot.childSnapshotForPath("subcategories")
    for child in subcategoriesKeysSnapshot.children {
      subcategoriesKeys?.append(child.key!!)
    }
  }
  
  func toAnyObject() -> AnyObject {
    return [
      "uid" : uid,
      "name": name,
      "subcategories": subcategoriesKeysToAnyObject()
    ]
  }
  
  func subcategoriesKeysToAnyObject() -> AnyObject {
    var subcategoriesKeysDic = [String:Bool]()
    if let keys = subcategoriesKeys {
      for key in keys{
        subcategoriesKeysDic[key] = true
      }
    }
    return subcategoriesKeysDic
  }
  
}