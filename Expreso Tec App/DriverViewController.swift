//
//  DriverViewController.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 08/05/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit
import CoreLocation

class DriverViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var trackingSwitch: UISwitch!
    
    let manager = CLLocationManager()
    let driver : Driver! = nil
    private var updatedOnce = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        nameLabel.text = "Bienvenido \(driver.name)"
        routeLabel.text = "Ruta \(driver.route.name)"
        
        trackingSwitch.on = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logout(sender: AnyObject) {
        
        UIAlertController.presentConfirmationAlertViewController("Cerrar sesión", description: "Si cierras sesión los alumnos no podrán ver donde estas", confirmText: "Sí, cerrar sesión", cancelText: "Mejor no", controller: self, destructive: true, confirmAction: { 
                self.manager.stopUpdatingLocation()
                self.performSegueWithIdentifier("logout", sender: nil)
            }, cancelAction: nil)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        if newLocation.distanceFromLocation(oldLocation) > 50 || !updatedOnce{
            let request = HTTPRequestSimplified.getStandardOnlyTextRequest("set", httpdata: HTTPRequestSimplified.generateParamString(["route":driver.route.name, "lat":"\(newLocation.coordinate.latitude)","lng": "\(newLocation.coordinate.longitude)"]))
            HTTPRequestSimplified.getDictionaryOfParsingJSONFromRequest(request, callback: {
                
                (dictionary, error) in
                
                if let err = error{
                    print("Error. Algo esta saliendo mal.\(err)\n \(#file):\(#line)")
                }
                
                
            })
            
        }
        
    }
    
    @IBAction func attempToUpdate(sender: AnyObject) {
        
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
