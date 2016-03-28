//
//  ExtensionFile.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 27/03/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

extension Character{
    
    func isDigit() -> Bool{
        if self >= "0" && self <= "9"{
            return true
        }
        return false
    }
    
}

extension UIAlertController{
    class func showAlertMessage(message : String, inController : UIViewController, withTitle : String, block : (()->())?){
        
        let c = UIAlertController(title: withTitle, message: message, preferredStyle: .Alert)
        c.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {
            _ in
            block?()
        }))
        inController.presentViewController(c, animated: true, completion: nil)
    }
}