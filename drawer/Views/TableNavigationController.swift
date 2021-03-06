//
//  TableNavigationController.swift
//  TableNavigation
//
//  Created by ChanCyrus on 3/1/16.
//  Copyright © 2016 ChanCyrus. All rights reserved.
//

import UIKit

class TableNavigationController: UINavigationController {
    
    // MARK: - Structs
    enum NavigationBarState { case Collapsed, Scrolling, Expanded }
    
    // MARK: - Properties
    var state:NavigationBarState = .Expanded
    
    var originalNavBarHeight: CGFloat = 44.0
    
    var tableView: UITableView!
    var tableViewContainer: UIView!
    var tableData: [String] = []
    var tableCellHeight:CGFloat = 25.0
    
    var gestureRecognizer: UIPanGestureRecognizer?
    
    var scrollableView: UIScrollView? // UIView that TableNav would follow to scroll
    var scrollingEnabled = false // Determine if TableNav should enable scrolling
    var scrollUpDelay = CGFloat(0.0)
    var scrollDownDelay = CGFloat(0.0)
    var currentDelay = CGFloat(0.0)
    
    var lastYTranslation = CGFloat(0.0) // Keep track of the pan gesture translation before user's finger is up
    
    // MARK: - computed properties
    var statusBarHeight: CGFloat { return UIApplication.sharedApplication().statusBarFrame.size.height}
    // (tableView + NavigationBar) view offset from status bar
    var tableNavY: CGFloat {
        get {
            return tableView.frame.origin.y
        }
        set {
            tableView.frame.origin.y = newValue
            tableViewContainer.frame.size.height = tableView.frame.size.height + tableView.frame.origin.y
            navigationBar.frame.size.height = originalNavBarHeight + tableViewContainer.frame.size.height
        }
    }
    // tableView.frame.size.height, it resets everything to default position everytime size change
    var tableNavHeight: CGFloat {
        get {
            return tableView.frame.size.height
        }
        set {
            tableView.frame.origin.y = 0
            tableView.frame.size.height = newValue
            tableViewContainer.frame.size.height = newValue
            navigationBar.frame.size.height = originalNavBarHeight + tableViewContainer.frame.size.height
        }
    }
    var tableViewHeight: CGFloat { return tableView.frame.height }
    var fullTableViewHeight: CGFloat { return statusBarHeight + tableViewHeight }
    var navBarY: CGFloat { return navigationBar.frame.origin.y }
    var navBarHeight: CGFloat { return navigationBar.frame.height }
    var fullNavBarHeight: CGFloat { return statusBarHeight + navBarHeight }
    var scrollLimit: CGFloat { return tableView.frame.size.height }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableViewContainer
        tableViewContainer = UIView()
        var frame = view.frame
        frame.size.height = 0
        frame.origin.y = statusBarHeight
        tableViewContainer.frame = frame
        tableViewContainer.clipsToBounds = true
        view.addSubview(tableViewContainer)
        
        // tableView
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.scrollEnabled = false
        tableViewContainer.addSubview(tableView)
        frame = view.frame
        frame.size.height = 0
        frame.origin.y = 0
        tableView.frame = frame
        tableView.backgroundColor = UIColor.clearColor()
        
        // Register custom cell
        let nib = UINib(nibName: "TableNavigationViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "cell")
        
        // Navigationbar
        originalNavBarHeight = navigationBar.frame.size.height
    }
    
