//
//  RaisedTabBarController.swift
//  drawer
//
//  Created by ChanCyrus on 2/4/16.
//  Copyright © 2016 ChanCyrus. All rights reserved.
//

import UIKit

class RaisedTabBarController: UITabBarController {
  
  // MARK: - lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: - helper functions
  func insertEmptyTabItem(title: String) {
    let vc = UIViewController()
    vc.tabBarItem = UITabBarItem(title: title, image: nil, tag: 0)
    vc.tabBarItem.enabled = false
    
    let midTab:Int = (self.viewControllers?.count)!/2
    self.viewControllers?.insert(vc, atIndex: midTab)
  }
  
  // function to be called to add the raised button, button is added on top of the middle tab bar item to give a vision of raised button
  func addRaisedButton(buttonImage: UIImage?, highlightImage: UIImage?) {
    print(self.tabBar.frame.size.height)
    if let buttonImage = buttonImage {
      let button = UIButton(type: UIButtonType.Custom)
      button.autoresizingMask = [UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleTopMargin]
      
      button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height)
      button.setBackgroundImage(buttonImage, forState: UIControlState.Normal)
      button.setBackgroundImage(highlightImage, forState: UIControlState.Highlighted)
      
      let heightDifference = buttonImage.size.height - self.tabBar.frame.size.height
      
      if (heightDifference < 0) {
        button.center = self.tabBar.center
      }
      else {
        var center = self.tabBar.center
        center.y -= heightDifference / 2.0
        
        button.center = center
      }
      
      button.addTarget(self, action: "onRaisedButton:", forControlEvents: UIControlEvents.TouchUpInside)
      self.view.addSubview(button)
    }
  }
  
  
  // MARK: - Action
  // Action when button is clicked
  func onRaisedButton(sender: UIButton!) {
    
  }
  
}
