//
//  Driver.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 08/05/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

/**
 
 This is the model that represents a driver user on the application
 
 This object should be instanciated via *login*
 */
class Driver: NSObject {
    
    /// The database id that represents the driver
    private var id : Int = 0
    
    /// The drivers name
    private(set) var name = ""
    
    /// The route that the driver drive
    private(set) var route = Route(id: 8, color: UIColor.greenColor(), name: "San manuel", conductor: "Carlos")
    
    /**
     
     This method is a class function that will request the webservice for logging in a certain driver.
     
     **Note:** In order for a driver to login he must accomplish 2 conditions
     1. ID and password match a database tuple
     2. The driver is assigned to a route

     - parameter databaseID: The ID that uniquely identifies the driver
     - parameter password: The password supplied by the user
     - parameter callback: The code block that should be called when the action is complete. 
        + Driver?: The logged in driver 
        + LoginError?: The reason that explains why *Driver?* is nil
     
     */
    class func login(databaseID : String, password : String, callback: (Driver?, LoginError?)->()){
        
        let d = Driver()
        d.id = 1
        d.name = "Carlos"
        
    }
    
    /// To be removed when final login is ready
    @available(*, deprecated=9.0)
    private override init(){}
    
}
