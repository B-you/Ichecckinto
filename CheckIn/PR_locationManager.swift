//
//  PR_locationManager.swift
//  CheckIn
//
//  Created by Bin on 2018/10/5.
//  Copyright © 2018 Bin. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class PR_locationManager: NSObject {
    
    static let shared = PR_locationManager()
    
    var getLocationHandler : ((Bool) -> ())?
    
    let locationManager = CLLocationManager()
    
    var currentLatLong = CLLocationCoordinate2D()
    
    func getLocationAfterUpdate(handler : @escaping(Bool) -> ()) {
        self.getLocationHandler = handler
        self.locationManager.startUpdatingLocation()
    }
    
    func startTrackingLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    /// Help to get location by lat long
    
    func getAddressFromLatLon(cordinate : CLLocationCoordinate2D, completionHandler : @escaping(CLPlacemark?) -> () ) {
        
        let loc: CLLocation = CLLocation.init(latitude: cordinate.latitude, longitude: cordinate.longitude)
        
        let ceo: CLGeocoder = CLGeocoder()
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                
                completionHandler(placemarks?.last)
        })
    }
}


extension PR_locationManager : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse
        {
            locationManager.requestLocation()
        }
        else if status == .denied , status == .restricted
        {
            let alertController = UIAlertController (title: "Title", message: "Allow location service.Go to Settings?", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                if let url = settingsUrl {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        //currentLatLong = location.coordinate
        currentLatLong = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        self.getLocationHandler?(true)
        
        self.locationManager.stopUpdatingLocation()
        
        self.getLocationHandler = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
