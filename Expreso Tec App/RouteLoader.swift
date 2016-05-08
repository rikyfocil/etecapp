//
//  RouteLoader.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 22/04/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

public class RouteLoader: NSObject {
    
    public private(set) static var routes : [Route]?
    public private(set) static var hasLoadedRoutes = false

    private static var waitingList = Array<([Route]?)->()>()
    private static var loading = false
    
    public static func startGetingRoutes(){
        
        if loading{
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
                            
                            try RouteLoader.routes?.append( parseRoute(route as? NSDictionary))
                            
                        }
                        
                        RouteLoader.hasLoadedRoutes = true
                        RouteLoader.informWaitingListOfCompletedLoading()
                        RouteLoader.loading = false
                        
                    }
                    catch{
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
    
    public static func notifyWhenLoaded( callBack : ([Route]?)->() ){
    
        if !hasLoadedRoutes && !loading{
            waitingList.append(callBack)
        }
        else{
            callBack(RouteLoader.routes)
        }
        
    }
    
    private static func cancelWaitingList(){
        
        if !NSThread.isMainThread(){
            
            dispatch_async(dispatch_get_main_queue()){
                RouteLoader.cancelWaitingList()
            }
            
        }
        else{
        
            for i in waitingList{
                i(nil)
            }
            
            waitingList.removeAll()
            
            RouteLoader.routes = nil
            RouteLoader.hasLoadedRoutes = false
            RouteLoader.loading = false
        }
    
    }

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
    
    private static func parseRoute(route : NSDictionary?) throws ->Route{
        
        guard let routeDictionary = route else{
            throw GenericError.GenericError
        }
        
        let name = routeDictionary["name"] as? String
        let id = routeDictionary["id"] as? Int
        let driver = routeDictionary["driver"] as? String
        let color = UIColor(fromHexHashtagedString: (routeDictionary["color"] as? String) ?? "")
        
        guard name != nil && id != nil && driver != nil && color != nil else{
            throw GenericError.GenericError
        }
        
        return Route(id: id!, color: color! , name: name!, conductor: driver!)
        
    }
    
}

enum GenericError : ErrorType{
    
    case GenericError
    case JSONParsingError
    case HTTPError
    case WebSiteError
    
}