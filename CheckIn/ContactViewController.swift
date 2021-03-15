//
//  ContactViewController.swift
//  CheckIn
//
//  Created by Bin on 2018/10/4.
//  Copyright © 2018 Bin. All rights reserved.
//

import UIKit
import CoreLocation
class ContactViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate ,CLLocationManagerDelegate{

    @IBOutlet weak var contactUsView: UIView!
    @IBOutlet weak var topDesignView: UIView!
    @IBOutlet weak var aboutUsView: UIView!
    @IBOutlet weak var txt_name: UITextField!
    @IBOutlet weak var txt_email: UITextField!
    
    @IBOutlet weak var contactusLblView: UIView!
    @IBOutlet weak var txt_phone: UITextField!
    @IBOutlet weak var txt_location: UILabel!
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var contactUsLabelSuperView: UIView!
    @IBOutlet weak var top_constraint: NSLayoutConstraint!
    @IBOutlet weak var txt_message: UITextView!
    var isFirst = true;
    var upload_state = false;
    var locationManager:CLLocationManager!
    var runTimer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutUsView.setCircle(view: aboutUsView)
       // contactUsView.setCardView(view: contactUsView)
       // contactusLblView.setCardView(view: contactusLblView)
       // contactUsLabelSuperView.setRoundCardView(view: contactUsLabelSuperView)
        submitBtn.setCardView(view: submitBtn)
        self.top_constraint.constant = 8.0
        locationManager = CLLocationManager()
        locationManager.delegate = self
        let defaults = UserDefaults.standard
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        self.txt_email.text = email
        defaults.synchronize()
        self.activity_indicator.stopAnimating()
        runTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(uploadRun), userInfo: nil, repeats: true)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.topDesignView.addTopRoundedCornerToView(targetView: self.topDesignView, desiredCurve: 2)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.topDesignView.addTopRoundedCornerToView(targetView: self.topDesignView, desiredCurve: 2)
        }
    }
    @objc func uploadRun(){
        if self.upload_state {
            self.activity_indicator.stopAnimating()
            self.upload_state = false
            //show success alert
        }
    }
    
    @IBAction func select_location(_ sender: Any) {
        let autoCompleteLocationController = AutoCompleteLocationController.init(nibName: "AutoCompleteLocationController", bundle: nil)
        
        autoCompleteLocationController.completion = { [weak self] (placemark, clplacemark) in
            self?.isFirst = false
            let thoroughfare = (placemark.thoroughfare != nil) ? "\(placemark.thoroughfare!), " : ""
            let locality = (placemark.locality != nil) ? "\(placemark.locality!), " : ""
            let subLocality = (placemark.subLocality != nil) ? "\(placemark.subLocality!), " : ""
            let administrativeArea = (placemark.administrativeArea != nil) ? "\(placemark.administrativeArea!), " : ""
            let postalCode = (placemark.postalCode != nil) ? "\(placemark.postalCode!), " : ""
            let country = (placemark.country != nil) ? "\(placemark.country!)" : ""
            self?.txt_location.text = "\(thoroughfare)\(locality)\(subLocality)\(administrativeArea)\(postalCode)\(country)"
            
//            self?.companyLocationInfo = (placemark,clplacemark)
        }
        
        self.present(autoCompleteLocationController, animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
       self.top_constraint.constant = -100.0
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            self.top_constraint.constant = 8.0
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)     
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.top_constraint.constant = 8.0
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        if self.isFirst {
            self.isFirst = false
            self.getAddressFromLatLon(pdblLatitude: latitude, withLongitude: longitude)
        }
    }
    func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = pdblLatitude
        //21.228124
        let lon: Double = pdblLongitude
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                    return
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    
                    self.txt_location.text = addressString
                }
        })
        
    }  
    
    @IBAction func submit_clicked(_ sender: Any) {
        self.activity_indicator.startAnimating()
        let url_string = "http://appcheckinroute.com/rest_api/mobile_api/send_email.php"
        //let url_string = "http://vehicleapp.apps.remoteareagroup.com.au/send_email.php"
        let postString = ["name":self.txt_name.text!,"email":self.txt_email.text!,"mobile":self.txt_phone.text!,"location":self.txt_location.text!,"message":self.txt_message.text!]
        var request = URLRequest(url: URL(string: url_string)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: postString, options:.prettyPrinted)
        let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
            if error != nil{
                print("---------------------urlsession error happened------------------------")
                print(error?.localizedDescription ?? "error")
                self.upload_state = true
                return
            }
            self.upload_state = true            
        }
        task.resume()
    }
}
