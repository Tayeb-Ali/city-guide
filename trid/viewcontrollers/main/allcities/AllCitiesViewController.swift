//
//  AllCitiesViewController.swift
//  trid
//
//  Created by Black on 9/28/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import FirebaseDatabase
import AVFoundation
import AVKit
import PureLayout
import MBProgressHUD
import GoogleMobileAds

class AllCitiesViewController: MainBaseViewController, UITableViewDelegate, UITableViewDataSource, CityServiceProtocol {
    // identifier
    let kCellIdentifier = "CityCell"
    
    // outlet
    @IBOutlet weak var tableCity: UITableView!
    @IBOutlet weak var viewBanner: UIView!
    
    // property
    var isFirstLoaded = false
    var allCities : [FCity] = []
    
    override func viewDidLoad() {
        debugPrint("AllCitiesViewController viewDidLoad")
        super.viewDidLoad()
        // header
        header.makeHeaderAllCity()
        
        // table
        self.tableCity.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: kCellIdentifier)
        self.tableCity.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        // Get Location
        _ = Le2Location.shared
        
        // Ask user for review app
        let times = AppState.setNewTimesOpenApp()
        if times == AppSetting.App.timesToAskRate {
            if #available(iOS 9.0, *){
                let alert = UIAlertController(title: " ", message: "Are you enjoying \(Localized.AppFullName) App?", preferredStyle: UIAlertController.Style.alert)
                let imgViewTitle = UIImageView(forAutoLayout: ())
                imgViewTitle.image = UIImage(named:"emoji-smiling")
                imgViewTitle.contentMode = .scaleAspectFit
                imgViewTitle.clipsToBounds = true
                alert.view.addSubview(imgViewTitle)
                imgViewTitle.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: 10)
                imgViewTitle.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
                imgViewTitle.autoSetDimensions(to: CGSize(width: 30, height: 30))
                alert.view.clipsToBounds = true
                
