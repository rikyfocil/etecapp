//
//  LoginSystem.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 09/05/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit


/**
 
 This class provides tha standard way to retrive users and drivers.
 
 Its methods should be used to validate data and to create user representations from the database.
 
 */
public class LoginSystem: NSObject {

    
    /**
     
     This method can verify if the user id is valid or not
     
     - parameter text: The id that needs to be validated
     
     - throws: LoginError if the id is not in the right formed
     
     */
    public class func validateID(text : String?) throws{
        
        guard let text = text else{
            throw LoginError.IDNull
        }
        
        if text.isEmpty{
            throw LoginError.IDEmpty
        }
        
        if text.characters.count != 9{
            throw LoginError.IDInvalidLength
        }
        
        //Validate string formation
        
        let upperTextFirstLetter = text.uppercaseString.characters.first!
        
        if !(upperTextFirstLetter == "A" || upperTextFirstLetter == "L" || upperTextFirstLetter == "D"){
            throw LoginError.IDMalformed
        }
        
        for character in text.substringWithRange(text.characters.startIndex.advancedBy(1)..<text.characters.endIndex).characters{
            if !character.isDigit(){
                throw LoginError.IDMalformed
            }
        }
        
    }
    
    /**
     
     This method can verify if the user password is valid or not
     
     - important: Even if this method doesn't throw an error that doesn't mean the password is associated with the user. It just means that is a valid password for any user.
     
     - parameter text: The id that needs to be validated
     
     - throws: LoginError if the password is not in the right formed
     
     
     */
    public class func validatePassword(text : String?) throws{
        guard let text = text else{
            throw LoginError.PasswordNull
        }
        
        if text.isEmpty{
            throw LoginError.PasswordEmpty
        }
        
        if text.characters.count < 6{
            throw LoginError.PasswordTooShort
        }
    }
    
    
    /**
     
     This method provides a way to validate if a login is valid for logging standard users.
     
     - parameter text: The id that needs to be validated
     
     - throws: LoginError if the id is not valid for logging standard users
     
     */
    public class func validateIDForStandardUser(text : String?) throws{
        
        do{
            
            try validateID(text)
            
            let character = text!.capitalizedString.characters.first!
            
            if !(character == "A" || character == "L"){
                throw LoginError.IDInvalidForLoginFunction
            }
        
        }
        catch{
            throw error
        }
        
    }
    
    
    /**
     
     This method provides a way to validate if a login is valid for drivers.
     
     Its guaranteed that if the id is valid and is not a rider one then is a driver one
     
     - parameter text: The id that needs to be validated
     
     - throws: LoginError if the id is not valid for logging drivers
     
     */
    public class func validateIDForDrivers(text : String?) throws{
        
        do{
            
            try validateID(text)
            
            if (try? validateIDForStandardUser(text)) != nil{
                throw LoginError.IDInvalidForLoginFunction
            }
            
        }
        catch{
            throw error
        }
        
    }
    
    /**
     
     This is the standard way to create a User or Driver.
     
     The app will automatically determine which kind of user it should login.
     
     Thi method will recieve three callbacks. Its guarantee that this function will only call one of them.
     
     - parameter id: The id that identifies the user
     - parameter password: The user associated password
     - parameter userSuccess: A block of code that should be called with the logged user
     - parameter driverSuccess: A block of code that should be called with the logged in driver
     - parameter errorCallback: An error explaining why nor a driver nor a driver where logged in
    
     */
    public class func loginWithData(id : String?, password : String?, userSuccess : (User)->(), driverSuccess : (Driver)->(), errorCallback : (LoginError)->() ){
        
        do{
            
            try LoginSystem.validatePassword(id)
            try LoginSystem.validatePassword(password)
            
            let params = HTTPRequestSimplified.generateParamString(["username":id!.uppercaseString, "password":password!])
            
            var route = ""
            var rider = true
            
            do{
            
                try LoginSystem.validateIDForStandardUser(id)
                //Rider case
                route = "mobileLogin"
                
            }
            catch{
                
                //By this point we are on the driver case 
                route = "driverLogin"
                rider = false
            
            }
            
            let request = HTTPRequestSimplified.getStandardOnlyTextRequest(route, method: .POST, httpdata: params)
            
            HTTPRequestSimplified.getDictionaryOfParsingJSONFromRequest(request, callback: {
                
                (loginDictionaryOptional, error) in
                
                if let error = error{
                    
                    print("Error. Error while attempting to login user. Dictionary was not formed\n\(error)\n \(#file):\(#line)")
                    errorCallback(LoginError.ApiMalformed)
                    return
                    
                }
                
                let dictionary = loginDictionaryOptional!
                
                if let message = dictionary["result"] as? String where message == "success"{
                    
                    if rider{
                    
                        if let user = User(dictionary: dictionary){
                            userSuccess(user)
                        }
                        else{
                            errorCallback(LoginError.ApiMalformed)
                        }
                    
                    }
                    else{
                        
                        if let driver = Driver(dictionary: dictionary){
                            driverSuccess(driver)
                        }
                        else{
                            errorCallback(LoginError.ApiMalformed)
                        }
                    
                    }
                    
                }
                else{
                    errorCallback( LoginError.InvalidData )
                }
                
            })
            
        }
        catch{
            
            guard let error = error as? LoginError else{
                fatalError("Unexpected error thrown")
            }
            
            errorCallback(error)
            return
        }
        
    }

    
}
