//
//  UserProfileViewController.swift
//  CheckIn
//
//  Created by Aroliant Developer on 2/23/19.
//  Copyright © 2019 Bin. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserProfileViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var styleView: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var checkedInShopListTableview: UITableView!
   
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var checkedList: [ShopCheckedList] = []
  
    var user_Id: Int!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.red
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        //self.navigationController?.hidesBarsOnSwipe = true
       //self.styleView.backgroundColor = UIColor.init(hex: "FE2526")
        profileImg.layer.borderWidth = 0.25
        profileImg.layer.masksToBounds = false
        profileImg.layer.borderColor = UIColor.black.cgColor
        profileImg.layer.cornerRadius = profileImg.frame.height/2
        profileImg.clipsToBounds = true
        self.getUserData()
    }
    

    @IBAction func edit(_ sender: Any) {
        
        let detail_vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController
        self.navigationController?.pushViewController(detail_vc!, animated: true)
    }
    
    func getUserData(){
        self.activityIndicator.startAnimating()
        let defaults = UserDefaults.standard
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        defaults.synchronize()
        
        let url_string = "http://appcheckinroute.com/rest_api/mobile_api/get_userInfo.php"
        let postString = ["email":email]
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
                //let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                let json = JSON(data!)
                let parseJSON = json
                let status = parseJSON["status"].debugDescription
                print("result: \(status)")
                let parse_data = parseJSON["data"]
            DispatchQueue.main.async {
                  self.userName.text = ("\(parse_data["name"].debugDescription)")
                
            }
                self.user_Id = Int(parse_data["user_id"].debugDescription)
                print(self.user_Id!)
                let urlData = parse_data["facebookImage"].debugDescription
                let url: URL = NSURL(string: urlData.replacingOccurrences(of: " ", with: "%20"))! as URL
                self.profileImg.af_setImage(withURL: url)
                DispatchQueue.main.async {
                    self.getShopList()
                }
        }
        task.resume()
        self.activityIndicator.stopAnimating()
        // Do any additional setup after loading the view.
        
    }
    
    func getShopList(){

        let url_string = "http://appcheckinroute.com/rest_api/mobile_api/get_checkins.php"
        let postString = ["user_id":"\(self.user_Id!)"]
        
        checkedList.removeAll()
        var request = URLRequest(url: URL(string: url_string)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: postString, options:[])
        let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
            if error != nil{
                print("---------------------urlsession error happened------------------------")
                print(error?.localizedDescription ?? "error")
                return
            }
            let json = JSON(data!)
            let parseJSON = json
            let status = parseJSON["status"]
            //let  = parseJSON["checkins"]
            for data in parseJSON["checkins"]{
                let parse_data = data.1
                let shopId = Int(parse_data["shopID"].debugDescription)
                let shopName = parse_data["title"].debugDescription
                let checkedOn = parse_data["createdAt"].debugDescription
                let shopData = ShopCheckedList(id: shopId!, name:shopName, date: checkedOn)
                self.checkedList.append(shopData)
            }
            DispatchQueue.main.async {
                self.checkedInShopListTableview.reloadData()
            }
        }
        task.resume()
       
        
        
   }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return checkedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = checkedInShopListTableview.dequeueReusableCell(withIdentifier: "userShopLIstTableViewCell", for: indexPath) as! userShopLIstTableViewCell
        let data = checkedList[indexPath.row]
        cell.shopListView.setCardView(view: cell.shopListView)

        cell.shopDetails.text = data.shopName
        cell.dateLbl.text = "checked on \(data.checkedInDate)"
        heightConstraint.constant = checkedInShopListTableview.contentSize.height
        
        return cell
    }
}
extension UIView {

    
    func setCardView(view : UIView){

        view.layer.cornerRadius = 5.0
        view.layer.borderColor  =  UIColor.clear.cgColor
        view.layer.borderWidth = 1.5
        view.layer.shadowOpacity = 0.2
       // view.layer.shadowColor =  UIColor.lightGray.cgColor
        view.layer.shadowRadius = 1.0
        view.layer.shadowOffset = CGSize(width:2, height: 2)
        view.layer.masksToBounds = false
        
}
    func setRoundCardView(view : UIView){
        
        view.layer.cornerRadius = 30
        view.layer.borderColor  =  UIColor.clear.cgColor
        view.layer.borderWidth = 1.5
        view.layer.shadowOpacity = 0.2
        view.layer.shadowColor =  UIColor.lightGray.cgColor
        view.layer.shadowRadius = 1.0
        view.layer.shadowOffset = CGSize(width:2, height: 2)
        view.layer.masksToBounds = false
    }
    func gradientView(view: UIView){
        //let view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        
        // Create a gradient layer
        let gradient = CAGradientLayer()
        
        // gradient colors in order which they will visually appear
        gradient.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        
        // Gradient from left to right
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // set the gradient layer to the same size as the view
        gradient.frame = view.bounds
        // add the gradient layer to the views layer for rendering
        view.layer.addSublayer(gradient)
    }
    func setCircle(view: UIView){
        
        view.layer.borderWidth = 0.25
        view.layer.masksToBounds = false
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = view.frame.height/2
        view.clipsToBounds = true
        
    }
}
extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
