//
//  StringConstants.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 03/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import Foundation
import UIKit

struct StringConstants {
    
    // Firebase Constanrs
    static let FirebaseUserDBRef = "landmarkUsers"
    static let FirebaseRemarkDBRef = "landmarkRemarks"
    
    //Alert Controller
    static let AlertInformation = "Information"
    static let AddRemarkSubtitle = "Enter a short remark at this location"
    static let AlertTextfieldPlaceholder = "Please type here..."
    static let OkAlertAction = "Cancel"
    static let SaveAlertAction = "Save"
    static let CancelAlertAction = "Cancel"
    static let RemarkSaveSuccess = "User Remark added successfully"
    static let RemarkSaveError = "Error Occurred while saving"


    //Location Manager
    static let LocationError = "Unable to retrieve user location:"
    
    //Map View
    static let LoggedInUserRemark = "UserRemark"
    static let OtherUserRemark = "OtherRemark"
    static let MAP_REGION_DISTANCE = 3000
        
}
