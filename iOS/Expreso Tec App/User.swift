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
    public let userID : String
    
    /// The user name
    public let name : String
    
    /// The database id that uniquely identifies this user
    private var databaseID : Int
    
    /// An array of the routes to which the user is suscribed to
    public private(set) var subscribedRoutes = [Route]()
    
    /// An array of observers that shoul be notified whenever the user changes its subscribed routes preferences
    private var listOfRouteChangingObservs = Array< (User, didUpdateRoutes : [Route] )->(Bool) >()

    /**
     
     The only user constructor. Despite the constructor is public please use the login system. 
     
     - parameter dictionary: A dictionary containing all the user information. Required keys:
        + name : String -> The riders name
        + id : Int -> The unique database identifier
        + routes : [NSDictionary] -> An array containing dictionaries ready to instanciate the routes
     
     - returns: nil if the dictionary is invalid for user creation
     
     */
    public init?(dictionary : NSDictionary){
        
        let name = dictionary["name"] as? String
        let id = dictionary["id"] as? Int
        let usernameID = dictionary["username"] as? String
        let routes = dictionary["routes"] as? Array<NSDictionary>
        
        guard name != nil && id != nil && routes != nil && usernameID != nil else{
            return nil
        }
    
        self.name = name!
        self.databaseID = id!
        self.userID = usernameID!
        
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