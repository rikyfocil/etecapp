//
//  RouteTableViewCell.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 22/04/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

public class RouteTableViewCell: UITableViewCell {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var routeNameLabel: UILabel!
    
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
