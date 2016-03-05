//
//  TableNavigationViewController.swift
//  TableNavigation
//
//  Created by ChanCyrus on 3/1/16.
//  Copyright © 2016 ChanCyrus. All rights reserved.
//

import UIKit

class TableNavigationViewController: UIViewController {
    
    // MARK: - properties
    //scrollView that is used to scroll with the Table Navigation Controller
    var scrollableView: UIScrollView?
    
    // MARK: - lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Adjust the frame of the scrollableView due to the change of the tableView in Navigation Controller
        if let nvc = navigationController as? TableNavigationController{
            if let sv = scrollableView {
                sv.contentInset.top = nvc.fullNavBarHeight
                print(sv.contentInset.top)
                sv.scrollIndicatorInsets.top = sv.contentInset.top
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let navigationController = self.navigationController as? TableNavigationController {
            navigationController.stopFollowingScrollView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
