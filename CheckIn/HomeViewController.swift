//
//  HomeViewController.swift
//  CheckIn
//
//  Created by Bin on 2018/10/4.
//  Copyright © 2018 Bin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FacebookShare
import SwiftyJSON
import AlamofireImage
import Social


struct Constant {
    static var USER_ID = 0
}

class HomeViewController: UIViewController, CLLocationManagerDelegate ,UIImagePickerControllerDelegate,UINavigationControllerDelegate, SharingDelegate {
	
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    
    @IBOutlet weak var image1: UIImageView!
    
    @IBOutlet weak var comerciosbtn: UIButton!
    @IBOutlet weak var currentMapBtn: UIButton!
    @IBOutlet weak var checkInDetailView: UIView!
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    var shop_list:JSON!
    @IBOutlet weak var map_view: MKMapView!
    @IBOutlet weak var btn_clickPhoto: UIButton!
    @IBOutlet weak var shopDetail: UIVisualEffectView!
    @IBOutlet weak var shopImage: UIImageView!
    
    @IBOutlet weak var checkInBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var shopName: UILabel!
    
    @IBOutlet weak var shopDesc: UILabel!
    @IBOutlet weak var selfieImg: UIImageView!
    @IBOutlet weak var selfieMainView: UIVisualEffectView!
    @IBOutlet weak var selfieViewClosebtn: UIButton!
    @IBOutlet weak var selfieMainUiView: UIView!
    
    @IBOutlet weak var chkBoxesView: UIView!
    @IBOutlet weak var chB4View: UIView!
    @IBOutlet weak var chB3View: UIView!
    @IBOutlet weak var chB2View: UIView!
    @IBOutlet weak var chB1View: UIView!
    var locationManager:CLLocationManager!
    var longitude = 0.0
    var latitude = 0.0
    
    var shopLatitude = 0.0
    var shopLongitude = 0.0
    let regionRadius: CLLocationDistance = 1000
    var runTimer: Timer!
    var isFirst = true
    var download_state = false
    
    var shopImg: String!
    var shopNameTxt: String!
    var shopDecTxt: String!
    var shopId: Int!
    var userId: Int!
    var blurLayer : CALayer{
        return shopDetail.layer
    }
	
	var shareImage = UIImage()
  
