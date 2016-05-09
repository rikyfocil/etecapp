//
//  BusMapAnnotationView.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 07/05/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import MapKit

/**
 This class provides the bus annotation that the user can see in the map. 
 
 This annotation is created as a bus with a certain color that represents the route
 
 */
class BusMapAnnotationView: MKAnnotationView {
    
    /// The image view that displays the bus image
    private var imageView : UIImageView?
    
    /**
     This method has two functions
     
     + It provides a way to create the image view if it hasn't been created yet
     + It changes the tint color of the bus when needed
     
      - parameter color: The color that represents the route
     */
    func setBusColor(color : UIColor){
        
        if let iv = imageView{
            iv.tintColor = color
            return
        }
        
        self.imageView = UIImageView(image: UIImage(named: "bus")!.imageWithRenderingMode(.AlwaysTemplate))
        self.imageView!.tintColor = color
        self.imageView?.frame.size = CGSize(width: 20, height: 20)
        self.addSubview(self.imageView!)
        self.frame.size = CGSize(width: 20, height: 20)
    }
    
}
