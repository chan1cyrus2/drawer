//
//  CategoryViewController.swift
//  drawer
//
//  Created by ChanCyrus on 2/11/16.
//  Copyright © 2016 ChanCyrus. All rights reserved.
//

import UIKit
import Firebase
//import MXParallaxHeader

class CategoryViewController: TableNavigationViewController {
    // MARK: - Properties
    var currentCategory: Category?  // category associated to current view
    var categories = [Category]()   // list of categories to shown on screen
    var user:User!
    
    // Mark: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - UIViewController Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("on CategoryViewController viewDidLoad")
        
        // attach delegates
        tableView.delegate = self
        
        // Update title
        if let currentCategory = currentCategory{
            self.title = currentCategory.name
        }else{
            self.title = "List"
        }
        
        // Get user auth Data
        let ref = FBConfig.getBaseRef()
        self.user = User(authData: ref.authData)
        
        // Get categories list based on whether this is the first category page or nested
        var categoryRef: Firebase
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
                let row = self.categories.count // -1
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
        super.viewDidAppear(animated)
        
        // Enable follow scrolling
        if let navigationController = self.navigationController as? TableNavigationController {
            navigationController.followScrollView(tableView, scrollUpDelay: 0, scrollDownDelay: 50)
        }
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
        return categories.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /* Get cell type */
        let cellReuseIdentifier = "CategoryCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        if(indexPath.row == 0){
            cell.textLabel!.text = "All"
        }else{
            let category = categories[indexPath.row-1]
            /* Set cell defaults */
            cell.textLabel!.text = category.name
            print(category.name)
        }

        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get the associated category item
        if(indexPath.row == 0){
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("DetailListViewController") as! DetailListViewController
            //vc.currentCategory = categories[indexPath.row-1]
            if let nc = navigationController as? TableNavigationController{
                vc.title = "All"
                nc.pushViewController(vc, animated: true, title: self.title!)
            }else{
                navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CategoryViewController") as! CategoryViewController
            vc.currentCategory = categories[indexPath.row-1]
            if let nc = navigationController as? TableNavigationController{
                nc.pushViewController(vc, animated: true, title: self.title!)
            }else{
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}