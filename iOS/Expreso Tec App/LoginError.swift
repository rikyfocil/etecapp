//
//  LoginError.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 09/05/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import Foundation

/**
 
 This enum provides a set of all errors that can occur during a Login.
 
 */
public enum LoginError : ErrorType{
 
    /// The id provided is empty
    case IDEmpty
    /// The id provided does not contains 9 characters
    case IDInvalidLength
    /// The id is not on the format (A | L | D)[0-9]{8}
    case IDMalformed
    /// The id provided was nil
    case IDNull
    /// The id does not correspond to the attempted login (DXXXXXXXX for loging user or [AL](0-9){8} for logging a driver
    case IDInvalidForLoginFunction
    
    /// The password provided was empty
    case PasswordEmpty
    /// The password provided was nil
    case PasswordNull
    /// The password length was unaceptable by the ITESM system
    case PasswordTooShort
    
    /// The login data was not correct
    case InvalidData
    /// The web service response have changed. This may mean an update available.
    case ApiMalformed
    
    /// The error reason is not known
    case UnknownError
}
