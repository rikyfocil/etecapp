//
//  Route.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 22/04/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

/**
 This class is the model that represents a route.
 */
public class Route : NSObject{
    
    /// The name of the driver that drives the route
    public let conductor : String
    
    /// The name of the route
    public let name : String
    
    /// The color that represents the route
    public let color : UIColor
    
    /// The identifier on the database of the route
    public let id : Int
    
    /// The site that should be requested to check the bus schedule
    public let webImage : String

    
    /**
     This function tells if another route is equal by comparing the id
     
     - parameter object: An object to compare. This object must be a route or the behavior is the one of the superclass
     
     - returns: A bool telling if the objects should be considered equal 
     */
    public override func isEqual(object: AnyObject?) -> Bool {
        
        if let route = object as? Route{
            return self.id == route.id
        }
        
        return super.isEqual(object)
        
    }
    
    /**
     
     This is the default constructor for a route
     
     **Never attempt to create a route with a custom created dictionary** 
     The success of all the application depends on the database data. Because of this if there are routes without its correspondent database instance weird errors may occur.
     
     - parameter route: A dictionary containing the route information. The dictionary must contain the following fields:
        + name : String -> The name of the route
        + id : Int -> The id that represents this route in the database
        + driver : String -> The drivers name
        + color : String -> A hex string that represent the color of the route (#FFFFFF)
        + page : String -> The web page linked to the current schedule
     
     */
    public init?(route : NSDictionary?){
        
        guard let routeDictionary = route else{
            return nil
        }
        
        let name = routeDictionary["name"] as? String
        let id = routeDictionary["id"] as? Int
        let driver = routeDictionary["driver"] as? String
        let color = UIColor(fromHexHashtagedString: (routeDictionary["color"] as? String) ?? "")
        let webPage = routeDictionary["page"] as? String
        
        guard name != nil && id != nil && driver != nil && color != nil && webPage != nil else{
            return nil
        }
        
        self.name = name!
        self.id = id!
        self.conductor = driver!
        self.color = color!
        self.webImage = webPage!
    }
    
}