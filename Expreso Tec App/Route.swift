//
//  Route.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 22/04/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

public class Route : NSObject{

    public let conductor : String
    public let name : String
    public let color : UIColor
    public let id : Int
    
    init(id : Int, color : UIColor, name : String, conductor : String) {
        
        self.id = id
        self.color = color
        self.name = name
        self.conductor = conductor
        
    }
    
}