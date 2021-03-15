//
//  RutasViewController.swift
//  CheckIn
//
//  Created by apple on 12/21/20.
//  Copyright © 2020 Bin. All rights reserved.
//

import UIKit

class RutasViewController: UIViewController {

    @IBOutlet weak var resturantView: UIView! {
        didSet {
            resturantView.layer.cornerRadius = 12
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    @IBOutlet weak var foodTrucksView: UIView! {
        didSet {
            foodTrucksView.layer.cornerRadius = 12
        }
    }
    
    @IBOutlet weak var productsView: UIView! {
        didSet {
            productsView.layer.cornerRadius = 12
        }
    }
    
    @IBOutlet weak var hotelsView: UIView! {
        didSet {
            hotelsView.layer.cornerRadius = 12
        }
    }
    
    
    @IBAction
    func resturantButton(_ sender: UIButton) {
        openResturantListingVC()
    }
    
    @IBAction
    func foodTruckButton(_ sender: UIButton) {
        openResturantListingVC()
    }
    
    @IBAction
    func productButton(_ sender: UIButton) {
        openResturantListingVC()
    }
    
    @IBAction
    func hotelsButton(_ sender: UIButton) {
        openResturantListingVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if setFirstItem {
            if let tabBarController = self.parent?.parent as? UITabBarController {
                tabBarController.selectedIndex = 0
            }
            
        }
    }
    
    private func openResturantListingVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyBoard.instantiateViewController(withIdentifier: "resturantsListingViewController")
        self.navigationController?.pushViewController(VC, animated: true)
    }
}
