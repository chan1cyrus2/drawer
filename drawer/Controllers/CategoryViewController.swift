//
//  CategoryViewController.swift
//  drawer
//
//  Created by ChanCyrus on 2/11/16.
//  Copyright © 2016 ChanCyrus. All rights reserved.
//

import UIKit
import Firebase

class CategoryViewController: UIViewController {
  // MARK: - Properties
  var currentCategory: Category?
  var categories = [Category]()
  var user:User!
  
  // Mark: - Outlets
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - UIViewController Lifecycle
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    // Get user auth Data
    let ref = FBConfig.getBaseRef()
    self.user = User(authData: ref.authData)
    
    var categoryRef: Firebase
    // Get categories list based on whether this is the first category page or nested
    if let currentCategory = currentCategory{
      categoryRef = currentCategory.ref!.childByAppendingPath("subcategories")
    }else{
      categoryRef = FBConfig.getUserCategoryRef(user.uid)
    }
    
    // Category ChildAdded observer
    categoryRef.observeEventType(.ChildAdded, withBlock: { snapshot -> Void in
      // get category ref
      let categoryKeyRef = FBConfig.getCategoryWithKeyRef(snapshot.key)
      categoryKeyRef.observeEventType(.Value, withBlock: { snapshot -> Void in
        self.categories.append(Category(snapshot: snapshot))
        let row = self.categories.count - 1
        let indexPath = NSIndexPath(forRow: row, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
      })
    })
    
    // Category childRemove observer
    categoryRef.observeEventType(.ChildRemoved, withBlock: { snapshot -> Void in
      let categoryKeytoFind = snapshot.key
      
      for (index, category) in self.categories.enumerate(){
        if category.key == categoryKeytoFind{
          let indexPath = NSIndexPath(forRow: index, inSection: 0)
          self.categories.removeAtIndex(index)
          self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
      }
    })
  }
  
  override func viewDidAppear(animated: Bool) {
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Actions
  @IBAction func onAddButton(sender: UIBarButtonItem) {
    let alert = UIAlertController(title: "Add", message: "Add Category", preferredStyle: .Alert)
    
    let saveAction = UIAlertAction(title: "Add", style: .Default) {
      (action: UIAlertAction) -> Void in
      let categoryField = alert.textFields![0]
      
      let category = Category(name: categoryField.text!, uid: self.user.uid)
      let newCategoryRef = FBConfig.getCategoryRef().childByAutoId()
      // 1. add to category
      newCategoryRef.setValue(category.toAnyObject())
      // 2. add to users/categories or categories/id/subcategories
      if let currentCategory = self.currentCategory {
        currentCategory.ref?.childByAppendingPath("subcategories").childByAppendingPath(newCategoryRef.key).setValue("true")
      }else{
        FBConfig.getUserCategoryRef(self.user.uid).childByAppendingPath(newCategoryRef.key).setValue("true")
      }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
      style: .Default) { (action: UIAlertAction) -> Void in
    }
    
    alert.addTextFieldWithConfigurationHandler {
      (textCategory) -> Void in
      textCategory.placeholder = "Enter your Category"
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    presentViewController(alert,
      animated: true,
      completion: nil)
    
  }
  
}

// MARK: - UITableViewDelegates
extension CategoryViewController: UITableViewDelegate, UITableViewDataSource{
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    /* Get cell type */
    let cellReuseIdentifier = "CategoryCell"
    let category = categories[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
    
    /* Set cell defaults */
    cell.textLabel!.text = category.name
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {    
    // Get the associated category item
    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CategoryViewController") as! CategoryViewController
    vc.currentCategory = categories[indexPath.row]
    navigationController?.pushViewController(vc, animated: true)
    
  }
  
}