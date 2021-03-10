//
//  SearchPlaceViewController.swift
//  trid
//
//  Created by Black on 10/1/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import FirebaseDatabase
import PureLayout

class SearchPlaceViewController: DashboardBaseViewController {

    // outlet
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewSearchHeader: UIView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var btnCategory: DropdownButton!
    @IBOutlet weak var constraintChooseCategoryWidth: NSLayoutConstraint!
    
    @IBOutlet weak var labelEmptyResult: UILabel!
    @IBOutlet weak var tableResult: UITableView!
    @IBOutlet weak var constraintTableBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintHeaderHeight: NSLayoutConstraint!
    
    // variable
    var isSearchPage = true
    var isFirstCome = true
    let dropDownCategory = DropDown()
    var dictAllPlaces = [FCategoryType: [FPlace]]()
    var results = [FCategoryType: [FPlace]]()
    var filterIndexCategoryType = [Int: FCategoryType]()
    var filterNames = [FCategoryType: String]()
    fileprivate var allPlaces = [FPlace]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // header
        header.isHidden = true
        constraintHeaderHeight.constant = AppSetting.App.headerHeight
        //btnBack.isHidden = !isSearchPage
        tfSearch.isHidden = !isSearchPage
        labelTitle.isHidden = isSearchPage
        labelTitle.text = Localized.Saved
        
        // Tabbar
        tabbar.isHidden = isSearchPage
        
        // dropdown
        setupDropDown()
        
        // table
        constraintTableBottom.constant = isSearchPage ? 0 : AppSetting.App.tabbarHeight
        tableResult.register(UINib(nibName: PlaceCell.className, bundle: nil), forCellReuseIdentifier: PlaceCell.className)
        tableResult.register(UINib(nibName: TipTableCell.className, bundle: nil), forCellReuseIdentifier: TipTableCell.className)
        
        // Register Notifiation
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteAdded), name: NotificationKey.favoriteAdded(""), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteDeleted), name: NotificationKey.favoriteDeleted(""), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirstCome && isSearchPage {
            tfSearch.becomeFirstResponder()
            isFirstCome = false
        }
        else if isFirstCome && !isSearchPage {
            setAllPlace(PlaceService.placesFromKeys(keys: AppState.shared.favoritedList))
            setupDropDown()
            search(forKey: "")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -
    
    func setAllPlace(_ all: [FPlace]?){
        allPlaces = all ?? []
    }
    
    // MARK: - Handle Notification
    @objc func handleFavoriteAdded(notification: Notification){
        let p = notification.object as? FPlace
        if p != nil{
            allPlaces.insert(p!, at: 0)
            setupDropDown()
            search(forKey: "")
        }
    }
    
    @objc func handleFavoriteDeleted(notification: Notification){
        let p = notification.object as? FPlace
        if p != nil
        {
            let index = allPlaces.firstIndex(where: {$0.objectId == p?.objectId})
            if index != nil {
                allPlaces.remove(at: index!)
                setupDropDown()
                search(forKey: "")
            }
        }
    }
    
    // MARK: - action
    @IBAction func actionChooseCategory(_ sender: AnyObject) {
        dropDownCategory.show()
    }
    
    @IBAction func actionBack(_ sender: AnyObject) {
        if isSearchPage {
            _ = self.navigationController?.popViewController(animated: true)
        }
        else{
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    // MARK: - Manage result
    func clearSearchResult(){
        results.removeAll()
        tableResult.reloadData()
    }
    
    func search(forKey keyword: String?){
        // search in all place
        results.removeAll()
        btnCategory.isEnabled = false
        // Search
        for key in dictAllPlaces.keys {
            // search for each key
            for place in dictAllPlaces[key]! {
                let name = place[FPlace.name] as! NSString
                if results[key] == nil {
                    results[key] = [FPlace]()
                }
                if (keyword ?? "") != "" {
                    if (name.range(of: keyword!, options: NSString.CompareOptions.caseInsensitive)).location != NSNotFound {
                        results[key]?.append(place)
                    }
                }
                else{
                    results[key]?.append(place)
                }
            }
        }
        
        
        tableResult.reloadData()
        btnCategory.isEnabled = true
    }
    
}

extension SearchPlaceViewController {
    // MARK : - Setup dropdown
    func setupDropDown() {
        // config
        dropDownCategory.dismissMode = .onTap
        dropDownCategory.anchorView = btnCategory
        dropDownCategory.bottomOffset = CGPoint(x: 0, y: 35)
        
        // data source
        var arr : [String] = ["All"]
        for cat in CityCategoryService.shared.categoriesOfCurrentCity {
            let type = cat.getType()
            let name = cat.getName()
            // Tips không search ở đây vì cell format của nó khác
            // 13/3/17 Có thể search được Tip
            if name != "" && type != nil /* && type != .Tips */ && FCategory.DisplayTypes.contains(type!) {
                // add category
                arr.append(name)
                // append all places
                filterIndexCategoryType[arr.count - 1] = type
                dictAllPlaces[type!] = PlaceService.places(fromAll: allPlaces, forCategoryKey: cat.objectId!)
                filterNames[type!] = name
            }
        }
        dropDownCategory.dataSource = arr
        
        // Action triggered on selection
        dropDownCategory.selectionAction = {[unowned self] (index, item) in
            self.btnCategory.setNewText(item)
            self.constraintChooseCategoryWidth.constant = 22 + item.widthWithConstrainedHeight(height: 18, font: self.btnCategory.getTextFont())
            // if searching -> filter result
            if !self.isSearchPage || (self.tfSearch.text ?? "" != "") {
                self.tableResult.reloadData()
            }
        }
        // set selected at index 0
        dropDownCategory.selectRow(at: 0)
        dropDownCategory.selectionAction?(0, arr[0])
        
        // setup appearance
        setupCustomizeAppearance(self)
        // setupDefaultAppearance()
    }
    
    func setupDefaultAppearance(){
        DropDown.setupDefaultAppearance()
        dropDownCategory.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
        dropDownCategory.customCellConfiguration = nil
    }
    
    func setupCustomizeAppearance(_ sender: AnyObject) {
        let appearance = DropDown.appearance()
        appearance.cellHeight = 40
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2) // UIColor(netHex: AppSetting.Color.blue) //
        appearance.separatorColor = UIColor(netHex: 0xeeeeee)
        appearance.cornerRadius = 3
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25
        appearance.animationduration = 0.25
        appearance.textColor = UIColor(netHex: AppSetting.Color.gray)
        appearance.textFont = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.normal)!
    }
}

