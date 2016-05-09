//
//  SettingsViewController.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 22/04/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import UIKit

/**
 
 This controller provide a way for users to change his subscribed routes
 
 */
public class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// Indicates wheter the routes are already loaded or not
    private var loaded = false
    
    /// An array containing all the routes that the user can subscribe to
    private var routes : [Route]?
    
    /// The routes that the user has already selected
    private var selectedRoutes : [Route]!
    
    /// The user instance that will be modified. Setting this variable is responsability of the previous view controller
    var user : User!
    
    /// The label that displays the user name
    @IBOutlet weak var userNameLabel: UILabel!
    
    /// The label that displays the user ID
    @IBOutlet weak var userIDLabel: UILabel!
    
    /// An activity indicator that tells that there is an action in progress
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// A view that blocks the user contennt while an update is happening
    @IBOutlet weak var blockingView: UIView!
    
    /// The table view in whic the routes are being displayed
    @IBOutlet weak var routesTable: UITableView!
    
    /// An outlet to the back button item. This button will be disabled if there is not at least one route selected.
    @IBOutlet weak var backButtonOutlet: UIBarButtonItem!

    /**
     
     This override provides the following behaviors:
     
     + Configures the UI
     + Sets the currect selected routes as the user registered routes
     + Registers self as an observer for the routes
     + Sets the initial state of the back button
     
     */
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
        
        RouteLoader.startGetingRoutes()
        selectedRoutes = user.subscribedRoutes
        updateBackButton()
    }


    /**
     
     This method is triggered when the user wants to be logged out.
     
     A destructive confirmation message will be shown and if the user accepts it then he will be taken back to the login screen
     
     */
    @IBAction func logout(sender: AnyObject) {
        
        UIAlertController.presentConfirmationAlertViewController("¿Estas seguro?", description: "Si cierras sesión no podremos informarte de la ubicación del expreso y dejarás de recibir notificaciones", confirmText: "Sí, cerrar sesión", cancelText: "Cambie de idea", controller: self, destructive: true, confirmAction: { 
            
            // TODO: Actually close the session
            self.view.userInteractionEnabled = false
            self.performSegueWithIdentifier("backToLogin", sender: self)
            
            }, cancelAction: nil)
        
    }
    
    
    //MARK: Table view data source and delegate methods
    
    /**
     
     Tells how many sections should be in the table view
     
     - parameter tableView: the requesting table view
    
     - returns: 1
     
     */
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    /**
     
     Tells how many rows should be in the table view *section*
     
     - parameter tableView: The requesting table view
     - parameter numberOfRowsInSection: The requested section
     
     - returns: 1 if the route information is not available. The number of routes otherwise
     
     */
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !loaded{
            return 1
        }
        else{
            return routes!.count
        }
        
    }

    
    /**
     
     Returns a row associated to a certain index path
     
     - parameter tableView: The requesting table view
     - parameter cellForRowAtIndexPath: The row that needs to be configured
     
     - returns: A loading cell if the routes are not yet available or a RouteTableViewCell with the corresponding route otherwise
     
     */
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
    
    /**
     
     Changes the local settings accordingly to the user selected cell
     
     + If the routes information is not available, the selection is ignored.
     + Otherwise if the route is contained in *selectedRoutes* it will be removed
     + Otherwise the associated route will be added to *selectedRoutes*
     
     After this method call, the back button will be updated
     
     - parameter tableView: The requesting table view
     - parameter didSelectRowAtIndexPath: The row that was selected
     
     
     */
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
            updateBackButton()
            
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        

    }
    
    /**
     
     This method will be triggered when the user wants to go back to the current location map. 
     
     The settings will be saved automatically but the user will have to wait for completion. 
     
     If there is an error in the request, the table will be updated to reflect the new settings and prompt the user to try again to get the desired configuration
     
     If everithing is successful the view controller will be dismissed
     
     */
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
                self.routesTable.reloadData()
            }
            else{
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }
    
    /**
     
     This method has the only purpose of updating the back button accordingly to the user selected routes
     
     + 0 routes selected = button dissabled
     + > 0 routes selected = button enabled
     
     */
    func updateBackButton(){
        self.backButtonOutlet.enabled = !self.selectedRoutes.isEmpty
    }
}
