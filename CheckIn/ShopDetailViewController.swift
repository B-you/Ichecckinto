//
//  ShopDetailViewController.swift
//  CheckIn
//
//  Created by Bin on 2018/10/4.
//  Copyright © 2018 Bin. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import AlamofireImage

var setFirstItem = false

class ShopDetailViewController: UIViewController ,UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    var counter: Int = 0
    @IBOutlet weak var img_logo: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var txt_location_top: UITextView!
    @IBOutlet weak var imageDesignView: UIView!
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var txt_description: UITextView!
    @IBOutlet weak var txt_phoneList: UITextView!
    @IBOutlet weak var txt_emailList: UITextView!
    
    @IBOutlet weak var mealsIdeaViewCollection: UIView!
    @IBOutlet weak var txt_location_right: UITextView!
    @IBOutlet weak var map_view: MKMapView!
    @IBOutlet weak var col_view: UICollectionView!
    
    @IBOutlet weak var mealIdeasView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var addressDirectionView: UIView!
   
    @IBOutlet weak var contactDetailLblView: UIView!
    @IBOutlet weak var mapDirectionaddressView: UIView!
    
    @IBOutlet weak var checkBox1: UIView!
    @IBOutlet weak var checkBox2: UIView!
    @IBOutlet weak var checkBox3: UIView!
    @IBOutlet weak var checkBox4: UIView!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var checkBoxesView: UIView!
    
    @IBOutlet weak var checkBoxLabelView: UIView!
    
    
    @IBOutlet weak var mapDirectionAddressViewHeightCnst: NSLayoutConstraint!
    var shopDic: RestaurantList!
    var photo_list:[String]!
    var fromRutas = false
    let descriptionlist = ["At Taco Bell, we’ve had innovation on our mind since Glen Bell started serving tacos at the first location in 1962 in Downey, California.","Mugaritz features head chef Andoni Aduriz, who was an apprentice at El Bulli. Situated in San Sebastian, and similar to El Bulli, has been recognised as being one of the best restaurants in the World, with two Michelin stars.","Another fantastic Basque restaurant is Arzak – situated in San Sebastian, with the cooking done by a unique father-daughter combination. Arzak mixes robust Mediterranean flavors with the 21st Century, delivering a truly once in a lifetime experience. Consider opting for the highly-recommended 16-course taster menu while visiting.", "Can Fabes is dedicated to delivering some of the finest Spanish cuisine in the country, with classical dishes at the forefront of the menu.  “The clock never ticks at Can Fabes” with it standing out as one of the unique restaurants in which you are encouraged to stay, talk and have an all round enjoyable evening after you have finished your meal. Can Fabes was also the first Catalan restaurant to be become a Michelin 3-star establishment.","Spain’s Martin Berasategui is one of the most unique restaurants in Spain in the sense that you will very rarely hear about a bad experience being had by diners. Traditional cooking techniques are blended with science to coax out the most wonderful flavours in the boldest of dishes. As with some of the other big-hitters in this list, Martin Berasategui holds 3 Michelin stars."  ]
    let titles = ["Taco Bell","Mugaritz","Arzak", "Can Fabes", "Martin Berasategui"  ]
    override func viewDidLoad() {
        
        [checkBox1,
        checkBox2,
        checkBox3,
        checkBox4].forEach { view in
            view?.layer.cornerRadius = 5
            view?.backgroundColor = .white
            view?.layer.borderColor = UIColor.red.cgColor
            view?.layer.borderWidth = 1
        }
        
        checkInButton.layer.cornerRadius = 5
        
        mealsIdeaViewCollection.layer.cornerRadius = 5
        mealIdeasView.setCardView(view: mealIdeasView)
        addressDirectionView.setCardView(view: addressDirectionView)
        
        checkBoxLabelView.setCardView(view: checkBoxLabelView)
        contactDetailLblView.setCardView(view: contactDetailLblView)
        imageDesignView.setCardView(view: imageDesignView)
        descriptionView.setCardView(view: descriptionView)
        addressView.setCardView(view: addressView)
        contactView.setCardView(view: contactView)
        txt_description.setCardView(view: txt_description)
        self.photo_list = [String]()
       
        checkInButton.addTarget(self, action: #selector(checkInButtonNew), for: .touchUpInside)
        if fromRutas {
            mapDirectionAddressViewHeightCnst.constant = 0
            addressView.isHidden = true
            checkBoxesView.isHidden = false
        } else {
            checkBoxesView.isHidden = true
        }
        //self.photo_list  = (shopDic["photo_list"].debugDescription).components(separatedBy: ",")
        
        self.photo_list  = shopDic.photo_list?.components(separatedBy: ",")
        self.col_view.reloadData()
        
        //let logo_str = shopDic["img_logo"].debugDescription
        let logo_str = shopDic.shopImage

//        let url = NSURL(string: logo_str.replacingOccurrences(of: " ", with: "%20"))! as URL
//        self.img_logo.af_setImage(withURL: url)
        self.img_logo.image = UIImage(named: shopDic.shopImage ?? "")
      //  let url = URL(string: "http://api.checkinrouteapp.com/rest_api/shop_images/\(logo_str)")!
//        getData(from: url) { data, response, error in
//            guard let data = data, error == nil else { return }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
//            DispatchQueue.main.async() {
//                self.img_logo.image = UIImage(data: data)
//            }
//        }
//        self.lbl_title.text! = shopDic["title"] .debugDescription
//        self.lbl_title.text! = shopDic.title!
//        self.txt_location_top.text! = shopDic["location_direction"].debugDescription
        self.txt_location_top.text! = shopDic.location_direction ?? ""
       
       
//        self.txt_description.text! = shopDic["description"].debugDescription
        if shopDic.shopID == "1" {
        self.txt_description.text! = descriptionlist[0]
            self.lbl_title.text! = titles[0]
        } else  if shopDic.shopID == "2" {
            self.txt_description.text! = descriptionlist[1]
            self.lbl_title.text! = titles[1]
            } else  if shopDic.shopID == "3" {
                self.txt_description.text! = descriptionlist[2]
                self.lbl_title.text! = titles[2]
                } else  if shopDic.shopID == "4" {
                    self.txt_description.text! = descriptionlist[3]
                    self.lbl_title.text! = titles[3]
                    } else  if shopDic.shopID == "5" {
                        self.txt_description.text! = descriptionlist[4]
                        self.lbl_title.text! = titles[4]
                        } else  if shopDic.shopID == "6" {
                            self.txt_description.text! = descriptionlist[5]
                            self.lbl_title.text! = titles[5]
                            }
  //      let phones_str = shopDic["contact_detail"].debugDescription

 //       self.txt_phoneList.text! = phones_str.replacingOccurrences(of: ",", with: "\n")
//         self.txt_phoneList.text! = "hello"
        //let emails_str = shopDic["e_mail"].debugDescription
        let defaults = UserDefaults.standard
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        defaults.synchronize()
        self.txt_emailList.text! = email.replacingOccurrences(of: ",", with: "\n")
       
        //show location
     //   self.txt_location_right.text! = shopDic["location_direction"].debugDescription
        //self.txt_location_right.text! = shopDic.locationDirection
         self.txt_location_right.text! = "you are going in correct direction \n"
        //show map
    //    let latitude = Double(shopDic["latitude"].debugDescription)
    //    let longitude = Double(shopDic["longitude"].debugDescription)
        let latitude = Double(shopDic.latitude!)
        let longitude = Double(shopDic.longitude!)
        let shopLocation:CLLocation = CLLocation(latitude: 27.2046, longitude: 77.4977)
        let region = MKCoordinateRegion(center: shopLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.map_view.setRegion(region, animated: true)
        let shopAnnotation: MKPointAnnotation = MKPointAnnotation()
        shopAnnotation.coordinate = CLLocationCoordinate2DMake( 27.2046,  77.4977);
       // shopAnnotation.title = shopDic["title"].debugDescription
        shopAnnotation.title = shopDic.title
        self.map_view.addAnnotation(shopAnnotation)
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @objc
    func checkInButtonNew(_ sender: UIButton) {
        self.counter += 1
            if (self.counter == 4) {
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                setFirstItem = true
            }
        
}
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let total_width = self.col_view.layer.bounds.width
        //print("\(total_width)")
        return CGSize(width: (total_width - 20)/3, height: (total_width - 20)/3)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.photo_list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath)  as! PhotoCollectionViewCell
        let img_str = self.photo_list[indexPath.row]
        print([photo_list])
        
        print("\n\n\nphotolist:::\(img_str)\n\n\n\n")
       // let catPictureURL = URL(string: "http://api.checkinrouteapp.com/rest_api/shop_images/\(img_str)")!
       // downloadImage(from: catPictureURL, toCell: cell)
        let url = NSURL(string: img_str.replacingOccurrences(of: " ", with: ""))! as URL
        //cell.img_deal.af_setImage(withURL: url)
       downloadImage(from: url, toCell: cell)
        return cell
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL, toCell: PhotoCollectionViewCell) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                toCell.img_deal.image = UIImage(data: data)
            }
        }
    }
}

