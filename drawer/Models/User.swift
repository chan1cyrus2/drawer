//
//  User.swift
//  drawer
//
//  Created by ChanCyrus on 2/5/16.
//  Copyright © 2016 ChanCyrus. All rights reserved.
//

import Foundation
import Firebase

class User{
  //Auth Data
  let uid: String
  var email: String
  
  // Initialize from Firebase Auth Data
  init(authData: FAuthData) {
    uid = authData.uid
    email = authData.providerData["email"] as! String
  }
}