                let nah = UIAlertAction(title: "Nah", style: UIAlertAction.Style.default, handler: nil)
                nah.setValue(UIColor(netHex: AppSetting.Color.gray), forKey: "titleTextColor")
                alert.addAction(nah)
                alert.addAction(UIAlertAction(title: "Yeah!", style: UIAlertAction.Style.default, handler: {[unowned self] action in
                    // Open rate
                    let alert = UIAlertController(title: " ", message: "Nice! Do you mind leaving a review? It will help other travellers find the app :)", preferredStyle: UIAlertController.Style.alert)
                    let imgViewTitle = UIImageView(forAutoLayout: ())
                    imgViewTitle.image = UIImage(named:"emoji-love")
                    imgViewTitle.contentMode = .scaleAspectFit
                    imgViewTitle.clipsToBounds = true
                    alert.view.addSubview(imgViewTitle)
                    imgViewTitle.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: 10)
                    imgViewTitle.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
                    imgViewTitle.autoSetDimensions(to: CGSize(width: 30, height: 30))
                    alert.view.clipsToBounds = true
                    
                    let nah = UIAlertAction(title: "Nah", style: UIAlertAction.Style.default, handler: nil)
                    nah.setValue(UIColor(netHex: AppSetting.Color.gray), forKey: "titleTextColor")
                    alert.addAction(nah)
                    alert.addAction(UIAlertAction(title: "Sure :)", style: UIAlertAction.Style.default, handler: {action in
                        // Open rate
                        Global.openRateApp()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let alert = UIAlertView(title: Localized.RateOurApp, message: Localized.RateOurAppDescription, delegate: self, cancelButtonTitle: Localized.Close, otherButtonTitles: Localized.Rate, Localized.SendFeedback)
                alert.tag = 1
                alert.show()
            }
        }
        
        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCities), name: NotificationKey.reloadCities, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserSignedInOut), name: NotificationKey.signedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserSignedInOut), name: NotificationKey.signedOut, object: nil)
        
        createBannerAd()
    }
    
    func createBannerAd() {
        let bannerView: GADBannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        viewBanner.addSubview(bannerView)
        bannerView.autoPinEdgesToSuperviewEdges()
        bannerView.load(GADRequest())
    }
    
    @objc func reloadCities(notification: NSNotification) {
        tableCity.reloadData()
        let obj = notification.object as? FCity
        if obj != nil {
            DispatchQueue.main.async {
                self.goto(city: obj!)
            }
        }
    }
    
    @objc func onUserSignedInOut(notification: NSNotification) {
        filterAllCities()
        tableCity.reloadData()
    }
    
    func filterAllCities() {
        allCities = AppState.getCities()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppState.clearCurrentCity()
        // delegate update city
        CityService.shared.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isFirstLoaded{
            // load data
            //AppLoading.showLoadingWithProgress(value: 0)
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "Loading..."
            TridService.shared.makeFirebase(finish: { () -> Void in
                // Reload
                //AppLoading.hideLoading()
                hud.hide(animated: true)
                self.filterAllCities()
                debugPrint("All Cities count", self.allCities.count)
                self.tableCity.reloadData()
            }, updateProgress: {value, total in
                hud.detailsLabel.text = "Loaded \(Int(value*100/total))%"
            })
            isFirstLoaded = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CityService.shared.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Table delegate & datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCities.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CityCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath) as! CityCell
        // parse data
        let city = allCities[indexPath.row]
        cell.makeCity(city)
        cell.openVideoIntro = {
            MeasurementHelper.openVideoIntro(city: city.getName())
            self.openVideoUrl(city.getVideoIntroUrl())
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = allCities[indexPath.row]
        if city.getDeactived() && (AppState.currentUser == nil || !AppState.currentUser!.checkAdmin()){
            self.view.makeToast("Coming Soon")
            return
        }
        if city.getState() == .Paid {
            MeasurementHelper.openPaidCity(name: city.getName())
            Utils.purchaseCity(city, viewcontroller: self)
        }
        else {
            MeasurementHelper.openCity(name: city.getName())
            goto(city: city)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(1.15, 1.05, 1)
        UIView.animate(withDuration: 0.3, delay: 0.025, options: .allowUserInteraction, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }, completion: nil)
    }
    
    // city protocol
    func cityServiceAdded(_ city: FCity) {
        filterAllCities()
        tableCity.reloadData()
//        tableCity.beginUpdates()
//        let indexpath = IndexPath(row: CityService.shared.cities.count-1, section: 0)
//        tableCity.insertRows(at: [indexpath], with: .fade)
//        tableCity.endUpdates()
    }
    
    func cityServiceChangedAt(index: Int) {
        filterAllCities()
        tableCity.reloadData()
//        let indexpath = IndexPath(row: index, section: 0)
//        tableCity.reloadRows(at: [indexpath], with: .right)
    }
    
    func cityServiceRemovedAt(index: Int) {
        filterAllCities()
        tableCity.reloadData()
//        let indexpath = IndexPath(row: index, section: 0)
//        tableCity.deleteRows(at: [indexpath], with: .fade)
    }
    
    func openVideoUrl(_ url: String?) {
        if url == nil {
            return
        }
        let player = AVPlayer(url: URL(string: url!)!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    // MARK: - Override parent func
    override func headerBarSearchImpl(){
        // go to city search
        let search = SearchCityViewController(nibName: "SearchCityViewController", bundle: nil)
        self.navigationController?.pushViewController(search, animated: true)
    }
}

extension AllCitiesViewController : UIAlertViewDelegate {
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        //print("aaaa \(buttonIndex)")
        // 0-Cancel 1-Rate 2-Feedback
        if buttonIndex == 1 {
            Global.openRateApp()
        }
        else if buttonIndex == 2 {
            Global.sendFeedback(controller: self)
        }
    }
}
