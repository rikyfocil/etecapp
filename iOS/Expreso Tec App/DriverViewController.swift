//
//  DriverViewController.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 08/05/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit
import CoreLocation

/**
 
 This class provides all the functionality that a driver needs in orde to be tracked or not by the users
 
 */
public class DriverViewController: UIViewController, CLLocationManagerDelegate {

    /// The label greeting the driver
    @IBOutlet weak var nameLabel: UILabel!
    
    /// The label telling the driver whose route is driving
    @IBOutlet weak var routeLabel: UILabel!
    
    /// A switch tell wheter the location of the bus is being tracked or not
    @IBOutlet weak var trackingSwitch: UISwitch!
    
    /// The Core location manager responsible of updating the user loaction
    private let manager = CLLocationManager()
    
    /// The current driver. This variable must be set by the previous controller
    public var driver : Driver! = nil
    
    /// Tells wheter the location has been uploaded at least once. With this booleean the distance verification is ommited the first time
    private var updatedOnce = false
    
    /**
     
     This override provides the following behavior:
     
     + Requests user authorization
     + Starts updating the user location
     + Sets the UI content
     
     */
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        manager.delegate = self
        
        nameLabel.text = "Bienvenido \(driver.name)"
        routeLabel.text = "Ruta \(driver.route.name)"
        
        trackingSwitch.on = true
        
    }

    /**
     
     This method is triggered when the user presses the logout button
     
     A confirmation is displayed and if the user accepts it the *manager* stops updating the location and the controller is dismised.
     
     */
    @IBAction public func logout(sender: AnyObject) {
        
        UIAlertController.presentConfirmationAlertViewController("Cerrar sesión", description: "Si cierras sesión los alumnos no podrán ver donde estas", confirmText: "Sí, cerrar sesión", cancelText: "Mejor no", controller: self, destructive: true, confirmAction: { 
                self.manager.stopUpdatingLocation()
                self.performSegueWithIdentifier("logout", sender: nil)
            }, cancelAction: nil)
        
    }
    
    /**
     
     **This method should only be called by *manager***
     
     This method is called when there is new location information available. This method have the following behavior
    
     + If the location has never being updated the location is informed to the server
     + If the new location has a difference greater than 30 meters from the old one then its informed to the server
     + Otherwise the new location is discarded
     
     - parameter manager: The manager that is triggering the action
     - parameter didUpdateToLocation: The new recorded user location
     - parameter fromLocation: The old registered location
     
     */
    public func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        if abs(newLocation.distanceFromLocation(oldLocation)) > 30 || !updatedOnce{
            let request = HTTPRequestSimplified.getStandardOnlyTextRequest("set", httpdata: HTTPRequestSimplified.generateParamString(["route":driver.route.name, "lat":"\(newLocation.coordinate.latitude)","lng": "\(newLocation.coordinate.longitude)"]))
            HTTPRequestSimplified.getDictionaryOfParsingJSONFromRequest(request, callback: {
                
                (dictionary, error) in
                
                if let err = error{
                    print("Error. Algo esta saliendo mal.\(err)\n \(#file):\(#line)")
                }
                
                
            })
            
        }
        
    }
    
    /**
     
     This method is called when the user toogles the switch of tracking location. The behavior is as follows:
     
     + if the new state is off the action is confirmed to the user. If he confirms then the manager location updates are stoped and *updatedOnce* is reset.
     + If the new state is on, the manager is told to recieve notifications without user confirmation
     
     - parameter sender: The item that is triggering the action **This param is allways ignored**
     
     */
    @IBAction public func attempToUpdate(sender: AnyObject) {
        
        if !trackingSwitch.on{
        
            UIAlertController.presentConfirmationAlertViewController("A punto de dejar de seguir", description: "Solo deberás de cancelar el seguimiento cuando no estes en ruta.", confirmText: "Sí, dejar de seguir", cancelText: "Mejor no", controller: self, destructive: true, confirmAction: { 
                    self.manager.stopUpdatingLocation()
                }, cancelAction: {
                    self.trackingSwitch.on = true
            })
        }
        else{
            manager.startUpdatingLocation()
        }
        
    }

}
