//
//  ViewController.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 27/03/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var opaqueView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        self.view.userInteractionEnabled = false
        self.opaqueView.hidden = false
        self.indicatorView.startAnimating()
        User.loginWithData(self.idTextField.text, password: self.passwordTextField.text, callback: {
            
            (logedUser, loginError) in
            
            self.opaqueView.hidden = true
            self.view.userInteractionEnabled = true
            if let le = loginError{
                switch le {
                case .IDEmpty, .IDNull:
                    UIAlertController.showAlertMessage("Please insert your ID", inController: self, withTitle: "Error", block: {
                        self.idTextField.becomeFirstResponder()
                    })
                case .IDInvalidLength, .IDMalformed:
                    UIAlertController.showAlertMessage("Your ID is wrong. Please check that it has its 9 characters and its formed like A or L followed by 8 numbers", inController: self, withTitle: "Error", block: {
                        self.idTextField.becomeFirstResponder()
                    })
                case .PasswordEmpty, .PasswordNull:
                    UIAlertController.showAlertMessage("Please insert your password", inController: self, withTitle: "Error", block: {
                        self.passwordTextField.becomeFirstResponder()
                    })
                case .PasswordTooShort:
                    UIAlertController.showAlertMessage("It seems like the entered password is too short. Please try again with your ITESM password", inController: self, withTitle: "Error", block: {
                        self.passwordTextField.becomeFirstResponder()
                    })
                case .InvalidData:
                    UIAlertController.showAlertMessage("It seems like the entered data is wrong. Please try again with your ITESM account", inController: self, withTitle: "Error", block: {
                        self.idTextField.becomeFirstResponder()
                    })
                
                default:
                    UIAlertController.showAlertMessage("It seems like something is wrong. Please check your Internet or try again later", inController: self, withTitle: "Error", block: {
                        self.idTextField.becomeFirstResponder()
                    })
                }
            }
            
            else if let _ = logedUser{
                
                self.performSegueWithIdentifier("showMap", sender: nil)
                self.idTextField.text = ""
                self.passwordTextField.text = ""
                
            }
            else{
                fatalError("Both user and error cannot be nil.")
            }
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.showKeyboard(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.hideKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard)))
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func showKeyboard(aNotification : NSNotification){
        
        let kbRect = aNotification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        
        let textField = self.idTextField.isFirstResponder() ? self.idTextField : self.passwordTextField
        let realTextFieldFrame = textField.convertRect(textField.frame, toView: nil)
        
        if realTextFieldFrame.origin.y + realTextFieldFrame.size.height > kbRect!.origin.y{
            let offset = (realTextFieldFrame.origin.y + realTextFieldFrame.size.height) - (kbRect!.origin.y)
            self.view.frame.origin.y -= offset
        }
        
    }
    
    func hideKeyboard(aNotification : NSNotification){
        self.view.frame.origin.y = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == idTextField{
            self.passwordTextField.becomeFirstResponder()
        }
        else{
            self.passwordTextField.resignFirstResponder()
            loginButtonPressed(self.passwordTextField)
        }
        return true
    }
    
    
    @IBAction func backToLoginViewController(segue : UIStoryboardSegue){}
}
