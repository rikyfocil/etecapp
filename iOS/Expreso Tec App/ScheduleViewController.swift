//
//  ScheduleViewController.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 10/05/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

/**
 
 This class provides a very conviniento way t load and display the schedule of a route. 
 
 Its responsability of the previous view controller to pass in the desired route
 
 */
public class ScheduleViewController: UIViewController {

    /// The route whose schedule will be displayed
    public var route : Route!
    
    /// The web view that will display the schedule
    @IBOutlet var webView : UIWebView!
    
    /// This override only loads the schedule web page in the web view
    public override func viewDidLoad() {
        
        let url = NSURL(string: route.webImage)
        
        if url == nil{
            return
        }
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        webView.loadRequest(request)
        
    }
    
}
