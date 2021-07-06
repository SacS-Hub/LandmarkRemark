//
//  LandmarkModel.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 02/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import Foundation

// Model structure for user
struct User {
    
    let userId: String
    let username: String
        
    init(userId: String, username: String) {
        
        self.userId = userId
        self.username = username
    }
    
    init?(dictionary: [String: Any?]) {
        
        guard let userId = dictionary["userId"] as? String,
              let username = dictionary["username"] as? String
            else {
                return nil
        }
        
        self.init(userId: userId, username: username)
    }
    
    func userDict() -> [String:Any?]{
        return [ "userId": userId,
                 "username": username,
               ]
    }

    
    
}
