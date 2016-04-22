//
//  SettingsViewController.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 22/04/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

public class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var loaded = false
    private var routes : [Route]?
    @IBOutlet weak var routesTable: UITableView!
    
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        routesTable.rowHeight = UITableViewAutomaticDimension
        routesTable.estimatedRowHeight = 56
        
        RouteLoader.notifyWhenLoaded {
            [weak self]
            (routesRetrivedOptional) in
            
            guard let s = self else{
                return
            }
            
            guard let routesRetrived = routesRetrivedOptional else{
                
                UIAlertController.showAlertMessage("No pudimos obtener las rutas\nPor favor, comprueba tu conexión a Internet e intentalo más tarde", inController: s, withTitle: "Error", block: nil)
                return
                
            }
            
            s.routes = routesRetrived
            s.loaded = true
            s.routesTable.reloadData()
            
        }
        
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logout(sender: AnyObject) {
        
        UIAlertController.presentConfirmationAlertViewController("¿Estas seguro?", description: "Si cierras sesión no podremos informarte de la ubicación del expreso y dejarás de recibir notificaciones", confirmText: "Sí, cerrar sesión", cancelText: "Cambie de idea", controller: self, destructive: true, confirmAction: { 
            
            // TODO: Actually close the session
            self.view.userInteractionEnabled = false
            self.performSegueWithIdentifier("backToLogin", sender: self)
            
            }, cancelAction: nil)
        
    }
    
    
    //MARK: Table view data source and delegate methods
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !loaded{
            return 1
        }
        else{
            return routes!.count
        }
        
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if !loaded{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("loadingCell")!
            let indicatorView = cell.contentView.viewWithTag(1) as! UIActivityIndicatorView
            indicatorView.startAnimating()
            indicatorView.hidden = false
            return cell
            

        }
        else{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("routeCell") as! RouteTableViewCell
            cell.route = routes![indexPath.row]
            return cell
            
        }
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
}
