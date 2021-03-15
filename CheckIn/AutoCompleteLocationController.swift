//
//  AutoCompleteLocationController.swift
//  CheckIn
//
//  Created by Bin on 2018/10/5.
//  Copyright © 2018 Bin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AutoCompleteLocationController: UIViewController {
    
    let locationManager = CLLocationManager()
    var matchingItems: [MKMapItem] = []
    var region: MKCoordinateRegion = MKCoordinateRegion.init()
    var search : MKLocalSearch!
    
    public var completion: ((MKPlacemark,CLPlacemark?) -> ())?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tbl: UITableView!
    
    let map = MKMapView.init(frame: UIScreen.main.bounds)
    
    override func loadView() {
        super.loadView()
        
        map.showsUserLocation = true
        map.showsPointsOfInterest = true
        map.isHidden = true
        
        self.view.addSubview(map)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tbl.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.searchBar.becomeFirstResponder()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initLocationManager()
        self.setUpUIWhenKeyBoardAppear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        locationManager.delegate = nil
    }
    
    func initLocationManager()  {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil &&
            selectedItem.thoroughfare != nil) ? " " : ""
        
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) &&
            (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil &&
            selectedItem.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        
        return addressLine
    }
}


extension AutoCompleteLocationController : CLLocationManagerDelegate
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
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        //Zoom to user location
        let viewRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        self.map.setRegion(viewRegion, animated: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension AutoCompleteLocationController : UITableViewDelegate , UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell")
        
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
//        cell.detailTextLabel?.text = (selectedItem.addressDictionary!["FormattedAddressLines"] as!
//            [String]).joined(separator: ",")
        
        let thoroughfare = (selectedItem.thoroughfare != nil) ? "\(selectedItem.thoroughfare!), " : ""
        let locality = (selectedItem.locality != nil) ? "\(selectedItem.locality!), " : ""
        let subLocality = (selectedItem.subLocality != nil) ? "\(selectedItem.subLocality!), " : ""
        let administrativeArea = (selectedItem.administrativeArea != nil) ? "\(selectedItem.administrativeArea!), " : ""
        let postalCode = (selectedItem.postalCode != nil) ? "\(selectedItem.postalCode!), " : ""
        let country = (selectedItem.country != nil) ? "\(selectedItem.country!)" : ""
        cell.detailTextLabel?.text = "\(thoroughfare)\(locality)\(subLocality)\(administrativeArea)\(postalCode)\(country)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = matchingItems[indexPath.row].placemark
        
        PR_locationManager.shared.getAddressFromLatLon(cordinate: selectedItem.coordinate) { [weak self] (placeDetails) in
            
            self?.completion?(selectedItem,placeDetails)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


extension AutoCompleteLocationController : UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        search?.cancel()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        request.region = self.map.region
        search = MKLocalSearch(request: request)
        
        search?.start { response, _ in
            
            guard let response = response, !searchBar.text!.isEmpty else {
                
                self.matchingItems.removeAll()
                self.tbl.reloadData();
                
                return
            }
            
            self.matchingItems = response.mapItems
            self.tbl.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK:  Handling Keyboard

extension AutoCompleteLocationController
{
    func setUpUIWhenKeyBoardAppear()  {
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] (notification) in
            
            guard let `self` = self else { return }
            
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                
                self.view.constraints.filter{$0.firstAttribute == NSLayoutConstraint.Attribute.bottom}.last!.constant =  keyboardSize.height
                
                UIView.animate(withDuration: 0.7, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { (_) in
                    
                })
                
            } else {
                debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] (notification) in
            
            guard let `self` = self else { return }
            
            self.view.constraints.filter{$0.firstAttribute == NSLayoutConstraint.Attribute.bottom}.last!.constant = 0
            
            UIView.animate(withDuration: 0.7, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                
            })
        }
    }
}



