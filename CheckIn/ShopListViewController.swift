//
//  ShopListViewController.swift
//  CheckIn
//
//  Created by Bin on 2018/10/4.
//  Copyright © 2018 Bin. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import AlamofireImage

class ShopListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource ,CLLocationManagerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var tbl_shopList: UITableView!
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
   
    var longitude = 0.0
    var latitude = 0.0
    var locationManager:CLLocationManager!
    var shop_list:JSON!
    var filter_list:JSON!
    var download_state = false
    var update_favState = false
    var runTimer: Timer!
    var shopList : [RestaurantList] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        runTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateShopList), userInfo: nil, repeats: true)
       
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activity_indicator.startAnimating()
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = false

        self.view.isUserInteractionEnabled = false
        shop_list = JSON()
        filter_list = JSON()
        tbl_shopList.rowHeight = UITableView.automaticDimension
         tbl_shopList.estimatedRowHeight = 110
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        let defaults = UserDefaults.standard
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        defaults.synchronize()
        self.shopList.removeAll()
        let url_string = "http://appcheckinroute.com/rest_api/mobile_api/get_restaurants.php"
        let postString = ["email":email]
        var request = URLRequest(url: URL(string: url_string)!)
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
    }
     @objc func updateShopList(){
       
        if self.longitude != 0.0&&self.download_state {
            
            var near_array = JSON()
            for index in shop_list {
                let item = index.1
                let shop_id = item["shop_id"].debugDescription
                let shop_latitude = item["latitude"].debugDescription
                let shop_longitude = item["longitude"].debugDescription
                let shop_title = item["title"].debugDescription
                let shop_Image = item["shopImage"].debugDescription
                let shop_Description = item["shopDescription"].debugDescription
                let coupon_Code = item["couponCode"].debugDescription
                let coupon_Description = item["coupon_Desc"].debugDescription
                let expiry_Date = item["expiryDateTime"].debugDescription
                let fav_Count = item["favCount"].debugDescription
                let distance = item["distance"].debugDescription
                let photo_List = item["photo_list"].debugDescription
                let location_Direction = item["location_direction"].debugDescription
                let shop_location = CLLocation(latitude: Double(shop_latitude)!, longitude: Double(shop_longitude)!)
                
                let userLocation = CLLocation(latitude: self.latitude, longitude: self.longitude);
                let distanceInMeters = userLocation.distance(from: shop_location)
                
                if (distanceInMeters < 1500000000)
                {
                  
                    let shopListData = RestaurantList(id: shop_id, latitude: shop_latitude, longitude: shop_longitude, title: shop_title, image: shop_Image, description: shop_Description, couponCode: coupon_Code, couponDesc: coupon_Description, expiryDate: expiry_Date, favCount: fav_Count, photoList: photo_List, locationDirection: location_Direction, distance: distance)
//                    let shopListData = RestaurantList(id: shop_id!, latitude: shop_latitude!, longitude: shop_longitude!, title: shop_title, image: shop_Image, description: shop_Desctiption, couponCode: coupon_Code, couponDesc: coupon_Description, expiryDate: expiry_Date, favCount: fav_Count!, photoList: photo_List, locationDirection: location_Direction, distance: Int(distanceInMeters))
                    near_array = item
                    self.shopList.append(shopListData)
                }
            }
            
            
            self.filter_list = near_array
            DispatchQueue.main.async {
                self.tbl_shopList.reloadData()
            }
            
            self.download_state = false
            self.activity_indicator.stopAnimating()
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
            self.view.isUserInteractionEnabled = true
        }
        if self.update_favState {
            DispatchQueue.main.async {
                self.tbl_shopList.reloadData()
            }
            self.activity_indicator.stopAnimating()
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
            self.view.isUserInteractionEnabled = true
            self.update_favState = false
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] as CLLocation
        self.latitude = userLocation.coordinate.latitude
        self.longitude = userLocation.coordinate.longitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return filter_list.count
        return shopList.count
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopTableViewCell") as! ShopTableViewCell
       // let item = self.filter_list[indexPath.row]
        let item = self.shopList[indexPath.row]
//        cell.txt_coupon_desc.text! = item["coupon_desc"].debugDescription
//        cell.lbl_time.text! = item["expire_time"].debugDescription
//        cell.lbl_favCount.text! = item["fav_count"].debugDescription
//
//        let img_str = item["img_logo"].debugDescription
        cell.txt_coupon_desc.text! = item.shopDescription ?? ""
        cell.lbl_time.text! = String(item.expiryDateTime!)
        cell.lbl_favCount.text! = String(item.favCount!)
        let distance = Int(item.distance!)
        if distance! > 1000{
            cell.distance.text = ("Distance : \(String(distance!/1000)) km")
        }else{
            cell.distance.text = ("Distance : \(String(distance!)) m")
        }
        
        if let img_str = item.shopImage {
       
            let catPictureURL = NSURL(string: img_str.replacingOccurrences(of: " ", with: "%20"))! as URL
        cell.btn_setFav.tag = indexPath.row
        cell.btn_setFav.addTarget(self, action: #selector(onclick_setFav(_:)), for: .touchUpInside)
        cell.img_photo.af_setImage(withURL: catPictureURL)
        }
        cell.starView.settings.passTouchesToSuperview = false
        //downloadImage(from: catPictureURL, toCell: cell)

        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        let item = self.shopList[indexPath.row]
        let detail_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ShopDetailViewController") as? ShopDetailViewController
        detail_vc?.shopDic = item
        self.navigationController?.pushViewController(detail_vc!, animated: true)
    }
    @objc func onclick_setFav(_ sender: UIButton)
    {
        self.activity_indicator.startAnimating()
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        self.view.isUserInteractionEnabled = false
        let defaults = UserDefaults.standard
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        defaults.synchronize()
       // let item = self.filter_list[sender.tag]
         let item = self.shopList[sender.tag]
        //print("\n\n\nitem!\(item.shopId)\n\n\n")
        let url_string = "http://appcheckinroute.com/rest_api/mobile_api/add_favorite.php"
        let postString = ["user_id": "\(Constant.USER_ID)","shop_id":"\(item.shopID!)"]
        //print("\n\n\n\(postString)\n\n\n")
        var request = URLRequest(url: URL(string: url_string)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: postString, options:.prettyPrinted)
        let shop_task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
            if error != nil{
                print("---------------------urlsession error happened------------------------")
                print(error?.localizedDescription ?? "error")
                self.update_favState = true
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                if let parseJSON = json {
                    self.update_favState = true
                    let parse_data = parseJSON["status"]

                    if parse_data.debugDescription == "1"
                    {
                        var fav_count = Int(item.favCount!)
                        fav_count = fav_count!+1
                        print(self.update_favState)
                        print("\n\n\n\nfav_count\(fav_count)!\n\n\n\n")
                        //let fav_count = (item["fav_count"] as! NSString).integerValue
                       // item.setValue("\(fav_count+1)", forKey: "fav_count")
                        
                        //add fav count
                    }else
                    {
                        //show alert: you already marked as like about this shop
                    }
                    
                }
            } catch let error as NSError {
                print("don't match data from rest api---")
                print(error)
            }
        }
        shop_task.resume()
       
    }
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL, toCell: ShopTableViewCell) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                toCell.img_photo.image = UIImage(data: data)
            }
        }
    }

}
