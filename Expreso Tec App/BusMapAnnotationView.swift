//
//  BusMapAnnotationView.swift
//  Expreso Tec App
//
//  Created by Ricardo Lopez Focil on 07/05/16.
//  Copyright © 2016 Ricardo Lopez Focil. All rights reserved.
//

import MapKit

class BusMapAnnotationView: MKAnnotationView {
    
    var imageView : UIImageView?
    
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
