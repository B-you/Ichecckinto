//
//  ResturantsListingViewController.swift
//  CheckIn
//
//  Created by apple on 12/21/20.
//  Copyright © 2020 Bin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class ResturantsListingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let disposeBag = DisposeBag()
//    var shopList: [ShopList] = []
private var shopList = [RestaurantList]()
    private let service = RestaurantAPI()

    let descriptionlist = ["At Taco Bell, we’ve had innovation on our mind since Glen Bell started serving tacos at the first location in 1962 in Downey, California.","Mugaritz features head chef Andoni Aduriz, who was an apprentice at El Bulli. Situated in San Sebastian, and similar to El Bulli, has been recognised as being one of the best restaurants in the World, with two Michelin stars.","Another fantastic Basque restaurant is Arzak – situated in San Sebastian, with the cooking done by a unique father-daughter combination. Arzak mixes robust Mediterranean flavors with the 21st Century, delivering a truly once in a lifetime experience. Consider opting for the highly-recommended 16-course taster menu while visiting.", "Can Fabes is dedicated to delivering some of the finest Spanish cuisine in the country, with classical dishes at the forefront of the menu.  “The clock never ticks at Can Fabes” with it standing out as one of the unique restaurants in which you are encouraged to stay, talk and have an all round enjoyable evening after you have finished your meal. Can Fabes was also the first Catalan restaurant to be become a Michelin 3-star establishment.","Spain’s Martin Berasategui is one of the most unique restaurants in Spain in the sense that you will very rarely hear about a bad experience being had by diners. Traditional cooking techniques are blended with science to coax out the most wonderful flavours in the boldest of dishes. As with some of the other big-hitters in this list, Martin Berasategui holds 3 Michelin stars."  ]
    override func viewDidLoad() {
        super.viewDidLoad()

//        shopList.append(ShopList(id: 1, latitude: 203.2, longitude: 212.1, title: "Taco Bell", image: "tacobell", description: "At Taco Bell, we’ve had innovation on our mind since Glen Bell started serving tacos at the first location in 1962 in Downey, California. ", couponCode: "xh2j12", couponDesc: "Free for 5 days.", expiryDate: "2021/01/10", favCount: 10, photoList: "", locationDirection: "", distance: 30))
//        shopList.append(ShopList(id: 1, latitude: 203.2, longitude: 212.1, title: "Mugaritz", image: "newElBulli", description: "Mugaritz features head chef Andoni Aduriz, who was an apprentice at El Bulli. Situated in San Sebastian, and similar to El Bulli, has been recognised as being one of the best restaurants in the World, with two Michelin stars.", couponCode: "xh2j12", couponDesc: "Free for 5 days.", expiryDate: "2021/01/10", favCount: 10, photoList: "", locationDirection: "", distance: 123))
//        shopList.append(ShopList(id: 1, latitude: 203.2, longitude: 212.1, title: "Arzak", image: "newElBulli", description: "Another fantastic Basque restaurant is Arzak – situated in San Sebastian, with the cooking done by a unique father-daughter combination. Arzak mixes robust Mediterranean flavors with the 21st Century, delivering a truly once in a lifetime experience. Consider opting for the highly-recommended 16-course taster menu while visiting.", couponCode: "xh2j12", couponDesc: "Free for 5 days.", expiryDate: "2021/01/10", favCount: 10, photoList: "", locationDirection: "", distance: 2121))
//        shopList.append(ShopList(id: 1, latitude: 203.2, longitude: 212.1, title: "Can Fabes", image: "newElBulli", description: "Can Fabes is dedicated to delivering some of the finest Spanish cuisine in the country, with classical dishes at the forefront of the menu.  “The clock never ticks at Can Fabes” with it standing out as one of the unique restaurants in which you are encouraged to stay, talk and have an all round enjoyable evening after you have finished your meal. Can Fabes was also the first Catalan restaurant to be become a Michelin 3-star establishment.", couponCode: "xh2j12", couponDesc: "Free for 5 days.", expiryDate: "2021/01/10", favCount: 10, photoList: "", locationDirection: "", distance: 100))
//
//        shopList.append(ShopList(id: 1, latitude: 203.2, longitude: 212.1, title: "Martin Berasategui", image: "newElBulli", description: "Spain’s Martin Berasategui is one of the most unique restaurants in Spain in the sense that you will very rarely hear about a bad experience being had by diners. Traditional cooking techniques are blended with science to coax out the most wonderful flavours in the boldest of dishes. As with some of the other big-hitters in this list, Martin Berasategui holds 3 Michelin stars.", couponCode: "xh2j12", couponDesc: "Free for 5 days.", expiryDate: "2021/01/10", favCount: 2, photoList: "", locationDirection: "", distance: 5630))

    }
    
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
       shopList.removeAll()
        service.fetchRestaurants(query: "", false, dataTask: URLSession.shared.dataTask(with:completionHandler:)).subscribe(onNext:{ model in
            self.shopList.append(contentsOf: model)
            print("mycount is \(self.shopList.count)")
           
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
           

           }).disposed(by: disposeBag)
    }
    

}

extension ResturantsListingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return filter_list.count
        return shopList.count
    }

}


extension ResturantsListingViewController: UITableViewDelegate {
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewCell") as! ShopTableViewCell
       // let item = self.filter_list[indexPath.row]
        let item = self.shopList[indexPath.row]
//        cell.txt_coupon_desc.text! = item["coupon_desc"].debugDescription
//        cell.lbl_time.text! = item["expire_time"].debugDescription
//        cell.lbl_favCount.text! = item["fav_count"].debugDescription
//
//        let img_str = item["img_logo"].debugDescription
        if indexPath.row < descriptionlist.count {
        cell.txt_coupon_desc.text! = self.descriptionlist[indexPath.row]
        }
    
        cell.lbl_time.text! = String(item.expiryDateTime!)
        cell.lbl_favCount.text! = item.favCount!
        let intdistance = Int(item.distance!)
        if intdistance! > 1000{
            cell.distance.text = ("Distance : \(String(intdistance!/1000)) km")
        }else{
            cell.distance.text = ("Distance : \(String(intdistance!)) m")
        }
        
        if  let img_str = item.shopImage {
       
        let catPictureURL = NSURL(string: img_str.replacingOccurrences(of: " ", with: "%20"))! as URL
        cell.btn_setFav.tag = indexPath.row
        //cell.btn_setFav.addTarget(self, action: #selector(onclick_setFav(_:)), for: .touchUpInside)
        cell.img_photo.af_setImage(withURL: catPictureURL)
            cell.img_photo.image = UIImage(named: item.shopImage ?? "")
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
        detail_vc?.fromRutas = true
        self.navigationController?.pushViewController(detail_vc!, animated: true)
    }
}
