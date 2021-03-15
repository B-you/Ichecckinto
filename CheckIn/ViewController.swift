//
//  ViewController.swift
//  CheckIn
//
//  Created by Bin on 2018/10/3.
//  Copyright © 2018 Bin. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    static var FB_IMAGE_URL: String = ""
    var getState = 0
    var runTimer:Timer!    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activity_indicator.stopAnimating()
        runTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(goHome), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func goHome(){
        if getState > 0 {
            self.activity_indicator.stopAnimating()
            if getState == 1 {
                self.getState = 0
                runTimer.invalidate()
                runTimer = nil
                self.performSegue(withIdentifier: "go_first", sender: nil)
            }else if getState == 2 {
                self.getState = 0
                let alert = UIAlertController(title: "Registering Error!", message: "You can't register your account on the server. please do later", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                //show register server error alert
            }else
            {
                self.getState = 0
            }
        }
        
    }

    @IBAction func onClick_facebookLogin(_ sender: Any) {
        self.activity_indicator.startAnimating()
		
	
		
		LoginManager().logIn(permissions: ["email","public_profile"], from: self) { (result, error) in
            if error != nil{
                print("Facebook Login Failed:",error as Any)
                let defaults = UserDefaults.standard
                defaults.set(0, forKey: "login_state")
                defaults.synchronize()
                self.getState = 3
                return
            }else if(result!.isCancelled){
                print("result cancelled")
                self.getState = 3
                return
            }
            print("successful login")
			let fbRequest = GraphRequest(graphPath:"me", parameters: ["fields": "id,about,birthday,email,gender,name,picture"])
            fbRequest.start(completionHandler: {
                (connection,detail_result,error) in
                if error != nil {
                    print("Error Getting Info \(String(describing: error))")
                    self.getState = 3
                    return
                } else {
                    let userInfo_data = detail_result as! NSDictionary
                   
                    let pic = userInfo_data["picture"] as! NSDictionary
                    let data = pic["data"] as! NSDictionary
                    let id = userInfo_data["id"] as! String
                   // let url = data["url"]! as! String
                    //let urlData = url.replacingOccurrences(of: "50", with: "100")
                    let url = "https://graph.facebook.com/\(id)/picture?type=large"
                    ViewController.FB_IMAGE_URL = url
                    let defaults = UserDefaults.standard
                    defaults.set(1, forKey: "login_state")
                    defaults.set((userInfo_data["email"] as! String), forKey: "email")
                    defaults.synchronize()
								      
                    let url_string = "http://appcheckinroute.com/rest_api/mobile_api/register_user.php"
                    let postString = ["name":(userInfo_data["name"] as! String),"email":(userInfo_data["email"] as! String),"facebook_id":(userInfo_data["id"] as! String),"facebookImage":(url)]
                   
                    var request = URLRequest(url: URL(string: url_string)!)
                    request.httpMethod = "POST"
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = try! JSONSerialization.data(withJSONObject: postString, options:.prettyPrinted)
                    let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
                        if error != nil{
                            print("---------------------urlsession error happened------------------------")
                            print(error?.localizedDescription ?? "error")
                            self.getState = 2
                            return
                        }
                        self.getState = 1
                    }
                   
                    task.resume()
                }
            })
        }
        
    }
    
}

