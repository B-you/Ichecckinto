//
//  RestaurantList.swift
//  CheckIn
//
//  Created by 100 on 15.03.2021.
//  Copyright © 2021 Bin. All rights reserved.
//

import Foundation
struct RestaurantList: Codable {
    var  couponCode, title, shopImage: String?
    var shopDescription, location_direction : String?
    var latitude : String?
        var longitude: String?
    var favCount, distance: String?
    var shopID : String?
    var coupon_Desc,  expiryDateTime, photo_list: String?

    enum CodingKeys: String, CodingKey {
        case shopID = "shop_id"
        case couponCode = "couponCode"
             case title = "title"
                  case shopImage = "shopImage"
                       case shopDescription = "shopDescription"
                            case location_direction = "location_direction"
        case  latitude = "latitude"
              case longitude = "longitude"
        case photo_list = "photo_list"
        case favCount = "favCount"
             case distance = "distance"
        case coupon_Desc = "coupon_Desc"
        case  expiryDateTime = "expiryDateTime"
        
    }
    init(id: String,latitude: String,longitude: String,title: String,image: String,description: String,couponCode: String,couponDesc: String,expiryDate: String,favCount: String,photoList: String,locationDirection: String,distance:String) {
            self.shopID = id
            self.latitude = latitude
            self.longitude = longitude
            self.title = title
            self.shopImage = image
            self.shopDescription = description
            self.couponCode = couponCode
            self.coupon_Desc = couponDesc
            self.expiryDateTime = expiryDate
            self.favCount = favCount
            self.photo_list = photoList
            self.location_direction = locationDirection
            self.distance = distance
        }
}