    override func viewDidAppear(_ animated: Bool) {
         shopDetail.alpha = 0
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if setFirstItem {
            self.chkBoxesView.isHidden = false
            setFirstItem = false
            
            let gesture1 = UITapGestureRecognizer(target: self, action: #selector(viewTapped1(_:)))
            let gesture2 = UITapGestureRecognizer(target: self, action: #selector(viewTapped2(_:)))
            let gesture3 = UITapGestureRecognizer(target: self, action: #selector(viewTapped3(_:)))
            let gesture4 = UITapGestureRecognizer(target: self, action: #selector(viewTapped4(_:)))
            chB1View.isUserInteractionEnabled = true
            chB1View.addGestureRecognizer(gesture1)
            chB2View.isUserInteractionEnabled = true
            chB2View.addGestureRecognizer(gesture2)
            chB3View.isUserInteractionEnabled = true
            chB3View.addGestureRecognizer(gesture3)
            chB4View.isUserInteractionEnabled = true
            chB4View.addGestureRecognizer(gesture4)
        }
        checkInDetailView.isHidden = true
       
    }
    @objc func  viewTapped1(_ gesture : UITapGestureRecognizer) {
        if image1.image == UIImage(named: "checked-success.png") {
            image1.image = UIImage(named: "")
        } else {
        image1.image = UIImage(named: "checked-success.png")
        }
    }
    @objc func  viewTapped2(_ gesture : UITapGestureRecognizer) {
        if image2.image == UIImage(named: "checked-success.png") {
            image2.image = UIImage(named: "")
        } else {
        image2.image = UIImage(named: "checked-success.png")
        }
    }
    @objc func  viewTapped3(_ gesture : UITapGestureRecognizer) {
        if image3.image == UIImage(named: "checked-success.png") {
            image3.image = UIImage(named: "")
        } else {
        image3.image = UIImage(named: "checked-success.png")
        }
    }
    @objc func  viewTapped4(_ gesture : UITapGestureRecognizer) {
        if image4.image == UIImage(named: "checked-success.png") {
            image4.image = UIImage(named: "")
        } else {
        image4.image = UIImage(named: "checked-success.png")
        }
    }
    override func viewDidLoad() {
        //get userid
        chkBoxesView.isHidden = true
        self.btn_clickPhoto.setCardView(view: btn_clickPhoto)
        let logoImage:UIImage = UIImage(named: "app_icon.png")!
       // self.navigationItem.titleView = UIImageView(image: logoImage)
        selfieMainUiView.isHidden = true
        self.navigationController?.addLogoImage(image: logoImage, navItem: self.navigationItem)
        shopDetail.alpha = 0
        currentMapBtn.setCardView(view: currentMapBtn)
        comerciosbtn.setCardView(view: comerciosbtn)
        self.selfieMainView.setCardView(view: selfieMainView)
        self.selfieViewClosebtn.setCardView(view: selfieViewClosebtn)
        
        map_view.userLocation.title = "Estas aqui"
        self.shopDetail.clipsToBounds = true
        self.shopDetail.layer.cornerRadius = 10
        self.closeBtn.setCardView(view: closeBtn)
        self.checkInBtn.setCardView(view: checkInBtn)
        self.activity_indicator.startAnimating()
        self.shop_list = JSON()
        
        [chB4View,
        chB3View,
        chB2View,
        chB1View].forEach { view in
            view?.layer.cornerRadius = 5
            view?.backgroundColor = .white
            view?.layer.borderColor = UIColor.red.cgColor
            view?.layer.borderWidth = 1
        }
        
        
        
        
        
        let defaults = UserDefaults.standard
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        
        var url_string = "http://appcheckinroute.com/rest_api/mobile_api/get_userInfo.php"
        var postString = ["email":email]
        var request = URLRequest(url: URL(string: url_string)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: postString, options:.prettyPrinted)
        let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
            if error != nil{
                print("---------------------urlsession error happened------------------------")
                print(error?.localizedDescription ?? "error")
                return
            }
            do {
                //let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                let json = JSON(data!)
                let parseJSON = json
                let parse_data = parseJSON["data"]
                defaults.set(parse_data["id"].debugDescription, forKey: "user_id")
                self.userId = Int(parse_data["user_id"].debugDescription)
                Constant.USER_ID = Int(parse_data["user_id"].debugDescription)!
            } catch let error as NSError {
                print("don't match data from rest api---")
                print(error)
            }
        }
        task.resume()
        
        
        //get shoplist
		
        url_string = "http://appcheckinroute.com/rest_api/mobile_api/get_restaurants.php"
        postString = ["email":email]
        request = URLRequest(url: URL(string: url_string)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: postString, options:.prettyPrinted)
        let shop_task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
            if error != nil{
                print("---------------------urlsession error happened------------------------")
                print(error?.localizedDescription ?? "error")
                return
            }
            
            do {
                //let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                let json = JSON(data!)
                let parseJSON = json
                let parse_data = parseJSON["data"]
                self.shop_list = parse_data
                self.download_state = true
                
            } catch let error as NSError {
                print("don't match data from rest api---")
                print(error)
            }
        }
        shop_task.resume()
        
        defaults.synchronize()
        
        
        btn_clickPhoto.isHidden = true
        determineMyCurrentLocation()
        
        runTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLocation), userInfo: nil, repeats: true)
        
        //self.map_view?.showsUserLocation = true
        super.viewDidLoad()
        self.activity_indicator.stopAnimating()
        // Do any additional setup after loading the view.
		
		
	
    }
    