    /*override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    tableNavHeight = tableCellHeight * (CGFloat)(tableData.count)
    tableView.reloadData()
    print(navigationBar.frame.size.height)
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation Controller
    func pushViewController(viewController: UIViewController, animated: Bool, title: String){
        tableData.append(title)
        self.pushViewController(viewController, animated: animated)
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        tableNavHeight = tableCellHeight * (CGFloat)(tableData.count)
        tableView.reloadData()
    }
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        let vc = super.popViewControllerAnimated(animated)
        
        tableData.removeLast()
        tableNavHeight = tableCellHeight * (CGFloat)(tableData.count)
        tableView.reloadData()
        return vc
    }
    
    override func popToViewController(viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let vcs = super.popToViewController(viewController, animated: animated)
        
        for var index = 0; index < (vcs?.count)!; ++index {
            tableData.removeLast()
        }
        tableNavHeight = tableCellHeight * (CGFloat)(tableData.count)
        tableView.reloadData()
        
        return vcs
    }
    
    // MARK: - public functions
    func followScrollView(scrollableView: UIScrollView, scrollUpDelay: CGFloat = 0, scrollDownDelay: CGFloat = 0){
        self.scrollableView = scrollableView
        
        gestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        gestureRecognizer?.delegate = self
        gestureRecognizer?.maximumNumberOfTouches = 1
        scrollableView.addGestureRecognizer(gestureRecognizer!)
        
        scrollingEnabled = true
        self.scrollUpDelay = scrollUpDelay
        self.scrollDownDelay = scrollDownDelay
    }
    
    //Stop observing the view and reset the navigation bar
    func stopFollowingScrollView() {
        if let gesture = gestureRecognizer {
            scrollableView?.removeGestureRecognizer(gesture)
        }
        scrollableView = .None
        gestureRecognizer = .None
        scrollingEnabled = false
    }
    
    // MARK: - PanGestureRecognizer action functions
    func handlePanGesture(gesture: UIPanGestureRecognizer){
        if let superview = scrollableView?.superview {
            let translation = gesture.translationInView(superview)
            let delta = translation.y - lastYTranslation  // delta to check whether the current finger motion is up (-) or down (+)
            lastYTranslation = translation.y
            
            if shouldScrollWithDelta(delta) {
                scrollWithDelta(delta)
            }
        }
        
        // check if the gesture/finger has ended/untouched, then reset last translation and considering whether table nav bar should collapse
        if gesture.state == .Ended || gesture.state == .Cancelled {
            checkForPartialScroll()
            lastYTranslation = 0
        }
    }
    
    // Determine whether table navigation should scroll
    private func shouldScrollWithDelta(delta: CGFloat) -> Bool {
        // no need to scroll if content fits
        if let scrollableView = scrollableView where scrollableView.frame.size.height > scrollableView.contentSize.height{
            return false
        }
        // down
        if (delta > 0){
            // check if we are swiping down within content size (not swiping on contentinet bottom)
            if let scrollableView = scrollableView where scrollableView.contentOffset.y + scrollableView.frame.size.height > scrollableView.contentSize.height {
                return false
            }
        } else { //up
            //check if we are swiping up within content size (not swiping on contentinet top)
            if let scrollableView = scrollableView where scrollableView.contentOffset.y + scrollableView.contentInset.top < 0 {
                return false
            }
        }
        return true
    }
    
    private func scrollWithDelta(delta: CGFloat) {
        // View scrolling up, hide the navbar
        if delta < 0 {
            // Update the delay
            currentDelay -= delta
            
            // Skip if it is already Collapsed
            if state == .Collapsed { return }
            
            // Skip if the delay is not over yet
            if currentDelay < scrollUpDelay {
                return
            }
            
            if tableNavY + delta < -scrollLimit {
                //navigationBar.frame.origin.y = statusBarHeight - scrollLimit
                tableNavY = -scrollLimit
            } else {
                //navigationBar.frame.origin.y += delta
                tableNavY += delta
            }
            
            // Detect when the bar is completely collapsed
            if tableNavY <= -scrollLimit{
                print("state is collapsed")
                state = .Collapsed
                currentDelay = 0
            } else {
                print("state is scrolling")
                state = .Scrolling
                currentDelay = max(scrollDownDelay, scrollUpDelay)
            }
        }
        
        // View scrolling down
        if delta > 0 {
            // Update the delay
            currentDelay += delta
            
            // Skip if it is already Collapsed
            if state == .Expanded { return }
            
            // Skip if the delay is not over yet, only when the current content is big enough
            //if scrollableView?.contentOffset.y > 0 {
            if currentDelay < scrollDownDelay { return }
            
            if tableNavY + delta > 0 {
                //navigationBar.frame.origin.y = statusBarHeight - scrollLimit
                tableNavY = 0
            } else {
                //navigationBar.frame.origin.y += delta
                tableNavY += delta
            }
            
            // Detect when the bar is completely expanded
            if tableNavY >= 0{
                print("state is expanded")
                state = .Expanded
                currentDelay = 0
            } else {
                print("state is scrolling")
                state = .Scrolling
            }
        }
    }
    
    private func checkForPartialScroll(){
        var duration = NSTimeInterval(0)
        
        if state == .Collapsed { return }
        
        // always scroll down to show full table if it is in partial scroll
        if tableNavY < 0 {
            duration = NSTimeInterval(abs((tableNavY / (scrollLimit / 2)) * 0.2))
            state = .Expanded
        }
        
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.tableNavY = 0
            // Hide all possible button items and navigation items
            func shouldHideView(view: UIView) -> Bool {
                let className = view.classForCoder.description()
                return className == "UINavigationButton" ||
                    className == "UINavigationItemView" ||
                    className == "UIImageView" ||
                    className == "UISegmentedControl"
            }
            self.navigationBar.subviews
                .filter(shouldHideView)
                .forEach {
                    // update later for backbutton
                    //print($0)
                    $0.alpha = 100
            }
            
            if let navigationItem = self.visibleViewController?.navigationItem{
                
                // Hide the left items
                navigationItem.leftBarButtonItem?.customView?.alpha = 0
                if let leftItems = navigationItem.leftBarButtonItems {
                    leftItems.forEach { $0.customView?.alpha = 0 }
                }
                
                // Hide the right items
                navigationItem.rightBarButtonItem?.customView?.alpha = 0
                if let leftItems = navigationItem.rightBarButtonItems {
                    leftItems.forEach { $0.customView?.alpha = 0 }}
                
                // Hide the back items
                print(navigationItem.backBarButtonItem?.customView)
                navigationItem.backBarButtonItem?.customView?.alpha = 0}
            
            }, completion: nil)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension TableNavigationController: UIGestureRecognizerDelegate{
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return scrollingEnabled
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TableNavigationController: UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TableNavigationViewCell
        
        cell.label?.text = tableData[indexPath.row]
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get the associated category item
        popToViewController(viewControllers[indexPath.row], animated: true)
    }
}

