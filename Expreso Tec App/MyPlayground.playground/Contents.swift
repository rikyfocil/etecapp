//: Playground - noun: a place where people can play

import UIKit



class User: NSObject {
    
    
    //TODO: Change this for real database connection
    
    
    public func loginWithData(id : String?, password : String?, callback : ((User?, LoginError?)->())? ) throws{
        
        do{
            try validateID(id)
            try validatePassword(password)
            
           
            
        }
        catch{
            if error is LoginError{
                throw error
            }
        }
        
    }
    
    public func validateID(text : String?) throws{
        
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
        
        if !(text.characters.first! == "A" || text.characters.first! == "L"){
            throw LoginError.IDMalformed
        }
        
        for character in text.substringWithRange(text.characters.startIndex.advancedBy(1)..<text.characters.endIndex).characters{
            if !(character >= "0" && character <= "9"){
                throw LoginError.IDMalformed
            }
        }
        
    }
    
    public func validatePassword(text : String?) throws{
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


let user = User()

do{
    try user.loginWithData("A01327311", password: "", callback: nil)
}
catch{
    error
}