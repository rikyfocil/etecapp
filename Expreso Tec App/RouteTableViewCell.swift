//
//  RouteTableViewCell.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 22/04/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

/**
 
 This class is associated with a table view cell on interface builder
 
 The main purpose of this class is to provide an easy way to configure a cell with a route
 
 */
public class RouteTableViewCell: UITableViewCell {
    
    /// A subview that illustrate the color of the route.
    @IBOutlet weak var colorView: UIView!
    
    /// The label that displays the route name
    @IBOutlet weak var routeNameLabel: UILabel!
    
    /**
     
     The route that the cell displays. Setting this property autoatically configures the cell with the following behavior:
     
     + Not nil Route: The cell is configured to display the Route information.
     + Nil Route: The cell information is cleaned up.
     
     */
    public var route : Route?{

        didSet{
            
            if let newRoute = route{
                
                colorView.backgroundColor = newRoute.color
                routeNameLabel.text = "\(newRoute.id). \(newRoute.name)"
                
            }
            else{
            
                colorView.backgroundColor = UIColor.clearColor()
                routeNameLabel.text = ""
                
            }
        }

    }

}
