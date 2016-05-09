//
//  HTTPRequestSimplified
//  Expreso Tec App
//
//

import Foundation
import UIKit

/**
 
 This class provides a lot of class level methods that allow making HTTP requests in a painless way without having a lot of duplicated code
 
 */
class HTTPRequestSimplified{
    
    /// This method retuns the base url that preceds all requests.
    class private func getURL() -> String{
        return "https://expreso.herokuapp.com/routes"
    }
    
    /**
     
     This method creates a request to a certain url. 
     
     - parameter site: The shorten (without base url) url that wants to be requested
     - parameter method: The Http method that should be ussed with this request. If no method is specified then GET is assumed
     - parameter httpData: The string that represents
     
     - returns: A http request that can be executed
     
     - seealso: generateParamString(_:)
     - seealso: getDictionaryOfParsingJSONFromRequest(_:callback:)

     */
    class func getStandardOnlyTextRequest(site : String, method : HTTPMethod = .GET,  httpdata: String? = nil)->NSMutableURLRequest{
        
        
        if method == .GET{
            
            let request = getStandardRequest("\(site)?\( httpdata ?? "" )")
            return request

        }
        else{
            let request = getStandardRequest(site, method: method)

            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            if let requestBody = httpdata{
                request.HTTPBody = requestBody.dataUsingEncoding(NSUTF8StringEncoding)
            }
            
            return request
        }
    
    }
    
    /**
     
     This method is a very generic method that creates a request to certain site and establishes it some defaults such as time out interval
     
     - parameter site: The short url that wants to be requested
     - parameter method: The HTTP method that the request should use. If no method is provided, GET will be used

     - returns: A very generic HTTP request that still needs some work to be ready
     
     */
    class private func getStandardRequest(site : String, method : HTTPMethod = .GET )->NSMutableURLRequest{
        
        let url: NSURL = NSURL(string: "\(HTTPRequestSimplified.getURL())/\(site)")!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
        request.timeoutInterval = 10
        return request
        
    }
    
    /**
     
     This method provides a convienient way to clean up user input and parameters that contains character that are not allowed by an HTTP request
     
     - parameter string: the string that needs to be cleaned up
     
     - returns: A string with the invalid characters escaped with percent characters
     
     */
    class func prepareForHttpSending(string : String) -> String{
        return string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    }
    
    /**
     
     This method takes a dictionary and parses it as a parameter string that will be valid for HTTP requests
     
     This method has the responsability of forming the string and cleaning up the parameters
     
     - parameter dic: The dictionary whose params are going to be sent along with some HTTP request
     
     - returns: A string that scontains all keys and values sanitized and is formed as *param1=value1&param2=value2&...&paramN=valueN*
     
     */
    class func generateParamString(dic : [String:String])->String{
        
        var first = true
        var str = ""
        
        for (k,v) in dic{
            
            str += "\(first ? "" : "&" )\(prepareForHttpSending(k))=\(prepareForHttpSending(v))"
            first = false
            
        }
        
        return str
    }
    
    /**
     
     This method executes a request in background and calls the result in the main thread
     
     **Only use this method when you need certain data that can't be parsed as a JSON, otherwise get the parsed dictionary to avoid duplicated code**
     
     - seealso: getDictionaryOfParsingJSONFromRequest
     
     - parameter request: The http request that needs to be executed
     - parameter result: The callback that is going to be called in the main thread. It contains 3 parameters
        1. data: The HTTP data returned by the server or nil if an error ocurred
        2. response: All the information about the HTTP response such as status code or nil when some errors occur
        3. error: The error that ocuured or nil if no error happened
     
     - returns: A Session task that the calle may be used to cancel the request if the response its no longer necessary
     
     */
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
    
    /**
     
     This method executes a request in background and calls the result as a dictionary with a JSON parsed in the main thread
     
     
     - parameter request: The http request that needs to be executed
     - parameter callback: The callback that is going to be called in the main thread. It contains 3 parameters
        1. NSDictionary?: The dictionary that was parsed from the server data respose or nil if an error occured
        2. GenericError?: The error that made the dictionary creation impossible or nil if the dictionary was created
     
     
     */
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

/**
 
 This enum provides a fixed number of options to create an HTTP request.
 
 Furthermore, the raw value must be used as a parameter to create the HTTP request
 
 */
public enum HTTPMethod : String{
    
    /// HTTP POST
    case POST = "POST"
    /// HTTP PUT
    case PUT = "PUT"
    /// HTTP DELETE
    case DELETE = "DELETE"
    /// HTTP GET
    case GET = "GET"
    
}