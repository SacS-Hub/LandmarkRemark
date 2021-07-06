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
    @IBOutlet weak var remarksTableView: UITableView!
    @IBOutlet weak var listBarBtn: UIBarButtonItem!
    @IBOutlet weak var myRemarksBtn: UIButton!
    
    var mapViewModel : MapViewModel!
    var userCurrentLocation: CLLocationCoordinate2D?
    var isLocationUpdating = false
    var currentUser: User?
    
    var isRemarksFiltered: Bool = false
    
    // To store all the filtered remarks.
    private var filteredRemarksArr: [Remark] = []
    
    // Property observer to assign delegate once location manager is set/initialised
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
    
    /*
     Method      : configureLocationManager
     Description : Initialise CLLocation manager to get current location updates
     parameter   : none
     Return      : none
     */
    func configureLocationManager(){
        self.locationManager = CLLocationManager()
        self.locationManager?.requestWhenInUseAuthorization()
    }
    
    // MARK: Actions
    
    /*
     Method      : logoutAction
     Description : Logout the user
     parameter   : sender
     Return      : none
     */
    @IBAction func logoutAction(_ sender: Any) {
        
        // Display logout confirmation alert
        let alert = UIAlertController.init(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] (UIAlertAction) in
            self!.mapViewModel.logout()
            self!.mapView.removeAnnotations(self!.mapView.annotations)
            
            self?.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
     Method      : addRemark
     Description : Add remark at a particular location
     parameter   : sender
     Return      : none
     */
    @IBAction func addRemark(_ sender: Any) {
        
        // Show UI to enter remarks
        configureRemarkView(userTitle:"Hi \(currentUser!.username)!", subTitle: StringConstants.AddRemarkSubtitle, remarkId: "")
    }
    
    /*
     Method      : showMyRemarksAction
     Description : Show remarkds added by the logged in user
     parameter   : sender
     Return      : none
     */
    @IBAction func showMyRemarksAction(_ sender: Any) {
        
        isRemarksFiltered = !isRemarksFiltered
        myRemarksBtn.isSelected = !myRemarksBtn.isSelected
        
        // Filter remarks for current user
        
        filterRemarks(byUser: isRemarksFiltered)
        plotRemarksOnMap(remarks: filteredRemarksArr)
        remarksTableView.reloadData()
    }
    
    /*
     Method      : showRemarkList
     Description : Show remarks in list format i.e. table
     parameter   : sender
     Return      : none
     */

    @IBAction func showRemarkList(_ sender: Any) {
        
        remarksTableView.isHidden = !remarksTableView.isHidden
        remarksTableView.reloadData()
        plotRemarksOnMap(remarks: filteredRemarksArr)
    }

    
    /*
     Method      : configureRemarkView
     Description : Configure alert view to display textfield to allow user to save
                   remark at a location
     parameter   : userTitle, subTitle, remarkId
     Return      : none
     */

    func configureRemarkView (userTitle: String, subTitle: String, remarkId: String = "") {
        
        
        // Stop updating location while adding a remark at current Lat/Long
        stopLocationUpdates()
        Utilities.getActivityIndicator(view: self.view).startAnimating()
        
        let alertController = Utilities.createCustomAlertController(title: userTitle, subtitle: subTitle)
        
        //Configure save action
        let saveAction = UIAlertAction(title: StringConstants.SaveAlertAction, style: .default) { (_) in
            let remarkTextField = alertController.textFields![0] as UITextField
            
            let remark = Remark(remarkId: remarkId, message: remarkTextField.text!, latitude: self.userCurrentLocation!.latitude, longitude: self.userCurrentLocation!.longitude, date: Utilities.dateToString(date: Date()), distance: 0.0, user: self.currentUser!)
            
            // Add user remark to firebase DB
            self.mapViewModel.addUserRemark(landmarkRemark: remark)
            
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
        
        // Enable save button once text is entered
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                saveAction.isEnabled = textField.text != ""
            }
        
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    /*
     Method      : setMapRegion
     Description : Set the visible map region based on location
     parameter   : location,distance
     Return      : none
     */
    func setMapRegion(location: CLLocationCoordinate2D, distance: CLLocationDistance) {
        let region:MKCoordinateRegion = MKCoordinateRegion(center: location,latitudinalMeters: distance, longitudinalMeters: distance)
            mapView.setRegion(region,animated:true)
                
    }
    
    /*
     Method      : plotRemarksOnMap
     Description : Show all the annotations with remark information on the map
     parameter   : remarks
     Return      : none
     */
    func plotRemarksOnMap (remarks: [Remark]) {
        
        if let displayedAnnotations = mapView?.annotations {
            mapView?.removeAnnotations(displayedAnnotations)
        }
        
        // Provide map with custom Annotation model
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
            
            // Zoom to map region based on remark location
            let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: remarks[0].latitude, longitude: remarks[0].longitude)
            setMapRegion(location: coordinate, distance: 3000)
        }
        
    }
    
    /*
     Method      : startLocationUpdates
     Description : Start fetching user location updates
     parameter   : remarks
     Return      : none
     */
    func startLocationUpdates() {
        isLocationUpdating = true
        locationManager?.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    /*
     Method      : stopLocationUpdates
     Description : Stop fetching user location updates
     parameter   : remarks
     Return      : none
     */
    func stopLocationUpdates() {
        isLocationUpdating = false
        locationManager?.stopUpdatingLocation()
        mapView.showsUserLocation = false
    }
    
    /*
     Method      : stopLocationUpdates
     Description : Stop fetching user location updates
     parameter   : remarks
     Return      : none
     */
    func showAddedRemarkOnMap (remark: Remark) {
        
        let annotation = AnnotationCustomModel.init(remark: remark)
        mapView.addAnnotation(annotation!)
        mapView.selectAnnotation(annotation!, animated: true)
        
        setMapRegion(location: CLLocationCoordinate2D.init(latitude: remark.latitude, longitude: remark.longitude), distance: 3000)

    }
}

