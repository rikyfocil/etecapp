//
//  User.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 27/03/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

public class User: NSObject {

    
    public private(set) var userID : String = ""
    public let name : String
    private var databaseID = 0

    public private(set) var subscribedRoutes = [Route]()
    
    private init?(dictionary : NSDictionary){
        
        let name = dictionary["name"] as? String
        let id = dictionary["id"] as? Int
        let routes = dictionary["routes"] as? Array<NSDictionary>
        
        guard name != nil && id != nil && routes != nil else{
            return nil
        }
    
        self.name = name!
        self.databaseID = id!
        
        for routeDic in routes!{
            if let route = Route(route: routeDic){
                self.subscribedRoutes.append(route)
            }
            else{
                return nil
            }
        }
        
    }
        
    private var listOfRouteChangingObservs = Array< (User, didUpdateRoutes : [Route] )->(Bool) >()
    
    public class func loginWithData(id : String?, password : String?, callback : (User?, LoginError?)->()){
        
        do{
            
            try validateID(id)
            try validatePassword(password)
            
            let request = HTTPRequestSimplified.getStandardOnlyTextRequest("mobileLogin", method: .POST, httpdata: HTTPRequestSimplified.generateParamString(["username":id!, "password":password!]))
            
            HTTPRequestSimplified.getDictionaryOfParsingJSONFromRequest(request, callback: {
                
                (loginDictionaryOptional, error) in
                
                if let error = error{
                    
                    print("Error. Error while attempting to login user. Dictionary was not formed\n\(error)\n \(#file):\(#line)")
                    callback(nil, LoginError.UnknownError)
                    return
                    
                }
                
                let dictionary = loginDictionaryOptional!
                
                if let message = dictionary["result"] as? String where message == "success"{
                    
                    if let user = User(dictionary: dictionary){
                        
                        user.userID = id!
                        callback(user, nil)
                        
                    }
                    else{
                        callback(nil, LoginError.ApiMalformed)
                    }
                    
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
                
                
                if generatedError != nil || dictionary!["result"] as? String != "success"{
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
                
                
                if generatedError != nil || dictionary!["result"] as? String != "success"{
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
    case ApiMalformed
    case UnknownError
}
