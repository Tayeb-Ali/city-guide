//
//  WeatherViewController.swift
//  trid
//
//  Created by Black on 4/20/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

class WeatherViewController: DashboardBaseViewController {

    // outlet
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var viewToday: UIView!
    @IBOutlet weak var labelCity: UILabel!
    @IBOutlet weak var labelToday: UILabel!
    @IBOutlet weak var imgCondition: UIImageView!
    @IBOutlet weak var labelTemp: UILabel!
    @IBOutlet weak var labelCondition: UILabel!
    
    @IBOutlet weak var labelHuminity: UILabel!
    @IBOutlet weak var labelPop: UILabel!
    @IBOutlet weak var labelWind: UILabel!
    @IBOutlet weak var constraintCityNameHeight: NSLayoutConstraint!
    
    // var
    var city : FCity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.header.makeHeaderWeather(name: "")
        header.labelCategoryName.alpha = 0
        self.tabbar.isHidden = true
        constraintCityNameHeight.constant = AppSetting.App.headerHeight - 20
        // Header
        if city != nil {
            labelCity.text = city?.getName()
            if city!.weather != nil && city!.weather!.today != nil {
                labelTemp.text = city?.weather?.today?.tempC
                header.labelCategoryName.text = labelTemp.text
                imgCondition.image = UIImage(named: city?.weather?.today?.icon ?? "")
                labelCondition.text = city?.weather?.today?.condition
                
                labelHuminity.text = city?.weather?.today?.humidity
                labelWind.text = city?.weather?.today?.windSpeed
                labelPop.text = city?.weather?.forecast != nil && (city?.weather?.forecast?.count)! > 0 ? city?.weather?.forecast?[0].pop : "-"
            }
        }
        
        // Table
        table.register(UINib(nibName: ForecastTableCell.className, bundle: nil), forCellReuseIdentifier: ForecastTableCell.className)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension WeatherViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension WeatherViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = city?.weather?.forecast?.count ?? 0
        return count > 1 ? count - 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ForecastTableCell.className, for: indexPath) as! ForecastTableCell
        cell.fillData(day: (city?.weather?.forecast?[indexPath.row + 1])!)
        return cell
    }
}

// MARK: - UIScrollView Delegate
extension WeatherViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        // Header Color, offse > 0 -> UP
        let alpha : CGFloat = offset <= 0 ? 0 : min(1, (offset/DetailValue.PhotoShowHeight))
        header.backgroundColor = UIColor(hex6: UInt32(AppSetting.Color.blue), alpha: alpha)
        header.labelCategoryName.alpha = alpha
        
        // PHOTO SHOW bounce
        if offset <= 0 {
            scrollView.contentOffset.y = 0
        }
    }
}
