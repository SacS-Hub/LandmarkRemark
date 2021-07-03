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

class MapViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var mapViewModel : MapViewModel!
    var userCurrentLocation: CLLocationCoordinate2D?
    var isLocationUpdating = false

    
    private var locationManager: CLLocationManager? {
        didSet {
            self.locationManager?.delegate = self
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    override func viewDidLoad() {
        
        configureLocationManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.showsUserLocation = true
    }
    
    func configureLocationManager(){
        self.locationManager = CLLocationManager()
        self.locationManager?.requestWhenInUseAuthorization()
    }
    
    
    @IBAction func logoutAction(_ sender: Any) {
    }
    
    @IBAction func addRemark(_ sender: Any) {
        
        
    }
    
    @IBAction func showRemarkList(_ sender: Any) {
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
            remarks.map { (remark) -> AnnotationCustomModel in return AnnotationCustomModel.init(remark: remark)! }
        )

        if(remarks.count > 0){
            let coordinate = CLLocationCoordinate2D.init(latitude: remarks[0].latitude, longitude: remarks[0].longitude)
            setMapRegion(location: coordinate, distance: 1500)
        }
        
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedWhenInUse:
                manager.startUpdatingLocation()
                isLocationUpdating = true
                
                if let location = userCurrentLocation {
                    setMapRegion(location: location, distance: 1500)
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
        setMapRegion(location: userCurrentLocation!, distance: 1500)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLocationUpdating = false
    }
}

extension MapViewController: MKMapViewDelegate {
    
    
}

extension MapViewController: RemarksDelegates {
    
    func remarkSavedWithSuccess(_ remark: Remark) {
        
    }
            
    func remarksFetchedWithSuccess(_ status: Bool) {
        plotRemarksOnMap(remarks: mapViewModel.remarksArray)
    }
    
    func operationFailedWithError(_ message: String) {
        
    }

    
}
