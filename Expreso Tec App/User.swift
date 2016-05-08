//
//  User.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 27/03/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

public class User: NSObject {

    
    public let userID : String
    public let name : String
    private var databaseID = 0

    public private(set) var loadedRoutes = false;
    public private(set) var subscribedRoutes = [Route]()
    
    //TODO: Change for private
    internal init(name : String, userID : String){
        self.name = name
        self.userID = userID
    }
    
    //TODO: Change this for real database connection
    private static let dictionary = ["A01327311" : "testing1", "A01327312" : "testing2" , "A01327313" : "testing3"]
    
    private var listOfRouteChangingObservs = Array< (User, didUpdateRoutes : [Route] )->(Bool) >()
    
    public class func loginWithData(id : String?, password : String?, callback : (User?, LoginError?)->()){
        
        do{
            try validateID(id)
            try validatePassword(password)
            
            
            
            let delay = 2 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                if self.dictionary.keys.contains(id!.capitalizedString) && self.dictionary[id!.capitalizedString] == password!{
                    callback(User(name : "Nombre del usuario", userID: id!.capitalizedString), nil)
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
    
    func registerForRouteChangingNotifications( notificationHandler : (User, didUpdateRoutes : [Route] )->(Bool)  ){
        self.listOfRouteChangingObservs.append(notificationHandler)
    }
    
    func updateRouteSubscriptions( routes : [Route], doneCallback : (Bool)->() ){
        
        var deSuscribedroutes = [Route]()
        var subcribingRoutes = [Route]()
        
        for route in routes{
            if !subscribedRoutes.contains(route){
                subcribingRoutes.append(route)
            }
        }
        
        for route in subscribedRoutes{
            if !routes.contains(route){
                deSuscribedroutes.append(route)
            }
        }
        
        if subcribingRoutes.isEmpty && deSuscribedroutes.isEmpty{
            doneCallback(true)
        }
        
        var allCompleted = true
        var toLoad = deSuscribedroutes.count + subcribingRoutes.count
        
        func complete(){
            
            doneCallback(allCompleted)
            
            var i = 0
                
            while i < listOfRouteChangingObservs.count {
                if !listOfRouteChangingObservs[i](self, didUpdateRoutes: self.subscribedRoutes){
                    _ = listOfRouteChangingObservs.removeAtIndex(i)
                }
                else{
                    i+=1
                }
            }
            
        }
        
        for route in subcribingRoutes{
            
            let request = HTTPRequestSimplified.getStandardOnlyTextRequest("subscribe", httpdata: HTTPRequestSimplified.generateParamString([ "profileId" : "\(self.databaseID)", "routeId" : "\(route.id)" ]))
            
            HTTPRequestSimplified.getDictionaryOfParsingJSONFromRequest(request, callback: {
                
                (dictionary, generatedError) in
                
                
                if generatedError != nil || dictionary!["message"] as? String != "success"{
                    allCompleted = false
                }
                else{
                    self.subscribedRoutes.append(route)
                }
                
                toLoad -= 1
                
                if toLoad == 0{
                    complete()
                }

            })
        }
        
        for route in deSuscribedroutes{
            
            let request = HTTPRequestSimplified.getStandardOnlyTextRequest("unsubscribe", httpdata: HTTPRequestSimplified.generateParamString([ "profileId" : "\(self.databaseID)", "routeId" : "\(route.id)" ]))
            
            HTTPRequestSimplified.getDictionaryOfParsingJSONFromRequest(request, callback: {
                
                (dictionary, generatedError) in
                
                
                if generatedError != nil || dictionary!["message"] as? String != "success"{
                    allCompleted = false
                }
                else{
                    if let index = self.subscribedRoutes.indexOf(route){
                        _ = self.subscribedRoutes.removeAtIndex(index)
                    }
                }
                
                toLoad -= 1
                
                if toLoad == 0{
                    complete()
                }
                
            })
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
