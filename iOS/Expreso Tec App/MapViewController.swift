//
//  MapViewController.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 5/6/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

/**
 This class is the main user view controller where he can track the location of all his subscribed routes
 
 - important: If the user hasn't suscribed to any route yet he is going to be taken to the settings screen where he will be able to select at least one
 
 This class registers itself as observer for the user subscribed routes changes.
 
 */
class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    /// The manager that informs the class about the user location and the responsable of displaying its location
    private let manager = CLLocationManager()

    /// The map that displays the user location and the routes
    @IBOutlet weak var map: MKMapView!
    
    /// The routes that are being tracked
    var trackingRoutes = [Route]()
    
    /// The annotations associated to the routes
    var annotation = [MKPointAnnotation]()
    
    /// The current logged user instance. The previous view controller is responsable for assigning this variable
    var user : User!
    
    /// A variable that tells wheter the buses are being tracked or not
    var updating = false
    
    /**
     This overriding perform the following actions:
     
     - Request user permission for getting his location
     - Register as observer for changes on the user suscribed routes
     - Assign itself as a delegate for the map events
     - Triggers the buses continue updating
     
     */
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        user.registerForRouteChangingNotifications {
            
            [weak self]
            (user, routes) -> (Bool) in
            
            
            if let s = self{
            
                s.updateAllBusses()
                return true
                
            }
            
            return false

        }
        
        if manager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization)){
            manager.requestWhenInUseAuthorization()
        }
        
        if user.subscribedRoutes.isEmpty{
            self.performSegueWithIdentifier("goSettings", sender: nil)
        }
        
        map.delegate = self
        updateAllBusses()
        
    }
    
    /**
     This method is the starting point for the bus tracking system. This method creates the annotations and the tracking information with the user. This method should be called in the following ocations: 
     
     - When the view is fully loaded
     - When the user changes its registered routes
     
     - important: This method will perform all the clean up before changing the routes so no extra calls are needed.
     
     */
    func updateAllBusses(){
    
        self.trackingRoutes = user.subscribedRoutes
        
        map.removeAnnotations(self.annotation)
        self.annotation.removeAll()

        for _ in self.trackingRoutes{
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: 19.019026,longitude: -98.242097)
            self.annotation.append(annotation)
            self.map.addAnnotation(annotation)
            
        }
        
        if !updating{
            updating = true
            getBusesLocation()
        }
    }
    
    /**
     This method is responsable for calling the web service and recieving each bus location.
     
     - important: Once called, this method is going to call himself back every 30 seconds so no extra calling is needed after it has started.
     */
    func getBusesLocation(){
        
        for bus in trackingRoutes{
        
            let request = HTTPRequestSimplified.getStandardOnlyTextRequest("get", httpdata: HTTPRequestSimplified.generateParamString(["route":"\(bus.name)"]))
            HTTPRequestSimplified.getDictionaryOfParsingJSONFromRequest(request, callback: {
                
                (dictionary, error) in
                
                if error != nil || dictionary!["result"] as? String != "success"{
                    print("Error. Request returned error while getting bus location\n\(dictionary)\n \(#file):\(#line)")

                    return
                }
            
                if let index = self.trackingRoutes.indexOf(bus), let latitude = dictionary!["lat"] as? Double, let longitude = dictionary!["lng"] as? Double{
                    self.annotation[index].coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
                
            })
        }
        
        let delay = 30 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.getBusesLocation()
        })
        
    }
    
    /**
     This method implements a map kit delegate method. Its function is to provide the annotations for each part of the map. 
     
     The method will check if the annotation is not the user location and then it will create (if a reuse is not possible) a new bus annotation. 
    
     - parameter mapView: The map that requests the view
     - parameter annotation: The annotation that is going to be displayed
     - returns: Abus annotation or nil if the user location annotation was requested
     */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKindOfClass(MKUserLocation.self){
            return nil
        }
        
        var annotationBus = mapView.dequeueReusableAnnotationViewWithIdentifier("bus") as? BusMapAnnotationView
        
        if annotationBus == nil{
            annotationBus = BusMapAnnotationView(annotation: annotation, reuseIdentifier: "bus")
        }
        
        if let pointAnnotation = annotation as? MKPointAnnotation , let index = self.annotation.indexOf(pointAnnotation){
             annotationBus!.setBusColor(self.trackingRoutes[index].color)
        }
        return annotationBus
    }
    
    /**
     
     This overriding provides the following behaviors:
     
     + If the segue is to settings the user will be passed to the controller
     + Otherwise the segue will be continued in an unnmodified manner
     
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goSettings"{
            
            let vc = segue.destinationViewController as! SettingsViewController
            vc.user = user
   
        }
    
    }
}
