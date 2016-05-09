//
//  User.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 27/03/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

/**
 
 This class represents a user in the database
 
 As the user may change some settings any time, this class is the right way to do it.
 
 To instanciate an user a login is required. 
 
 **This model follows observer design pattern**
 
 */
public class User: NSObject {

    /// The user unique identifier. The one with which he logs in
    public private(set) var userID : String = ""
    
    /// The user name
    public let name : String
    
    /// The database id that uniquely identifies this user
    private var databaseID = 0

    /// An array of the routes to which the user is suscribed to
    public private(set) var subscribedRoutes = [Route]()
    
    /// An array of observers that shoul be notified whenever the user changes its subscribed routes preferences
    private var listOfRouteChangingObservs = Array< (User, didUpdateRoutes : [Route] )->(Bool) >()

    /**
     
     The only user constructor. This constructor is kept private to avoid external classes to attempt to avoid the login system. 
     
     - parameter dictionary: A dictionary containing all the user information. Required keys:
        + name : String -> The riders name
        + id : Int -> The unique database identifier
        + routes : [NSDictionary] -> An array containing dictionaries ready to instanciate the routes
     
     - returns: nil if the dictionary is invalid for user creation
     
     */
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
        
    /**
     
     This is the standard way to create a User. 
     
     - parameter id: The id that identifies the user
     - parameter password: The user associated password
     - parameter callback: A block of code that should be called whit the login result
        + User?: The logged in user or nil if there was an error
        + LoginError?: The error explaining why the user in nil
     
     */
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
        
        if !(text.characters.first! == "A" || text.characters.first! == "L" || text.characters.first! == "l" || text.characters.first! == "a"){
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
     
     This is the standard way to register some code block to be called whenever the user registered routes change
     
     - parameter notificationHandler: The code of block to call
        + User: The user that changed his preferences
        + Routes: The new user registered routes
        + Returning Bool: Tells if the code block must be kept for future notifications
     
     */
    public func registerForRouteChangingNotifications( notificationHandler : (User, didUpdateRoutes : [Route] )->(Bool)  ){
        self.listOfRouteChangingObservs.append(notificationHandler)
    }
    
    /**
     
     This method should be called when the user preferences should change
     
     - parameter routes: An array containing to which routs should the user be subscribed after the update
     - parameter doneCallback: The block of code that will be called when the update is complete
        + Bool: Tells wheter the update was done completly or partially. The user *subscribedRoutes* property will reflect the new set of routes in case of faliure (or success).
     
     */
    public func updateRouteSubscriptions( routes : [Route], doneCallback : (Bool)->() ){
        
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