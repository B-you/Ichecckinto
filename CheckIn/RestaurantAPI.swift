//
//  RestaurantAPI.swift
//  CheckIn
//
//  Created by 100 on 15.03.2021.
//  Copyright © 2021 Bin. All rights reserved.
//


import Foundation
import Foundation
import RxSwift
import RxCocoa

class RestaurantAPI  {
    
    // create a method for calling api which is return a Observable
    
    func fetchRestaurants(query: String, _ needsMoreData: Bool, dataTask: @escaping (URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask) -> Observable<[RestaurantList]> {
            
            return Observable.create { observer -> Disposable in

                let task = dataTask(URL(string :"http://appcheckinroute.com/rest_api/mobile_api/get_restaurants.php")!)
                { data, _, _ in
            
                    guard let data = data else {
                        observer.onError(NSError(domain: "", code: -1, userInfo: nil))
                        return
                    }
            
                    do {
                       
                        let character = try JSONDecoder().decode([RestaurantList].self, from: data)
                        observer.onNext(character)

                    } catch {
                        print("error is : \(error.localizedDescription)")
                        observer.onError(error)
                    }
                }
                task.resume()
                return Disposables.create{
                    task.cancel()
                }
            }
        }
    
}
