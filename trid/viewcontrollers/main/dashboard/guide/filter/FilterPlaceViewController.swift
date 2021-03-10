//
//  FilterPlaceViewController.swift
//  trid
//
//  Created by Black on 12/22/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import TTRangeSlider

class FilterPlaceViewController: UIViewController {
    
    // outlet
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var btnReset: UIButton!
    
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    // price
    @IBOutlet weak var viewPrice: UIView!
    @IBOutlet weak var labelPriceTitle: UILabel!
    @IBOutlet weak var sliderPrice: TTRangeSlider!
    @IBOutlet weak var constraintViewPriceHeight: NSLayoutConstraint!
    
    // subcategory
    @IBOutlet weak var labelSubcategoryTitle: UILabel!
    @IBOutlet weak var tableSubcategory: UITableView!
    @IBOutlet weak var constraintTableSubCategoryHeight: NSLayoutConstraint!
    // apply
    @IBOutlet weak var btnApply: UIButton!
    
    // variables
    var categoryType : FCategoryType!
    var subcategories : [FSubcategory] = []
    var displaySub : [FSubcategory] = []
    var allPlaces : [FPlace]?
    var filter: FilterPlace?
    
    // block
    var onApplyFilter : ((FilterPlace, [FSubcategory]) -> Void)?
    var onDismiss : (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let MAX : Float = MAXFLOAT
        // calculate max
        var xMax : Float = MAX
        if allPlaces != nil && allPlaces!.count > 0 {
            let pMax = allPlaces!.max(by: {p1, p2 in
                return p1.getToPrice(categoryType: self.categoryType) < p2.getToPrice(categoryType: self.categoryType)
            })
            xMax = pMax != nil ? (pMax?.getToPrice(categoryType: self.categoryType))! : xMax
            if xMax == 0 {
                // Không có price -> hidden view price
                constraintViewPriceHeight.constant = 0
            }
            xMax = xMax == 0 ? MAX: xMax // nếu toPrice max == 0 -> lấy giá trị MAX
        }
        else{
            xMax = 1
        }
        if filter == nil {
            filter = FilterPlace(min: 0, max: xMax)
        }
        countSubPlaceWith(priceMin: filter!.minPrice, max: filter!.maxPrice)
        
        // slider money $
        sliderPrice.handleColor = UIColor(netHex: AppSetting.Color.blue).withAlphaComponent(0.75)
        sliderPrice.tintColorBetweenHandles = UIColor(netHex: AppSetting.Color.blue)
        sliderPrice.handleDiameter = 18
        sliderPrice.selectedHandleDiameterMultiplier = 1.3
        sliderPrice.lineHeight = 2.0
        sliderPrice.minLabelFont = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.normal)
        sliderPrice.maxLabelFont = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.normal)
        sliderPrice.maxLabelColour = UIColor(netHex: AppSetting.Color.black)
        sliderPrice.minLabelColour = UIColor(netHex: AppSetting.Color.black)
        sliderPrice.labelPadding = 10.0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = (categoryType == .SeeAndDo) ? "đ" : CountryService.shared.currentCountry.getDisplayCurrencySymbol()
        numberFormatter.maximumFractionDigits = 0
        sliderPrice.numberFormatterOverride = numberFormatter
        sliderPrice.step = 1
        sliderPrice.enableStep = true
        sliderPrice.delegate = self
        sliderPrice.minValue = 0
        sliderPrice.maxValue = xMax
        sliderPrice.selectedMinimum = filter!.minPrice
        sliderPrice.selectedMaximum = filter!.maxPrice
        
        // table
        tableSubcategory.register(UINib(nibName: FilterSubcategoryCell.className, bundle: nil), forCellReuseIdentifier: FilterSubcategoryCell.className)
        constraintTableSubCategoryHeight.constant = CGFloat(subcategories.count) * FilterSubcategoryCell.cellHeight()
        
        // remove header scrollview space
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Calculate
    func countSubPlaceWith(priceMin min: Float, max: Float){
        if subcategories.count <= 0 || allPlaces == nil {
            return
        }
        for sub in subcategories {
            sub.resultCount = allPlaces!.filter({p in
                let checkSub = p.getSubCategories().contains(sub.objectId!)
                if checkSub {
                    let from = p.getFromPrice(categoryType: self.categoryType)
                    let to = p.getToPrice(categoryType: self.categoryType)
                    let checkPrice = from >= min && to <= max
                    return checkPrice
                }
                return false
            }).count
        }
        displaySub = subcategories.filter({$0.resultCount > 0 || $0.selected})
        tableSubcategory.reloadData()
    }
    
    // MARK: - Actions
    // Apply
    @IBAction func actionApplyFilter(_ sender: Any) {
        if onApplyFilter != nil {
            MeasurementHelper.activeFilter()
            var selectedSubs = displaySub.filter({$0.selected})
            if selectedSubs.count == 0 {
                selectedSubs = displaySub
            }
            onApplyFilter!(FilterPlace(min: sliderPrice.selectedMinimum, max: sliderPrice.selectedMaximum), selectedSubs)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionClose(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            if self.onDismiss != nil {
                self.onDismiss!()
            }
        })
    }
    
    @IBAction func actionReset(_ sender: Any) {
        // Reset filter
        // slider
        sliderPrice.selectedMinimum = sliderPrice.minValue
        sliderPrice.selectedMaximum = sliderPrice.maxValue
        // sub selected
        for sub in subcategories {
            sub.selected = false
        }
        // apply
        countSubPlaceWith(priceMin: sliderPrice.minValue, max: sliderPrice.maxValue)
    }
    
}

// MARK: - Table delegate
extension FilterPlaceViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FilterSubcategoryCell.cellHeight()
    }
}

// MARK: - Table datasource
extension FilterPlaceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displaySub.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterSubcategoryCell.className, for: indexPath) as! FilterSubcategoryCell
        let sub = displaySub[indexPath.row]
        cell.changedState = {s in
            sub.selected = s
        }
        cell.fill(subCategory: sub)
        return cell
    }
    
}

extension FilterPlaceViewController : TTRangeSliderDelegate {
    func rangeSlider(_ sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        countSubPlaceWith(priceMin: selectedMinimum, max: selectedMaximum)
    }
}
