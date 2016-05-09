//
//  RouteLoader.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 22/04/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

/**
 
 This class provides an starting point for all classes among the application so no extra calls to getRoutes are performed
 
 This works as a observer design pattern
 
 */
public class RouteLoader: NSObject {
    
    /// The loaded routes. This wont be nil if *hasLoadedRoutes* is true but **this does not guarantee** that if *hasLoadedRoutes* is false then the variable is nil
    private static var routes : [Route]? = nil
    
    /// A boolean indicating if the routes are already loaded or not
    public private(set) static var hasLoadedRoutes = false

    /// An array of block codes that should be informed when the routes are fully loaded
    private static var waitingList = Array<([Route]?)->()>()
    
    /// A variable that tells if there is a web service call in progress
    private static var loading = false
    
    /**
     
     This method should be called when some object wants to start the route loading
     
     The behavior of this method is defined as follows: 
     
     + If the routes are already loaded or there is a request in progress the request is ignored
     + Otherwise A new request to the web service is started
     
     */
    public static func startGetingRoutes(){
        
        if loading || hasLoadedRoutes{
            return
        }
        
        let url = NSURL(string: "https://expreso.herokuapp.com/routes/getRoutes")
        
        let dataTask = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithURL(url!){
         
            data, response, error in
            
            if let error = error{
            
                print(error.description)
                RouteLoader.cancelWaitingList()
                
            }
            
            else if let response = response as? NSHTTPURLResponse where data != nil{
                
                if response.statusCode == 200 && data != nil{
                
                    do{
                        let dictionaryOptional = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        
                        guard let dictionary = dictionaryOptional else{
                        
                            RouteLoader.cancelWaitingList()
                            return
                            
                        }
                        
                        let routesOptional = dictionary["routes"] as? NSArray
                        
                        guard let routes = routesOptional else{
                        
                            RouteLoader.cancelWaitingList()
                            return
                            
                        }
                        
                        
                        RouteLoader.routes = [Route]()
                        
                        for route in routes{
                            
                            if let routeDic = route as? NSDictionary, let route = Route(route: routeDic){
                                RouteLoader.routes?.append( route )
                            }
                            else{
                                throw GenericError.GenericError
                            }
                        }
                        
                        RouteLoader.hasLoadedRoutes = true
                        RouteLoader.informWaitingListOfCompletedLoading()
                        RouteLoader.loading = false
                        
                    }
                    catch{
                        RouteLoader.routes = nil
                        cancelWaitingList()
                    }
                    
                }
                else{
                    
                    RouteLoader.cancelWaitingList()

                }
            
            }
            
        }
        
        dataTask.resume()
        
    }
    
    /**
    
     This method is the standard way to recieve the routes when they are ready.
     
     The behavior of this method is as described below 
     
     + If the routes are not yet loaded the *callback* is appended to the waiting list
     + If the lists are loaded then the *callback* is loaded inmediatly 
     
     - parameter callback: The block of code that should be called when the route request is finished
        - [Route]? is the array of retirved routes or nil if there was an error when requesting the web service
     
     */
    public static func notifyWhenLoaded( callBack : ([Route]?)->() ){
    
        if !hasLoadedRoutes{
            waitingList.append(callBack)
        }
        else{
            callBack(RouteLoader.routes)
        }
        
    }
    
    /**
     
     This method will be called when there is an error processing the routes by the web service. The behavior is stated below. 
     
     **This method will allways work on the main tread so calling it does not guarantee inmediate results**
     
     + The loading variable is set to false so new requests can be started
     + Each observer is called with a nil array
     + The waiting list is flushed
     
     */
    private static func cancelWaitingList(){
        
        if !NSThread.isMainThread(){
            
            dispatch_async(dispatch_get_main_queue()){
                RouteLoader.cancelWaitingList()
            }
            
        }
        else{
            
            RouteLoader.loading = false

            for i in waitingList{
                i(nil)
            }
            
            waitingList.removeAll()
        }
    
    }

    /**
     
     This method will be called when the routes are ready to be used. The behavior is stated below.
     
     **This method will allways work on the main tread so calling it does not guarantee inmediate results**
     
     + Each observer is called with the routes array
     + The waiting list is flushed
     
     **Important**: Loading will be set to false via *startGetingRoutes*
     
     */
    private static func informWaitingListOfCompletedLoading(){
    
        if !NSThread.isMainThread(){
            
            dispatch_async(dispatch_get_main_queue()){
                RouteLoader.informWaitingListOfCompletedLoading()
            }
            
            return
            
        }
        
        for i in waitingList{
            i(routes)
        }

        waitingList.removeAll()

    }
    
    
}
