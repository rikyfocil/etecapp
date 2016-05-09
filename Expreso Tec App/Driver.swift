//
//  Driver.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 08/05/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit


class Driver: NSObject {

    private var id : String = ""
    private(set) var name = ""
    private(set) var route = Route(id: 8, color: UIColor.greenColor(), name: "San manuel", conductor: "Carlos")
    
    
    
    
    class func login(databaseID : String, password : String, callback: (Driver?)->()){
        
        let d = Driver()
        d.id = "3"
        d.name = "Carlos"
        
    }
    
    private override init(){}
    
}