// MARK: CLLocationManager Delegate Methods
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

// MARK: MKMapViewDelegate Delegate Methods
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? AnnotationCustomModel {

            var identifier = ""
            var pinImage: UIImage? = nil

            // Determine the annotation image based on the current logged in user
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
            
            annotationView?.image = pinImage
            annotationView?.calloutOffset = CGPoint(x: 0.0, y: 0.0)

            return annotationView
        }
        return nil
    }
    
}

// MARK: RemarksDelegates Methods
extension MapViewController: RemarksDelegates {
    
    /*
     Method      : remarkSavedWithSuccess
     Description : Callback method after remark saved successfully to firebase db
     parameter   : remark
     Return      : none
     */
    func remarkSavedWithSuccess(_ remark: Remark) {
        
        Utilities.getActivityIndicator(view: self.view).stopAnimating()
        self.present(Utilities.commonInformationAlert(title: StringConstants.AlertInformation, message: StringConstants.RemarkSaveSuccess), animated: true, completion: nil)
        
        filteredRemarksArr.append(remark)
        
        // Show saved remark on map and list/table view
        showAddedRemarkOnMap(remark: remark)
        remarksTableView.reloadData()
        startLocationUpdates()
    }
            
    /*
     Method      : remarksFetchedWithSuccess
     Description : Callback method after all remarks are retrieved successfully from
                   firebase db
     parameter   : remark
     Return      : none
     */
    func remarksFetchedWithSuccess(_ status: Bool) {
        Utilities.getActivityIndicator(view: self.view).stopAnimating()
        
        filterRemarks(byUser: isRemarksFiltered)
        // Show all the remarks on the map
        plotRemarksOnMap(remarks: filteredRemarksArr)
    }
    
    /*
     Method      : operationFailedWithError
     Description : Callback method if any error in Fierebase DB operations
     parameter   : message
     Return      : none
     */
    func operationFailedWithError(_ message: String) {
        Utilities.getActivityIndicator(view: self.view).stopAnimating()
        self.present(Utilities.commonInformationAlert(title: StringConstants.AlertInformation, message: message), animated: true, completion: nil)
        startLocationUpdates()
    }

    /*
     Method      : filterRemarks
     Description : Filter the remarks based on search (also for remarks of current user)
     parameter   : byUser
     Return      : none
     */
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
        stopLocationUpdates()
        
        if (searchText.isEmpty) {
            searchBar.resignFirstResponder()
            }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        if (searchBar.text == "")
        {
            startLocationUpdates()
        }
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

