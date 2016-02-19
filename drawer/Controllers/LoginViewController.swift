//
//  LoginViewController.swift
//  drawer
//
//  Created by ChanCyrus on 2/3/16.
//  Copyright © 2016 ChanCyrus. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
  
  // MARK: - Constants
  let ref = FBConfig.getBaseRef()
  var currentUser = (UIApplication.sharedApplication().delegate as! AppDelegate).currentUser
  
  // MARK: - Segue Identifiers
  let loginToHome = "LogintoHome"
  
  // MARK: - Outlets
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  
  // MARK: - Lifecycles
  override func viewDidLoad() {
    super.viewDidLoad()
    ref.observeAuthEventWithBlock { (authData) -> Void in
      if let authData = authData {
        self.currentUser = User(authData: authData)
        self.performSegueWithIdentifier(self.loginToHome, sender: nil)
      }
    }
    // print (ref.authData)
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Action
  @IBAction func onLoginButton(sender: UIButton) {
    ref.authUser(textFieldLoginEmail.text, password: textFieldLoginPassword.text,
      withCompletionBlock: { (error, auth) in
        /*if auth != nil {
          self.currentUser = User(authData: auth)
          self.performSegueWithIdentifier(self.loginToHome, sender: nil)
        }*/
    })
  }
  
  @IBAction func onSignupButton(sender: UIButton) {
    let alert = UIAlertController(title: "Register",
      message: "Register",
      preferredStyle: .Alert)
    
    let saveAction = UIAlertAction(title: "Save",
      style: .Default) { (action: UIAlertAction) -> Void in
        
      let emailField = alert.textFields![0]
      let passwordField = alert.textFields![1]
      
      self.ref.createUser(emailField.text, password: passwordField.text) { (error: NSError!) in
        if error == nil {
          self.ref.authUser(emailField.text, password: passwordField.text,
            withCompletionBlock: { (error, auth) -> Void in
          })
        }
      }
    }
  
    let cancelAction = UIAlertAction(title: "Cancel",
      style: .Default) { (action: UIAlertAction) -> Void in
    }
    
    alert.addTextFieldWithConfigurationHandler {
      (textEmail) -> Void in
      textEmail.placeholder = "Enter your email"
    }
    
    alert.addTextFieldWithConfigurationHandler {
      (textPassword) -> Void in
      textPassword.secureTextEntry = true
      textPassword.placeholder = "Enter your password"
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    presentViewController(alert,
      animated: true,
      completion: nil)
  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
