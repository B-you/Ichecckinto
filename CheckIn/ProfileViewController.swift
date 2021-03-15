//
//  ProfileViewController.swift
//  CheckIn
//
//  Created by Bin on 2018/10/4.
//  Copyright © 2018 Bin. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var recentActivityView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var checkedInShopListTableView: UITableView!
    @IBOutlet weak var img_photo: UIImageView!
    @IBOutlet weak var txt_name: UITextField!
    @IBOutlet weak var txt_phone: UITextField!
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_gender: UILabel!
    @IBOutlet weak var txt_birthDay: UITextField!
    @IBOutlet weak var view_changeGendar: UIView!
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var profile_img:UIImage!
    var userInfo:JSON!
    var runTimer: Timer!
    var downlaod_state = false
    var upload_state = false
    
    var checkedList: [ShopCheckedList] = []
    var user_Id: Int!
    
    override func viewDidLoad() {
        self.activity_indicator.startAnimating()
       
        runTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePhoto), userInfo: nil, repeats: true)
        super.viewDidLoad()
        //recentActivityView.setRoundCardView(view: recentActivityView)
        saveBtn.setCardView(view: saveBtn)
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.view_changeGendar.isHidden = true
        self.view.isUserInteractionEnabled = false
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        //get user info from database
        img_photo.layer.borderWidth = 0.25
        img_photo.layer.masksToBounds = false
        img_photo.layer.borderColor = UIColor.black.cgColor
        img_photo.layer.cornerRadius = img_photo.frame.height/2
        img_photo.clipsToBounds = true
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
            
            do {
                
                //let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                let json = JSON(data!)
                let parseJSON = json
                let status = parseJSON["status"].debugDescription
                print("result: \(status)")
                let parse_data = parseJSON["data"]
                self.user_Id = Int(parse_data["user_id"].debugDescription)
              
                self.userInfo = parse_data
                    
                    //set image url
                    
                self.downlaod_state = true
                    
                    //                    let session = URLSession(configuration: .default)
                    //
                    //                    // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
                    //                    let downloadPicTask = session.dataTask(with: catPictureURL) { (data, response, error) in
                    //                        // The download has finished.
                    //                        if let e = error {
                    //                            print("Error downloading cat picture: \(e)")
                    //                        } else {
                    //                            // No errors found.
                    //                            // It would be weird if we didn't have a response, so check for that too.
                    //                            if let res = response as? HTTPURLResponse {
                    //                                self.downlaod_state = true
                    //                                print("Downloaded cat picture with response code \(res.statusCode)")
                    //                                if let imageData = data {
                    //                                    // Finally convert that Data into an image and do what you wish with it.
                    //                                    self.profile_img = UIImage(data: imageData)
                    //                                    // Do something with your image.
                    //                                } else {
                    //                                    print("Couldn't get image: Image is nil")
                    //                                }
                    //                            } else {
                    //                                print("Couldn't get response code for some reason")
                    //                            }
                    //                        }
                    //                    }
                    //                    downloadPicTask.resume()
                DispatchQueue.main.async {
                    self.getShopList()
                }
                
            } catch let error as NSError {
                print("don't match data from rest api---")
                print(error)
            }
        }
        task.resume()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.profileView.addTopRoundedCornerToView(targetView: self.profileView, desiredCurve: 2.5)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.profileView.addTopRoundedCornerToView(targetView: self.profileView, desiredCurve: 2.5)
        }
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
                self.checkedInShopListTableView.reloadData()
            }
        }
        task.resume()
        
        
        
    }
    
    @objc func updatePhoto(){
        if self.downlaod_state {
            self.activity_indicator.stopAnimating()
            self.txt_name.text! = self.userInfo["name"].debugDescription
            self.txt_phone.text! = self.userInfo["phone"].debugDescription
            self.txt_email.text! = self.userInfo["email"].debugDescription
            self.txt_gender.text! = self.userInfo["gender"].debugDescription
            self.txt_birthDay.text! = self.userInfo["birth_day"].debugDescription
            
            //let fbImage = self.userInfo["facebookImage"].debugDescription
            
            let fbImage = ViewController.FB_IMAGE_URL
            let img_str = self.userInfo["img_profile"].debugDescription
            let catPictureURL = URL(string: "http://appcheckinroute.com/rest_api/mobile_api/images/\(img_str)")!
            let picUrl = URL(string: fbImage)!
            //self.downloadImage(from: catPictureURL)
            print("\n\n\n\npictureurl\(picUrl)")
            self.downloadImage(from: picUrl)
            self.downlaod_state = false
        }
        if self.upload_state {
            self.activity_indicator.stopAnimating()
            self.upload_state = false
        }
    }

    @IBAction func edit_photo(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
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
        UIGraphicsBeginImageContext(CGSize(width: 200, height: 200))
        image.draw(in: CGRect(x: 0, y: 0, width: 200, height: 200))
        let destImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        self.profile_img = destImage
        self.img_photo.image = destImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func select_gender(_ sender: Any) {
        self.view_changeGendar.isHidden = false
    }
    
    @IBAction func select_mail(_ sender: Any) {
        self.txt_gender.text = "Male"
        self.view_changeGendar.isHidden = true
    }
    
    @IBAction func select_femail(_ sender: Any) {
        self.txt_gender.text = "Femail"
        self.view_changeGendar.isHidden = true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = checkedInShopListTableView.dequeueReusableCell(withIdentifier: "userShopLIstTableViewCell", for: indexPath) as! userShopLIstTableViewCell
        let data = checkedList[indexPath.row]
        //cell.shopListView.setCardView(view: cell.shopListView)
        
        cell.shopDetails.text = data.shopName
        cell.dateLbl.text = "checked on \(data.checkedInDate)"
        tableViewHeight.constant = checkedInShopListTableView.contentSize.height
        return cell
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
       print("url\(url)")
        
        getData(from: url) { data, response, error in
            guard let datas = data, error == nil else { return }
            //print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.profile_img = UIImage(data: data!)
                self.img_photo.image = UIImage(data: data!)

            }
        }
        self.view.isUserInteractionEnabled = true
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    func uploadImage(){
        
        let img_str = self.userInfo["img_profile"].debugDescription
        let imageData = self.profile_img.pngData()
        if imageData != nil{
            let request = NSMutableURLRequest(url: NSURL(string:"http://appcheckinroute.com/rest_api/mobile_api/upload_image.php")! as URL)
            
            request.httpMethod = "POST"
            
            let boundary = "---------------------------14737809831466499882746641449"
            let contentType = "multipart/form-data; boundary=\(boundary)"
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            
            let body = NSMutableData()
            // Image
            let header_boundary = "\r\n--\(boundary)\r\n"
            body.append(Data(header_boundary.utf8))
            
            let content_disposition = "Content-Disposition: form-data; name=\"userfile\"; filename=\"\(img_str)\"\\r\n"
            body.append(Data(content_disposition.utf8))
           
            let content_type = "Content-Type: application/octet-stream\r\n\r\n"
            body.append(Data(content_type.utf8))
            body.append((imageData ?? nil)!)
            
            let end_str = "\r\n--\(boundary)--\r\n"
            body.append(Data(end_str.utf8))
            
            request.httpBody = body as Data
            
            
            let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
                if error != nil{
                    print("---------------------urlsession error happened------------------------")
                    print(error?.localizedDescription ?? "error")
                    return
                }
                let returnString = String(data: data!, encoding: String.Encoding.utf8)
                self.upload_state = true
                //print("returnString \(String(describing: returnString))")
            }
            task.resume()
        }
    }
    
    @IBAction func onClick_save(_ sender: Any) {
        self.activity_indicator.startAnimating()
        let url_string = "http://appcheckinroute.com/rest_api/mobile_api/update_user.php"
        let postString = ["name":self.txt_name.text!,"email":self.txt_email.text!,"gender":self.txt_gender.text!,"birth_day":self.txt_birthDay.text!,"phone":self.txt_phone.text!]
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
            self.uploadImage()
        }
        task.resume()
    }   
}
