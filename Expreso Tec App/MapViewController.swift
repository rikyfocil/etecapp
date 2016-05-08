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

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    private let manager = CLLocationManager()

    @IBOutlet weak var map: MKMapView!
    
    private var unhide = false
    
    var user = User(name: "Ricardo", userID: "A01327311")
    
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
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 24.54, longitude: 23.12)
        map.addAnnotation(annotation)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        //TODO: Implement this method
    }
    
    func updateAllBusses(){}
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKindOfClass(MKUserLocation.self){
            return nil
        }
        
        var annotationBus = mapView.dequeueReusableAnnotationViewWithIdentifier("bus") as? BusMapAnnotationView
        
        if annotationBus == nil{
            annotationBus = BusMapAnnotationView(annotation: annotation, reuseIdentifier: "bus")
        }
        
        annotationBus!.setBusColor(UIColor.redColor())
        return annotationBus
    }
    
}
