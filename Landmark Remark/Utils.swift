//
//  Utils.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 03/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import Foundation
import UIKit

open class Utilities {
    
    static func getActivityIndicator(view: UIView) -> UIActivityIndicatorView {
        
        let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        activityIndicatorView.center = CGPoint(x: view.center.x, y: (view.center.y - 0))
        activityIndicatorView.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        activityIndicatorView.style = UIActivityIndicatorView.Style.large
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        
        return activityIndicatorView
    }
    
    static func createCustomAlertController(title: String, subtitle: String) -> UIAlertController {
        
        let titleFont =  UIFont(name: "Arial", size: 16)!
        let subtitleFont =  UIFont(name: "Arial", size: 12)
        
        let attributedTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font :  titleFont as Any, NSAttributedString.Key.foregroundColor : UIColor.black])
        let attributedMessage = NSAttributedString(string: subtitle, attributes: [NSAttributedString.Key.font : subtitleFont as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        let alert = UIAlertController(title: "", message: "",  preferredStyle: .alert)
        
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        return alert
    }
    
    static func commonInformationAlert(title:String, message:String) -> UIAlertController {
        let alertCtlr = createCustomAlertController(title: title, subtitle: message)
        alertCtlr.addAction(UIAlertAction(title: StringConstants.OkAlertAction, style: .cancel, handler: nil))
        return alertCtlr
    }
    
    private static func dateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
//        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
//
//        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "HH:mm dd-MMM-yyyy"
        return dateFormatter
    }
    
    
    static func dateToString(date: Date) -> String{
        return dateFormatter().string(from: date)
    }
    
    

    static func stringToDate(dateString: String) -> Date? {
        return dateFormatter().date(from: dateString)
    }
    
    static func trimSpaceFromString (string: String) -> String {
        
        return string.components(separatedBy: .whitespaces).joined()
    }
    
    static func getDistanceString(distance: Double) -> String {
        
        // If distance less than 1km then display in meters
        if distance < 1000.0 {
            
            if distance <= 50.0 {
                return "less than 20 m away"
            }
            else if distance <= 100.0 {
                return "less than 100 m away"
            }
            else if distance <= 500.0 {
                return "less than 500 m away"
            }
            else {
                // If more than 500m, show the actual distance in meters
                return "\(Double(round(10 * distance) / 10)) m away"
            }
        }
        else {
            //Show in km
            return "\(Double(round(10 * (distance/1000)) / 10)) km away"
        }
        
    }
    
}
