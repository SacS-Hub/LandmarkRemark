//
//  RemarkModel.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 03/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import Foundation

struct Remark {
    
    let remarkId: String
    let message: String
    let latitude: Double
    let longitude: Double
    let date: Date
    let distance: Double
    let user: User
    
    init (remarkId: String, message: String, latitude: Double, longitude: Double, date: Date, distance: Double, user: User){
        
        self.remarkId = remarkId
        self.message =  message
        self.latitude = latitude
        self.longitude = longitude
        self.date = date
        self.distance = distance
        self.user = user
    }
}
