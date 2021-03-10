//
//  SearchCityViewController.swift
//  trid
//
//  Created by Black on 10/24/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SearchCityViewController: MainBaseViewController {
    
    // outlet
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var tableResult: UITableView!
    
    // variables
    var results = [FCity]()
    var allCities : [FCity] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        filterAllCities()
        // setup ui
        self.tableResult.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: CityCell.className)
        self.tableResult.separatorStyle = UITableViewCell.SeparatorStyle.none
        // hide header
        header.isHidden = true
        
        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatedCities), name: NotificationKey.reloadCities, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserSignedInOut), name: NotificationKey.signedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserSignedInOut), name: NotificationKey.signedOut, object: nil)
    }
    
    @objc func handleUpdatedCities(notification: NSNotification) {
        tableResult.reloadData()
        let obj = notification.object as? FCity
        if obj != nil {
            self.goto(city: obj!)
        }
    }
    
    @objc func onUserSignedInOut(notification: NSNotification) {
        filterAllCities()
        search(forKey: tfSearch.text)
        tableResult.reloadData()
    }
    
    func filterAllCities() {
        allCities = AppState.getCities()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Manage result
    func clearSearchResult(){
        results.removeAll()
        tableResult.reloadData()
    }
    
    func search(forKey keyword: String?){
        // search in all cities
        results.removeAll()
        if (keyword ?? "") != "" && allCities.count > 0{
            results = allCities.filter({city in
                let name = NSString(string: city.getName())
                let found = name.range(of: keyword!, options: NSString.CompareOptions.caseInsensitive)
                return found.location != NSNotFound
            })
        }
        tableResult.reloadData()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func actionBack(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}

extension SearchCityViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = tfSearch.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: string)
        search(forKey: newString)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        clearSearchResult()
        return true
    }
}

extension SearchCityViewController : UITableViewDelegate {
    // cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CityCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get snap
        let city = results[indexPath.row]
        if city.getState() == .Paid {
            Utils.purchaseCity(city, viewcontroller: self)
        }
        else {
            goto(city: city)
        }
    }
}

extension SearchCityViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CityCell.className, for: indexPath) as! CityCell
        // parse data
        let city = results[indexPath.row]
        cell.makeCity(city)
        return cell
    }
}
