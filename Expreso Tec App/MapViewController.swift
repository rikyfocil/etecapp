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

class MapViewController: UIViewController {

    private let manager = CLLocationManager()
    @IBOutlet weak var planMap: MKMapView!
    private var unhide = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        if manager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization)){
            manager.requestWhenInUseAuthorization()
        }
        
        let point = MKPointAnnotation()
        planMap.addAnnotation(point)
        planMap.viewForAnnotation(point)?.draggable = false
        let region = MKCoordinateRegionMakeWithDistance(point.coordinate, 700, 700)
        planMap.setRegion(region, animated: false)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func done(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
