//
//  ShopList.swift
//  CheckIn
//
//  Created by Aroliant Developer on 2/21/19.
//  Copyright © 2019 Bin. All rights reserved.
//

import Foundation

class ShopList{
    var shopId: Int
    var latitude: Double
    var longitude: Double
    var title: String
    var shopImage: String
    var shopDesctiption: String
    var couponCode: String
    var expiryDate: String
    var favCount: Int
    var photoList: String
    var couponDesc: String
    var locationDirection: String
    var locationDistance: Int

    
    
    init(id:Int,latitude: Double,longitude: Double,title: String,image: String,description: String,couponCode: String,couponDesc: String,expiryDate: String,favCount: Int,photoList: String,locationDirection: String,distance:Int) {
        self.shopId = id
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
        self.shopImage = image
        self.shopDesctiption = description
        self.couponCode = couponCode
        self.couponDesc = couponDesc
        self.expiryDate = expiryDate
        self.favCount = favCount
        self.photoList = photoList
        self.locationDirection = locationDirection
        self.locationDistance = distance
    }
}
class ShopCheckedList{
    
    var shopId: Int
    var shopName: String
    
    var checkedInDate: String
    
    init(id:Int,name: String,date: String) {
        self.shopId = id
        self.shopName = name
        self.checkedInDate = date
        
    }
    
}