    @IBAction func currentMapBtnAction(_ sender: Any) {
        determineMyCurrentLocation()
        DispatchQueue.main.async {
        
            let latitude:CLLocationDegrees = 18.441051
            let longitude:CLLocationDegrees = -66.024633
            //let latitude:CLLocationDegrees = self.latitude
            //let longitude:CLLocationDegrees = self.longitude
           
            let latDelta:CLLocationDegrees = 0.01
            
            let lonDelta:CLLocationDegrees = 0.01
            
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            
            let location = CLLocationCoordinate2DMake(latitude, longitude)
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            self.map_view.setRegion(region, animated: false)
        }
       
    }
    
    @IBAction func comerciosBtnAction(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShopListViewController") as? ShopListViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func updateLocation(){
        if self.longitude != 0.0 {
            //show shop list on the map
            if download_state
            {
                for index in shop_list {
                    let item = index.1
                    
                    //let item = self.shop_list.object(at: index) as! NSDictionary
                    
                    let shop_latitude = Double(item["latitude"].debugDescription)
                    let shop_longitude = Double(item["longitude"].debugDescription)
                
                    shopLatitude = shop_latitude!
                    shopLongitude = shop_longitude!
                    let shop_location = CLLocation(latitude: shop_latitude!, longitude: shop_longitude!);
                    let userLocation = CLLocation(latitude: self.latitude, longitude: self.longitude);
                    
                    let distanceInMeters = userLocation.distance(from: shop_location)
                   
                    if (distanceInMeters < 15000000000000000)
                    {
                        let shopAnnotation: MKPointAnnotation = MKPointAnnotation()
                        shopAnnotation.coordinate = CLLocationCoordinate2DMake(shop_latitude!, shop_longitude!);
                        shopAnnotation.title = item["title"].debugDescription
                        self.map_view.addAnnotation(shopAnnotation)
                    }
                }
                self.download_state = false
                self.activity_indicator.stopAnimating()
            }
            var show_state = 0
            if shop_list.count > 0
            {
                //determine user on the shop
                for index in shop_list{
                    let item = index.1
                    
                    let shop_latitude = Double(item["latitude"].debugDescription)
                    let shop_longitude = Double(item["longitude"].debugDescription)
                    let shop_location = CLLocation(latitude: shop_latitude!, longitude: shop_longitude!);
                    let userLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
                 
                    let distanceInMeters = userLocation.distance(from: shop_location)
                    
                    if (distanceInMeters < 50)
                    {
                        
                        show_state = 1
                        let shop_Name = item["title"].debugDescription
                        let shop_Desc = item["shopDesctiption"].debugDescription
                        let shop_Img =  item["shopImage"].debugDescription
                        let shop_Id = Int(item["shop_id"].debugDescription)
                       
                        self.shopId = shop_Id!
                        self.shopNameTxt = shop_Name
                        self.shopDecTxt = shop_Desc
                        self.shopImg = shop_Img
                    }
                }
            }
           
            if show_state == 1
            {
                btn_clickPhoto.isHidden = false
            }else
            {
                btn_clickPhoto.isHidden = true
            }
          self.activity_indicator.stopAnimating()
        }
    }
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        self.latitude = userLocation.coordinate.latitude
        self.longitude = userLocation.coordinate.longitude
        
        //self.latitude = 18.441051
        //self.longitude = -66.024633
       
