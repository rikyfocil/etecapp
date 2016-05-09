//
//  GenericError.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 08/05/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import Foundation

/**
 
 This enum provides a common way to throw errors that are common among all the application. 
 
 This avoid the need of creating a lot of enums with only one case.
 
 */
enum GenericError : ErrorType{
    
    /// An error that happen but with unespecified cause
    case GenericError
    
    /// An error that was raised while parsing a JSON
    case JSONParsingError
    
    /// An error that happended whit a HTTP request
    case HTTPError
    
    /// An error because a malformed web service response. This may occur after updates to the web service.
    case WebSiteError
    
}