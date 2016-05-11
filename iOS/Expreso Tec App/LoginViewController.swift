//
//  ViewController.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 27/03/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

/**
 
 This class is the first view controller that the user see. This class provide Model and UI logic that validates his input and validates the data.
 
 This class is also responsible for calling the appopiate method according to the introduced ID and to change the screen when the user is logged.
 
 */
public class LoginViewController: UIViewController, UITextFieldDelegate {

    /// The text field in whic the user introduces his id
    @IBOutlet weak var idTextField: UITextField!
    /// The secured text field in which the user enters his password
    @IBOutlet weak var passwordTextField: UITextField!
    /// The view that blocks all the content when the user validation is on progress
    @IBOutlet weak var opaqueView: UIView!
    /// This is a subvvar of *opaqueView* and its function is to tell the user that there is an action in progress.
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    /**
     
     This method is called when the user press the login button. This class will do the following
     
     + Block the user content to avoid more calls to login.
     + Call the user login block TODO: select between driver and user and make inherance between this classes.
     + In case of error, see which error is responsable and tell the user about it.
     + Otherwise reset the testfields and present the corresponding screen
     
     - parameter sender: The ibject that triggered the method **Will allways be ignored**
     
     */
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        
        func unblockUI(){
        
            self.opaqueView.hidden = true
            self.view.userInteractionEnabled = true
        
        }
        
        func resetTextFields(){
            
            self.idTextField.text = ""
            self.passwordTextField.text = ""
        
        }
        
        self.view.userInteractionEnabled = false
        self.opaqueView.hidden = false
        self.indicatorView.startAnimating()
        
        LoginSystem.loginWithData(self.idTextField.text, password: self.passwordTextField.text, userSuccess: {
            
            (user) in
            unblockUI()
            self.performSegueWithIdentifier("showMap", sender: user)
            resetTextFields()
            
        }, driverSuccess: {
            
            (driver) in
            unblockUI()
            self.performSegueWithIdentifier("driverLogin", sender: driver)
            resetTextFields()
        
        }) {
            
            (le) in
            
            unblockUI()
            switch le {
            case .IDEmpty, .IDNull:
                UIAlertController.showAlertMessage("Por favor introduce tu Matrícula / Nómina / Identificador", inController: self, withTitle: "Error", block: {
                    self.idTextField.becomeFirstResponder()
                })
            
            case .IDInvalidLength, .IDMalformed:
                UIAlertController.showAlertMessage("Tu identificador es incorrecto. Por favor verifica que tenga 9 caracteres y que este formado como A, L o D seguido 8 números", inController: self, withTitle: "Error", block: {
                    self.idTextField.becomeFirstResponder()
                })
            
            case .PasswordEmpty, .PasswordNull:
                UIAlertController.showAlertMessage("Por favor introduce tu contraseña", inController: self, withTitle: "Error", block: {
                    self.passwordTextField.becomeFirstResponder()
                })
            
            case .PasswordTooShort:
                UIAlertController.showAlertMessage("Parece que el password es muy corto. Por favor intentalo de nuevo con tu contraseña del ITESM", inController: self, withTitle: "Error", block: {
                    self.passwordTextField.becomeFirstResponder()
                })
            
            case .InvalidData:
                UIAlertController.showAlertMessage("Parece que los datos son incorrectos. Por favor intentalo de nuevo con los datos de tu cuenta del ITESM", inController: self, withTitle: "Error", block: nil)
                
            default:
                UIAlertController.showAlertMessage("Parece que algo anda mal. Por favor verifica tu conexión a Internet y vuelve a intentarlo", inController: self, withTitle: "Error", block: nil)
            }

        }
    }
    
    /**
     
     This override only provide the following behaviors:
     
     + Register the class for moving the view when a keyboard comes to it
     + Adds a gesture recognizer to dismiss the keyboard
     
     */
    override public func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.showKeyboard(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.hideKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard)))
    }
    
    /**
        
     This method dissmises any editinf action that is going on on the controller
     
     Tipically its triggered when the user triggers the tap gesture recognizer or when he taps the login button
     
     */
    public func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    /**
     
     **This method should only be called by *NSNotificationCenter***
     
     This method should calculate the size of the keyboard and ove the view so the *firstResponder* is not hided.
     
     - parameter aNotification: The generated NSNotification
     
     */
    public func showKeyboard(aNotification : NSNotification){
        
        let kbRect = aNotification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        
        let textField = self.idTextField.isFirstResponder() ? self.idTextField : self.passwordTextField
        let realTextFieldFrame = textField.convertRect(textField.frame, toView: nil)
        
        if realTextFieldFrame.origin.y + realTextFieldFrame.size.height > kbRect!.origin.y{
            let offset = (realTextFieldFrame.origin.y + realTextFieldFrame.size.height) - (kbRect!.origin.y)
            self.view.frame.origin.y -= offset
        }
        
    }
    
    /**
     
      **This method should only be called by *NSNotificationCenter***
     
     This method should restore the view position after the keyboard is dismissed
     
     - parameter aNotification: The generated NSNotification **This parameter is allways ignored**
     
     */
    public func hideKeyboard(aNotification : NSNotification){
        self.view.frame.origin.y = 0
    }
    
    /**
     
     Default delegate implementation for *UITextField*
     
     This method provides the following behavior:
     
     + If the id is the current responder then the password becomes the first responder
     + If the password is the current responder the ogin is triggered
     
     - returns: true
     
     */
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == idTextField{
            self.passwordTextField.becomeFirstResponder()
        }
        else{
            self.passwordTextField.resignFirstResponder()
            loginButtonPressed(self.passwordTextField)
        }
        return true
    }
    
    /**
     
     This method is a way for any controller to go back to the login screen
     
     - parameter segue: The storyboard swgue including information such as the view controller that trigered it **Right now this parameter is ignored**
     
     */
    @IBAction func backToLoginViewController(segue : UIStoryboardSegue){}
    
    /**
     
     This override provides the following behaviors: 
     
     + if the segue is because of a normal user login, it will pass the user to the *MapViewController*
     
     - parameter segue: The storybooard segue containing information such as *destinationViewController* and *identifier*
     - parameter sender: This param vary according to the login type:
        + *showMap* segue should have a user as a sender
     
     */
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMap"{
            let nvc = segue.destinationViewController as! UINavigationController
            let vc = nvc.viewControllers[0] as! MapViewController 
            vc.user = sender as! User
        }
        else if segue.identifier == "driverLogin"{
            
            let dvc = segue.destinationViewController as! DriverViewController
            dvc.driver = sender as! Driver
            
        }

    }
}