        if self.isFirst{
            //let location = CLLocationCoordinate2DMake(latitude, longitude)
            //let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.map_view.setRegion(region, animated: true)
            self.isFirst = false;
        }
    }
    
    @IBAction func onClick_photo(_ sender: Any) {
        self.checkInDetailView.isHidden = false
        let url: URL = NSURL(string: shopImg.replacingOccurrences(of: " ", with: "%20"))! as URL
        self.shopImage.af_setImage(withURL: url)
        self.shopName.text = self.shopNameTxt
        self.shopDesc.text = self.shopDecTxt
        self.animateIn()
//        UIView.animate(withDuration: 1, animations: {
//            self.shopDetail.isHidden = false
//
//        }, completion: nil)
        
    }
    @IBAction func closeBtn(_ sender: UIButton) {
        self.checkInDetailView.isHidden = true
        self.checkInShop()
        self.animateOut()
    }
    
    @IBAction func checkInBtn(_ sender: UIButton) {
        self.camera()
       //btnClick()
    }

    
    func animateIn() {
//        self.view.addSubview(shopDetail)
//        shopDetail.center = self.view.center
        shopDetail.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        
        
        UIView.animate(withDuration: 0.4) {
            self.shopDetail.alpha = 1
            self.shopDetail.transform = CGAffineTransform.identity
        }
        
    }


    func animateOut () {
        UIView.animate(withDuration: 0.3, animations: {
            self.shopDetail.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.shopDetail.alpha = 0
        }) { (success:Bool) in
          //self.shopDetail.removeFromSuperview()
        }
    }
    func selfiViewAnimateIn(){
       
        selfieMainView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 2.0) {
            self.selfieMainView.alpha = 1
            self.selfieMainView.transform = CGAffineTransform.identity
        }
    }
    
    func selfiViewAnimateOut(){
        UIView.animate(withDuration: 0.3, animations: {
            self.selfieMainView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.selfieMainView.alpha = 0
        }) { (success:Bool) in
            //self.shopDetail.removeFromSuperview()
        }
    }
    
    func btnClick(){
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ? .alert :.actionSheet)
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) {
            actionSheet.popoverPresentationController?.sourceView = self.view;
            actionSheet.popoverPresentationController?.sourceRect = btn_clickPhoto.bounds
        }
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        // self.camera()
    }
    
  
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            myPickerController.cameraDevice = .front
            self.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    func photoLibrary()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return // No image selected.
        }
		
		shareImage = image.resized(withPercentage: 0.5)!
		
        let photo = SharePhoto(image: image, userGenerated: true)
		
		let content = SharePhotoContent()
		content.photos = [photo]
        //var content = SharePhotoContent(photos: [photo])
        content.hashtag = Hashtag("#blueburger")
        //let shareDialog = ShareDialog(content: content)
		let shareDialog = ShareDialog(fromViewController: self, content: content, delegate: self)
		//shareDialog.shareContent = content

		shareDialog.mode = .browser

		shareDialog.show()

		
		////---------------------------------------
//		let dialog = MessageDialog(content: content, delegate: self)
//
//		//guard dialog.canShow else { return }
//
//		dialog.show()
		
		
        self.activity_indicator.startAnimating()
        self.dismiss(animated: true, completion: nil)
    }
	
	func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
		self.activity_indicator.stopAnimating()
		self.checkInShop()
		print("Share succeeded")
	}
	
	func sharer(_ sharer: Sharing, didFailWithError error: Error) {
		print("\(error.localizedDescription)")
		
		
	}
	
	func sharerDidCancel(_ sharer: Sharing) {
		print("Cancelled sharing to Facebook")

		self.selfieMainUiView.isHidden = false
		self.selfieMainView.isHidden = false
		self.sharedImage(image: shareImage)
		self.selfiViewAnimateIn()
	}
    
    @IBAction func selfiViewCloseBtn(_ sender: Any) {
        self.selfiViewAnimateOut()
        self.selfieMainUiView.isHidden = true
        self.selfieMainView.isHidden = true
    }
    
    func sharedImage(image: UIImage){
        //self.selfieImg.setCircle(view: selfieImg)
        self.selfieImg.image = image
    }
    
    func checkInShop(){
        
        let url_string = "http://appcheckinroute.com/rest_api/mobile_api/checkin.php"
        let postString = ["user_id":userId,"shop_id":2]
        var request = URLRequest(url: URL(string: url_string)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: postString, options:.prettyPrinted)
        let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
            if error != nil{
                print("---------------------urlsession error happened------------------------")
                print(error?.localizedDescription ?? "error")
                return
            }
            do {
                //let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                let json = JSON(data!)
                let parseJSON = json
                let parse_data = parseJSON["data"]
            } catch let error as NSError {
                print("don't match data from rest api---")
                print(error)
            }
        }
        task.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    func calculateDistance(first:CLLocation,second:CLLocation) -> Double {
        return first.distance(from: second)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        
        self.checkInDetailView.isHidden = false
        let url: URL = NSURL(string: shopImg.replacingOccurrences(of: " ", with: "%20"))! as URL
        self.shopImage.af_setImage(withURL: url)
        self.shopName.text = self.shopNameTxt
        self.shopDesc.text = self.shopDecTxt
        self.animateIn()
        
    }
    private func addAnnotations() {
//        let appleParkAnnotation = MKPointAnnotation()
//        appleParkAnnotation.title = "Click to checkin"
//        appleParkAnnotation.coordinate = CLLocationCoordinate2D(latitude: shopLatitude , longitude:shopLongitude)
//        map_view.addAnnotation(appleParkAnnotation)
    }
    
    @IBAction func userCurrentLocation(_ sender: Any) {
        
        let location = CLLocationCoordinate2DMake(self.latitude, self.longitude)
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.map_view.setRegion(region, animated: true)
        
    }
    
}

extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       
        if annotation is MKUserLocation {
            return nil
        }
            
        else {
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
           // annotationView = CustomAnnotationView.init(annotation: annotation, reuseIdentifier: "annotationView")
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
            annotationView.image = UIImage(named: "icon_30.png")
            annotationView.canShowCallout = true
			// annotationView.target(forAction: #selector(buttonAction(sender:)), withSender: self)
            return annotationView
        }
    }
}
extension UINavigationController {
    func addLogoImage(image: UIImage, navItem: UINavigationItem) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        view.addSubview(imageView)
        
        navItem.titleView = view
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        view.heightAnchor.constraint(equalTo: navigationBar.heightAnchor).isActive = true
        view.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor).isActive = true
    }
}
//class CustomAnnotationView : MKAnnotationView
//{
//    let selectedLabel:UIButton = UIButton.init(frame:CGRect(x: 0, y: 0, width: 180, height: 40))
//
//    override func setSelected(_ selected: Bool, animated: Bool)
//    {
//        super.setSelected(false, animated: animated)
//
//        if(selected)
//        {
//            selectedLabel.backgroundColor = UIColor.white
//           // selectedLabel.layer.borderColor = UIColor.darkGray.cgColor
//           // selectedLabel.layer.borderWidth = 2
//            selectedLabel.layer.cornerRadius = 5
//            selectedLabel.layer.masksToBounds = true
//
//            selectedLabel.center.x = 0.5 * self.frame.size.width;
//            selectedLabel.center.y = -0.5 * selectedLabel.frame.height;
//            selectedLabel.setTitle("Click to checkin", for: .normal)
//            selectedLabel.setTitleColor(UIColor.black, for: .normal)
//            selectedLabel.titleLabel?.font =  UIFont(name: "HelveticaBold", size: 15)
//            selectedLabel.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
//           // selectedLabel.target(forAction: #selector(HomeViewController.buttonAction(self)), withSender:self)
//            self.addSubview(selectedLabel)
//        }
//        else
//        {
//            selectedLabel.removeFromSuperview()
//        }
//
//    }
//
//}


extension UIImage {
	func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
		let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
		let format = imageRendererFormat
		format.opaque = isOpaque
		return UIGraphicsImageRenderer(size: canvas, format: format).image {
			_ in draw(in: CGRect(origin: .zero, size: canvas))
		}
	}
	func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
		let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
		let format = imageRendererFormat
		format.opaque = isOpaque
		return UIGraphicsImageRenderer(size: canvas, format: format).image {
			_ in draw(in: CGRect(origin: .zero, size: canvas))
		}
	}
}
