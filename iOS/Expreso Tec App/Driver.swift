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
public class Driver: NSObject {
    
    /// The database id that represents the driver
    private let id : Int
    
    /// The drivers name
    public var name : String
    
    /// The route that the driver drive
    private(set) var route : Route
    
    /**
     
     This is the default initiliazer of a driver 
     
     **This method should only be called with the result of a web service call**
     
     - parameter dictionary: The dictionary contatining the driver data. The keys that must be present are:
        + id : Int -> The database id of the driver
        + name : String -> The name of the driver
        + route : NSDictionary -> A dictionary with all the information of the route that the driver drives
     
     - returns: nil if the dictionary is not well formed
     
     */
    public init?(dictionary : NSDictionary){

        let id = dictionary["id"] as? Int
        let name = dictionary["name"] as? String
        let route = dictionary["route"] as? NSDictionary
        
        guard id != nil && name != nil && route != nil else{
            return nil
        }
        
        if let parsedRoute = Route(route: route!){
            self.route = parsedRoute
        }
        else{
            return nil
        }
        
        self.name = name!
        self.id = id!
    
    }
    
}
