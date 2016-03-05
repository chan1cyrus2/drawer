//
//  DetailListViewController.swift
//  drawer
//
//  Created by ChanCyrus on 3/4/16.
//  Copyright © 2016 ChanCyrus. All rights reserved.
//

import UIKit

class DetailListViewController: TableNavigationViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollableView = tableView

        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DetailListViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text = "Title \(indexPath.row + 1)"
        cell.detailTextLabel!.text = "3/4/2016"
        cell.imageView!.image = UIImage(named: "Receipt.jpg")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        cell.imageView
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
}
