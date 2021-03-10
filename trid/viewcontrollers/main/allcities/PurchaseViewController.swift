//
//  PurchaseViewController.swift
//  trid
//
//  Created by Black on 5/9/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseViewController: UIViewController {
    
    // Outlet
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var labelDescription1: UILabel!
    @IBOutlet weak var labelDescription2: UILabel!
    @IBOutlet weak var labelDescription3: UILabel!
    @IBOutlet weak var labelDescription4: UILabel!
    @IBOutlet weak var btnBuyCity: UIButton!
    
    @IBOutlet weak var viewBuyAll: UIView!
    @IBOutlet weak var labelBuyAll: UILabel!
    @IBOutlet weak var btnBuyAll: UIButton!
    
    @IBOutlet weak var btnRestored: UIButton!
    
    // Variables
    var city : FCity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBuyCity.isEnabled = false
        btnBuyAll.isEnabled = false
        btnBuyCity.layer.cornerRadius = btnBuyCity.bounds.height/2
        btnBuyAll.layer.cornerRadius = btnBuyAll.bounds.height/2
        labelTitle.text = Localized.Unlock + " " + city.getName()
        for p in PurchaseManager.shared.products {
            if p.productIdentifier == PurchaseManager.ItemAll {
                let text = "\(p.priceLocale.currencySymbol!)\(p.price)"
                btnBuyAll.setTitle(text, for: .normal)
                btnBuyAll.isEnabled = true
            }
            if p.productIdentifier == city.getPurchaseId() {
                let text = "\(p.priceLocale.currencySymbol!)\(p.price)"
                btnBuyCity.setTitle(text, for: .normal)
                btnBuyCity.isEnabled = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Actions
    @IBAction func actionClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionBuyCity(_ sender: Any) {
        purchase(id: city.getPurchaseId())
    }
    
    @IBAction func actionBuyAll(_ sender: Any) {
        purchase(id: PurchaseManager.ItemAll)
    }
    
    func purchase(id: String){
        AppLoading.showLoading()
        PurchaseManager.shared.purchaseProduct(id, completed: {result, error in
            AppLoading.hideLoading()
            if error != nil {
                UIAlertView(title: Localized.AppFullName, message: error!, delegate: nil, cancelButtonTitle: "Ok").show()
            }
            else if result != nil {
                let alert = UIAlertView(title: Localized.AppFullName, message: "Purchase success", delegate: self, cancelButtonTitle: "Ok")
                alert.tag = id == PurchaseManager.ItemAll ? 1 : 2
                alert.show()
            }
        })
    }
    
    @IBAction func actionRestorePurchased(_ sender: Any) {
        AppLoading.showLoading()
        PurchaseManager.shared.restorePurchase(completed: {results, error in
            AppLoading.hideLoading()
            if error != nil {
                UIAlertView(title: Localized.AppFullName, message: error!, delegate: nil, cancelButtonTitle: "Ok").show()
            }
            else if results != nil {
                let alert = UIAlertView(title: Localized.AppFullName, message: "Restore purchased success", delegate: self, cancelButtonTitle: "Ok")
                alert.tag = 3
                alert.show()
            }
        })
    }
    
}

extension PurchaseViewController : UIAlertViewDelegate {
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.tag == 1 {
            // purchased all
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: NotificationKey.reloadCities, object: nil)
            })
        }
        else if alertView.tag == 2 {
            self.dismiss(animated: true, completion: {
                // purchase this city only
                NotificationCenter.default.post(name: NotificationKey.reloadCities, object: self.city)
            })
        }
        else if alertView.tag == 3 {
            // restored
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: NotificationKey.reloadCities, object: nil)
            })
        }
    }
}
