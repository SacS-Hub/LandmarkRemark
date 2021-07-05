//
//  MapViewController.swift
//  Landmark Remark
//
//  Created by Sachin Jagat on 02/07/2021.
//  Copyright © 2021 Sachin Jagat. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import FirebaseUI

class MapViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var mapViewModel : MapViewModel!
    var userCurrentLocation: CLLocationCoordinate2D?
    var isLocationUpdating = false
    var currentUser: User?
    @IBOutlet weak var remarksTableView: UITableView!
    
    @IBOutlet weak var listBarBtn: UIBarButtonItem!
    var isRemarksFiltered: Bool = false
//    var isRemarksFilteredByUser: Bool = false
    
    @IBOutlet weak var myRemarksBtn: UIButton!
    private var filteredRemarksArr: [Remark] = []
    
    private var locationManager: CLLocationManager? {
        didSet {
            self.locationManager?.delegate = self
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapViewModel.delegate = self
        
        // Setup search bar
        
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.keyboardType = .default
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        
        configureLocationManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.showsUserLocation = true
        
        // Get all the user's remarks
        mapViewModel.getAllRemarks()
    }
    
    func configureLocationManager(){
        self.locationManager = CLLocationManager()
        self.locationManager?.requestWhenInUseAuthorization()
    }
    
    
    @IBAction func logoutAction(_ sender: Any) {
        
        let alert = UIAlertController.init(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] (UIAlertAction) in
            self!.mapViewModel.logout()
            self!.mapView.removeAnnotations(self!.mapView.annotations)
            
            self?.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addRemark(_ sender: Any) {
        
        configureRemarkView(userTitle:"Hi \(currentUser!.username)!", subTitle: StringConstants.AddRemarkSubtitle, remarkId: "")
    }
    
    @IBAction func showMyRemarksAction(_ sender: Any) {
        
        isRemarksFiltered = !isRemarksFiltered
        myRemarksBtn.isSelected = !myRemarksBtn.isSelected
        
        filterRemarks(byUser: isRemarksFiltered)
        plotRemarksOnMap(remarks: filteredRemarksArr)
        remarksTableView.reloadData()
    }
    
    func configureRemarkView (userTitle: String, subTitle: String, remarkId: String = "") {
        
            // Stop updating location while adding a remark at current Lat/Long
            stopLocationUpdates()
            Utilities.getActivityIndicator(view: self.view).startAnimating()
            
            let alertController = Utilities.createCustomAlertController(title: userTitle, subtitle: subTitle)
            
            //Configure save action
        let saveAction = UIAlertAction(title: StringConstants.SaveAlertAction, style: .default) { (_) in
            let remarkTextField = alertController.textFields![0] as UITextField

//            if isUpdating {
//
//                self.landmarkViewModel.updateCurrentLandmarkRemark(remarkId, newRemark: remarkTextField.text!)
//
//            }
//            else {
            
                let remark = Remark(remarkId: remarkId, message: remarkTextField.text!, latitude: self.userCurrentLocation!.latitude, longitude: self.userCurrentLocation!.longitude, date: Utilities.dateToString(date: Date()), distance: 0.0, user: self.currentUser!)
            
            self.mapViewModel.addUserRemark(landmarkRemark: remark)
//            }
            
        }
        saveAction.isEnabled = false
        
        //Configure cancel action
        let cancelAction = UIAlertAction(title: StringConstants.CancelAlertAction, style: .cancel) { (_) in
            self.startLocationUpdates()
        }
        alertController.addTextField { (textField) in
            
        //Customize text field
        textField.placeholder = StringConstants.AlertTextfieldPlaceholder
        textField.keyboardType = .default
        textField.autocorrectionType = .yes
        textField.autocapitalizationType = .sentences
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
            
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                saveAction.isEnabled = textField.text != ""
            }
        
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func showRemarkList(_ sender: Any) {
        
        remarksTableView.isHidden = !remarksTableView.isHidden
        remarksTableView.reloadData()
        plotRemarksOnMap(remarks: filteredRemarksArr)
    }
    
    func setMapRegion(location: CLLocationCoordinate2D, distance: CLLocationDistance) {
        let region:MKCoordinateRegion = MKCoordinateRegion(center: location,latitudinalMeters: distance, longitudinalMeters: distance)
            mapView.setRegion(region,animated:true)
                
    }
    
    func plotRemarksOnMap (remarks: [Remark]) {
        
        if let displayedAnnotations = mapView?.annotations {
            mapView?.removeAnnotations(displayedAnnotations)
        }
        
        mapView?.addAnnotations(
            remarks.map { (remark) -> AnnotationCustomModel in return AnnotationCustomModel.init(remark: remark)!
                
                #warning("calculate distance from current location")
//                let remarkLocation = CLLocation(latitude: remark.latitude, longitude: remark.longitude)
//
//                // Calculate distance of landmark from currrent location
//                let distanceFromUser = remarkLocation.distance(from: userCurrentLocation.l)
//                remark.distance = Utilities.
            }
        )

        if(remarks.count > 0){
            
            let coordinate: CLLocationCoordinate2D
            
            // Zoom to map region based on users current location if available.
            if let curLoc = userCurrentLocation {
                
                coordinate = CLLocationCoordinate2D.init(latitude: curLoc.latitude, longitude: curLoc.longitude)
            }
            else{
                coordinate = CLLocationCoordinate2D.init(latitude: remarks[0].latitude, longitude: remarks[0].longitude)
            }
            setMapRegion(location: coordinate, distance: 3000)
        }
        
    }
    
    func startLocationUpdates() {
        isLocationUpdating = true
        locationManager?.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    func stopLocationUpdates() {
        isLocationUpdating = false
        locationManager?.stopUpdatingLocation()
        mapView.showsUserLocation = false
    }
    
    
    func showAddedRemarkOnMap (remark: Remark) {
        
        let annotation = AnnotationCustomModel.init(remark: remark)
        mapView.addAnnotation(annotation!)
        mapView.selectAnnotation(annotation!, animated: true)
        
        setMapRegion(location: CLLocationCoordinate2D.init(latitude: remark.latitude, longitude: remark.longitude), distance: 3000)

    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedWhenInUse:
                manager.startUpdatingLocation()
                isLocationUpdating = true
                
                if let location = userCurrentLocation {
                    setMapRegion(location: location, distance: 3000)
                }
                break
            default:
                break
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        userCurrentLocation = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        isLocationUpdating = true
        setMapRegion(location: userCurrentLocation!, distance: 3000)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLocationUpdating = false
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? AnnotationCustomModel {

            var identifier = ""
            var pinImage: UIImage? = nil

            // Determine the annotation color based on the conditions
            if(annotation.remark.user.username.caseInsensitiveCompare(currentUser!.username) == .orderedSame){
                identifier = StringConstants.LoggedInUserRemark
                pinImage = UIImage.init(named: "userPin")
            }
            else {
                identifier = StringConstants.OtherUserRemark
                pinImage = UIImage.init(named: "otherUserPin")
            }
            
            var annotationView: MKAnnotationView?
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            }
            else {
                annotationView?.annotation = annotation
            }
            
//            let size = CGSize(width: 50, height: 50)
//                    UIGraphicsBeginImageContext(size)
//                    pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            annotationView?.image = pinImage
            annotationView?.calloutOffset = CGPoint(x: 0.0, y: 0.0)

            return annotationView
        }
        return nil
    }
    
}

extension MapViewController: RemarksDelegates {
    
    func remarkSavedWithSuccess(_ remark: Remark) {
        
        Utilities.getActivityIndicator(view: self.view).stopAnimating()
        self.present(Utilities.commonInformationAlert(title: StringConstants.AlertInformation, message: StringConstants.RemarkSaveSuccess), animated: true, completion: nil)
        
        // Show saved remark on map and list view
        showAddedRemarkOnMap(remark: remark)
        remarksTableView.reloadData()
    }
            
    func remarksFetchedWithSuccess(_ status: Bool) {
        Utilities.getActivityIndicator(view: self.view).stopAnimating()
        
        filterRemarks(byUser: isRemarksFiltered)
        // Show all the remarks on the map
        plotRemarksOnMap(remarks: filteredRemarksArr)
    }
    
    func operationFailedWithError(_ message: String) {
        Utilities.getActivityIndicator(view: self.view).stopAnimating()
        self.present(Utilities.commonInformationAlert(title: StringConstants.AlertInformation, message: message), animated: true, completion: nil)
    }

    func filterRemarks(byUser: Bool) {
        
        var filteredArr: [Remark] = []
        if let text = searchBar.text, !text.isEmpty{
            filteredArr = mapViewModel.remarksArray.filter {
                (remark) -> Bool in
                
                let username = remark.user.username.lowercased()
                let userRemark = remark.message.lowercased()
                let lowercaseSearchText = text.lowercased()
                return
                    lowercaseSearchText.contains(username) ||
                    lowercaseSearchText.contains(userRemark) ||
                    username.contains(lowercaseSearchText) ||
                    userRemark.contains(lowercaseSearchText)
                }
        }
        else {
                filteredArr = mapViewModel.remarksArray
        }
        
        filteredRemarksArr = filteredArr.filter({ (remark) -> Bool in
            if  byUser {
                return currentUser?.userId == remark.user.userId
            }
            else {
                return true
            }
        })
    }
    
}

//MARK: SearchBar Delegate Method Implementation

extension MapViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                
        filterRemarks(byUser: isRemarksFiltered)
        plotRemarksOnMap(remarks: filteredRemarksArr)
        remarksTableView.reloadData()
    }
    
}

//MARK:- UITableViewDataSource
extension MapViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredRemarksArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RemarkTableViewCell.cellId, for: indexPath) as! RemarkTableViewCell
    
            cell.setCellContents(remark: filteredRemarksArr[indexPath.row])

        return cell
        
    }
}

