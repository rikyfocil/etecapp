//
//  ExtensionFile.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 27/03/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

/**
 This extension provides a method for determining if a certain character is a digit or not
 */
extension Character{
    
    /**
     This method tells wheter a character is a digit (0-9) or not
     
     - returns: A bool telling if the character is in the digit range or not
     
     */
    func isDigit() -> Bool{
        if self >= "0" && self <= "9"{
            return true
        }
        return false
    }
    
}

/**
 This extension provides UIAlertController old style capabilities that allow forming alert messages without having a lot of duplicated code among different view controllers
 */
extension UIAlertController{
    
    /**
     This method show a standard alert message to inform something to the user. 
     
     The user won't have any decision but to accept the alert. The alert will only have an 'ok' option
     
     - parameter message: The body of the alert
     - parameter inController: The controller that is going to present the alert
     - parameter withTitle: The alert view controller title
     - parameter block: An optional code block that is going to be called when the alert is dismissed
     
     */
    class func showAlertMessage(message : String, inController : UIViewController, withTitle : String, block : (()->())?){
        
        let c = UIAlertController(title: withTitle, message: message, preferredStyle: .Alert)
        c.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {
            _ in
            block?()
        }))
        inController.presentViewController(c, animated: true, completion: nil)
    }
    
    /**
     This method is a standard way to confirm potentially dangerous actions to the user. This method is going to be responsable of instanciating and presenting the alert on the view controller.
     
     Also, this method prepares the alert to tell the calling controller the decision that the user took.
     
     - parameter title: A brief string describing what the user is about to do
     - parameter description: The body of the alert. Tipically the consecuences of performing the action
     - parameter confirmText: The text that is going to appear as a confirmation
     - parameter cancelText: The abort action text
     - parameter controller: The controller that is going to present the alert
     - parameter destructive: If this parameter is set to *true* the confirm action is going to appear in red letters to higthligth that its a dangerous action.
     - parameter confirmAction: The code block that should be called when the user accepts the action
     - parameter cancelAction: An optional code block that should perform some clean up actions when the user cancels its decision such as restoring the user interface or toggling switches to the previous state
     
     */
    class func presentConfirmationAlertViewController(title : String, description : String, confirmText : String, cancelText : String, controller : UIViewController, destructive : Bool, confirmAction : ()->(), cancelAction : (()->())?){
        
        let alert = UIAlertController(title: title, message: description, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: confirmText, style: destructive ? .Destructive : .Default , handler: {
            _ in
            confirmAction()
        }))
        alert.addAction(UIAlertAction(title: cancelText, style: .Default, handler: {
            _ in
            cancelAction?()
        }))
        controller.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    /**
     
     This method is a standard way to present an error messge to the user. This method is reponsable for instanciating and presenting the alert on the requested view controller
     
     The user won't have any desicion in this error alert but to accept it.
     
     - parameter title: The title that the alert will have. If no parameter is supplied then *"Error"* will be used
     - parameter description: The description of the error
     - parameter okText: The string that confirms that the user has read the alert. If no parameter is supplied then *"Ok"* will be used
     - parameter controller: The controller that will present the alert
     - parameter completition: An optional code block that is going to be invocked when the user dismisses the alert view
     
     */
    class func presentErrorMessage(title : String = "Error", description : String,  okText : String = "Ok", controller : UIViewController, completition : (()->())?){
        
        let alert = UIAlertController(title: title, message: description, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: okText, style: .Default , handler: {
            
            _ in
            completition?()
            
        }))
        
        controller.presentViewController(alert, animated: true, completion: nil)
        
    }

    
}