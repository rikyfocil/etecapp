//
//  User.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 27/03/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

public class User: NSObject {

    
    public let user : String
    public let name : String
    
    private init(name : String, user : String){
        self.name = name
        self.user = user
    }
    
    //TODO: Change this for real database connection
    private static let dictionary = ["A01327311" : "testing1", "A01327312" : "testing2" , "A01327313" : "testing3"]
    
    public class func loginWithData(id : String?, password : String?, callback : (User?, LoginError?)->()){
        
        do{
            try validateID(id)
            try validatePassword(password)
            
            
            
            let delay = 2 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                if self.dictionary.keys.contains(id!.capitalizedString) && self.dictionary[id!.capitalizedString] == password!{
                    callback(User(name : "Nombre del usuario", user: id!.capitalizedString), nil)
                }
                else{
                    callback(nil, LoginError.InvalidData)
                }
            })
        }
        catch{
            
            guard let error = error as? LoginError else{
                fatalError("Unexpected error thrown")
            }
            
            callback(nil,error)
            return
        }
        
    }
    
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
        
        if !(text.characters.first! == "A" || text.characters.first! == "L" || text.characters.first! == "l" || text.characters.first! == "a"){
            throw LoginError.IDMalformed
        }
        
        for character in text.substringWithRange(text.characters.startIndex.advancedBy(1)..<text.characters.endIndex).characters{
            if !character.isDigit(){
                throw LoginError.IDMalformed
            }
        }

    }
    
    class func validatePassword(text : String?) throws{
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
    
}

public enum LoginError : ErrorType{
    case IDEmpty
    case IDInvalidLength
    case IDMalformed
    case IDNull
    
    case PasswordEmpty
    case PasswordNull
    case PasswordTooShort

    case InvalidData
    case UnknownError
}
