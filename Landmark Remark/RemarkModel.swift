//
//  RemarkModel.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 03/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import Foundation

struct Remark {
    
    let remarkId: String?
    let message: String
    let latitude: Double
    let longitude: Double
    let date: String
    let distance: Double
    let user: User
    
    init (remarkId: String, message: String, latitude: Double, longitude: Double, date: String, distance: Double, user: User){
        
        self.remarkId = remarkId
        self.message =  message
        self.latitude = latitude
        self.longitude = longitude
        self.date = date
        self.distance = distance
        self.user = user
    }
    
    init?(dictionary: [String: Any?]) {
        
        guard let remarkId = dictionary["remarkId"] as? String,
              let message = dictionary["message"] as? String,
              let latitude = dictionary["latitude"] as? Double,
              let longitude = dictionary["longitude"] as? Double,
              let date = dictionary["date"] as? String,
              let distance = dictionary["distance"] as? Double,
              let user = User.init(dictionary:(dictionary["user"] as? [String : Any?])!)
            else {
                return nil
        }
        
        self.init(remarkId: remarkId, message: message, latitude: latitude, longitude: longitude, date: date, distance: distance, user: user)
    }
    
    func remarkDict() -> [String:Any?]{
        return [ "remarkId": remarkId,
                 "message": message,
                 "latitude": latitude,
                 "longitude": longitude,
                 "date": date,
                 "distance": distance,
                 "user": user.userDict()
               ]
    }
}
