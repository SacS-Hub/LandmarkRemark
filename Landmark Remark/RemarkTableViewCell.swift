//
//  File.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 04/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import Foundation
import UIKit

class RemarkTableViewCell: UITableViewCell {

    @IBOutlet weak var userLbl: UILabel!
    @IBOutlet weak var remarkLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    
    static let cellId = "RemarkTableViewCellID"
    
    /*
     Method      : setCellContents
     Description : Assign values to cell elements
     parameter   : remark
     Return      : none
     */
    func setCellContents(remark: Remark){
        
//        guard let username = remark.user.username,
//              let message = remark.message,
//              let date = remark.date else {
//            return
//        }
        self.userLbl.text = remark.user.username
        self.remarkLbl.text = remark.message
        self.dateLbl.text = remark.date
    }
}
