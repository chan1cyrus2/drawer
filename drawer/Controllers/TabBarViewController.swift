//
//  TabBarViewController.swift
//  drawer
//
//  Created by ChanCyrus on 2/4/16.
//  Copyright © 2016 ChanCyrus. All rights reserved.
//

import UIKit

class TabBarViewController: RaisedTabBarController {
  
  // MARK: - lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Insert empty tab item at center index. In this case we have 5 tabs.
    self.insertEmptyTabItem("")
    
    // Raise the center button with image
    let img = UIImage(named: "PlusIcon")
    self.addRaisedButton(img, highlightImage: nil)
  }
  
  // MARK: - Handler
  override func onRaisedButton(sender: UIButton!) {
    super.onRaisedButton(sender)
    
    print("Raised button tapped")
  }
}
