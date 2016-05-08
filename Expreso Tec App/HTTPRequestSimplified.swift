//
//  HTTPRequestSimplified
//  Expreso Tec App
//
//  Created by Carlos Alberto Baños Martínez on 3/14/16.
//  Copyright © 2016 Carlos Baños. All rights reserved.
//

import Foundation
import UIKit

class HTTPRequestSimplified{
    
    class private func getURL() -> String{
        return "https://expreso.herokuapp.com/routes/"
    }
    
    class func getStandardOnlyTextRequest(site : String, method : HTTPMethod = .GET,  httpdata: String? = nil)->NSMutableURLRequest{
        
        let request = getStandardRequest(site, method: method)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        if let requestBody = httpdata{
            request.HTTPBody = requestBody.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        return request
    
    }
    
    class private func getStandardRequest(site : String, method : HTTPMethod = .GET )->NSMutableURLRequest{
        
        let url: NSURL = NSURL(string: "\(HTTPRequestSimplified.getURL())/\(site)")!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
        request.timeoutInterval = 8
        return request
        
    }
    
    class func prepareForHttpSending(string : String) -> String{
        return string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    }
    
    class func generateParamString(dic : [String:String])->String{
        
        var first = true
        var str = ""
        
        for (k,v) in dic{
            
            str += "\(first ? "" : "&" )\(prepareForHttpSending(k))=\(prepareForHttpSending(v))"
            first = false
            
        }
        
        return str
    }
    
    private class func performRequest(request : NSURLRequest, result : (data : NSData?, response : NSURLResponse?, error : NSError?)->() )->NSURLSessionTask{
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            
            d, r, e in
            
            dispatch_async(dispatch_get_main_queue()){
                result(data: d, response: r, error: e)
            }
            
        }
        
        task.resume()
        return task
        
    }
    
    class func getDictionaryOfParsingJSONFromRequest(request : NSURLRequest, callback : ( (NSDictionary?, GenericError?)->() ) ){
        
        HTTPRequestSimplified.performRequest(request) { (data, response, error) in
            
            if let error = error{
                
                print("\(error)\n\(#file):\(#line)")
                
                dispatch_async(dispatch_get_main_queue()){
                    callback(nil,GenericError.HTTPError)
                }
                
                return
                
            }
            
            guard let data = data else{
            
                print("Error retriving the data\n\(#file):\(#line)")
                
                dispatch_async(dispatch_get_main_queue()){
                    callback(nil,GenericError.HTTPError)
                }
                
                return
            
            }
            
            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
            
            if let json = json{
                
                if let dic = json as? NSDictionary{
                    
                    dispatch_async(dispatch_get_main_queue()){
                        callback(dic,nil)
                    }
                
                }
                else{
                    
                    print("Error. JSON was not dictionary or result was nil\n\(NSString(data:data, encoding: NSUTF8StringEncoding))\n\(#file):\(#line)")
                    
                    dispatch_async(dispatch_get_main_queue()){
                        callback(nil,GenericError.JSONParsingError)
                    }
                
                }
                
            }
            else{
            
                print("Error parsing JSON\n\(NSString(data:data, encoding: NSUTF8StringEncoding))\n\(#file):\(#line)")
                
                dispatch_async(dispatch_get_main_queue()){
                    callback(nil,GenericError.JSONParsingError)
                }
                
            }
            
        }
    
    }
    
}

public enum HTTPMethod : String{
    
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case GET = "GET"
    
}