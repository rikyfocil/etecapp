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
    private var selectedRoutes : [Route]!
    
    var user : User!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var blockingView: UIView!
    @IBOutlet weak var routesTable: UITableView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButtonOutlet: UIBarButtonItem!

    override public func viewDidLoad(){
        
        super.viewDidLoad()
        routesTable.rowHeight = UITableViewAutomaticDimension
        routesTable.estimatedRowHeight = 56
        
        userNameLabel.text = user.name
        userIDLabel.text = user.userID
        
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
        
        selectedRoutes = user.subscribedRoutes
        updateBackButton()
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
            cell.accessoryType = selectedRoutes.contains(cell.route!) ? .Checkmark : .None
            cell.tintColor = UIColor.whiteColor()
            return cell
            
        }
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if loaded{
            
            let route = routes![indexPath.row]
            
            if let index = self.selectedRoutes.indexOf(route){
                self.selectedRoutes.removeAtIndex(index)
            }
            else{
                self.selectedRoutes.append(route)
            }
            
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        updateBackButton()

    }
    
    @IBAction func goToMap(sender: AnyObject) {
        
        self.backButtonOutlet.enabled = false
        self.blockingView.hidden = false
        self.activityIndicator.startAnimating()
        user.updateRouteSubscriptions(self.selectedRoutes) {
            
            (updated) in
            
            self.selectedRoutes = self.user.subscribedRoutes
            self.blockingView.hidden = true
            self.updateBackButton()
            
            if !updated{
                UIAlertController.presentErrorMessage(description: "No pudimos actualizar todas tus rutas. Ahora te mostramos lo que si pudimos actualizar. Si deseas volver a intentarlo realiza de nuevo tus modificaciones e intenta volver al mapa otra vez.\nSi no haces cambios y tienes al menos una ruta podrás volver al mapa de inmediato.", controller: self, completition: nil)
                self.selectedRoutes = self.user.subscribedRoutes
                self.tableView.reloadData()
            }
            else{
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }
    
    func updateBackButton(){
        self.backButtonOutlet.enabled = !self.selectedRoutes.isEmpty
    }
}
