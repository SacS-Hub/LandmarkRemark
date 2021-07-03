//
//  AnnotationModel.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 03/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import Foundation
import MapKit

class AnnotationCustomModel: MKPointAnnotation {
    
    var remark: Remark!

    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, remark: Remark){
        
        super.init()
        
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.remark = remark
    }
    
    convenience init?(remark: Remark){
        
        self.init(title: remark.user.username, subtitle: remark.message, coordinate: CLLocationCoordinate2D.init(latitude: remark.latitude, longitude: remark.longitude), remark: remark)
    }
    
}