// MARK: - Textfield delegate
extension SearchPlaceViewController : UITextFieldDelegate{
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

// MARK: - Table delegate
extension SearchPlaceViewController : UITableViewDelegate {
    // header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let filter = dropDownCategory.indexForSelectedRow!
        if filter != 0 {
            return nil
        }
        // init view header
        let height = self.tableView(tableView, heightForHeaderInSection: section)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: AppSetting.App.screenSize.width, height: height))
        view.backgroundColor = UIColor.white
        let label = UILabel(forAutoLayout: ())
        label.font = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.big)
        label.textColor = UIColor(netHex: AppSetting.Color.gray)
        label.text = filterNames[Array(results.keys)[section]]
        view.addSubview(label)
        label.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: 10)
        label.autoPinEdge(toSuperviewEdge: ALEdge.top)
        label.autoPinEdge(toSuperviewEdge: ALEdge.trailing)
        label.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let filter = dropDownCategory.indexForSelectedRow!
        return filter == 0 ? 35 : 0
    }
    
    // cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // get snap
        let filter = dropDownCategory.indexForSelectedRow ?? 0
        let filterType = filter == 0 ? Array(results.keys)[indexPath.section] : filterIndexCategoryType[filter]
        let place : FPlace? = results[filterType!]![indexPath.row]
        // move
        if filterType == .Tips {
            // Move to Tip Detail page
            let controller = CommentViewController(nibName: "CommentViewController", bundle: nil)
            controller.categoryType = FCategoryType.Tips
            controller.place = place
            _ = self.navigationController?.pushViewController(controller, animated: true)
        }
        else{
            let detail = DetailViewController(nibName: "DetailViewController", bundle: nil)
            detail.categoryType = filterType
            detail.place = place
            _ = self.navigationController?.pushViewController(detail, animated: true)
        }
    }
}

// MARK: - Table datasource
extension SearchPlaceViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dropDownCategory.indexForSelectedRow == 0 ? results.keys.count : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return allPlaces[Int(1)]!.count
        let filter = dropDownCategory.indexForSelectedRow
        if filter! == 0 {
            return results[Array(results.keys)[section]]!.count
        }
        let arr = results[filterIndexCategoryType[filter!]!]
        return arr == nil ? 0 : (arr?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // parse data
        let filter = dropDownCategory.indexForSelectedRow ?? 0
        let filterType = filter == 0 ? Array(results.keys)[indexPath.section] : filterIndexCategoryType[filter]
        let arr = results[filterType!]
        if arr == nil {
            return UITableViewCell()
        }
        let place : FPlace? =  arr![indexPath.row]
        if filterType == .Tips {
            // Tip
            let cell = tableView.dequeueReusableCell(withIdentifier: TipTableCell.className, for: indexPath) as! TipTableCell
            // init cell
            if place != nil {
                cell.fill(place: place!, parentController: self, type: .Small)
            }
            return cell
        }
        // Other
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceCell.className, for: indexPath) as! PlaceCell
        // init cell
        if place != nil {
            cell.makePlace(place!, categoryType: filterType, parentController: self)
        }
        return cell
    }
}
