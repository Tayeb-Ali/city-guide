//
//  HomeView.swift
//  trid
//
//  Created by Black on 2/15/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

protocol ExploreHomeViewDelegate {
    func exploreHomeViewAll(categoryType: FCategoryType)
    func exploreHome(_ explore: ExploreHomeView, didSelectedPlace p: FPlace, type: FCategoryType)
    func exploreHomeShowCityInfo()
    func exploreHomeShowEmergency()
    func exploreHomeShowTranspotation()
}

class ExploreHomeView: ExploreBaseView {
    
    var TagType1 = 1
    var TagType2 = 2
    
    var delegateHome: ExploreHomeViewDelegate?
    
    // - Outlet
    @IBOutlet weak var scrollMain: UIScrollView!
    @IBOutlet weak var viewMain: UIView!
    // padding
    @IBOutlet weak var viewPaddingTop: UIView!
    @IBOutlet weak var constraintPaddingTop: NSLayoutConstraint!
    // - Body
    // Tip
    @IBOutlet weak var labelTitle1: UILabel!
    @IBOutlet weak var btnViewAllType1: UIButton!
    @IBOutlet weak var collectionType1: UICollectionView!
    @IBOutlet weak var viewNoType1: UIView!
    @IBOutlet weak var labelNoType1: UILabel!
   //  @IBOutlet weak var btnAddNewTip: UIButton!
    
    // Tour
    @IBOutlet weak var labelTitle2: UILabel!
    @IBOutlet weak var btnViewAllType2: UIButton!
    @IBOutlet weak var collectionType2: UICollectionView!
    @IBOutlet weak var viewNoType2: UIView!
    @IBOutlet weak var labelNoType2: UILabel!
    
    @IBOutlet weak var btnCityInfo: UIButton!
    @IBOutlet weak var btnEmergency: UIButton!
    @IBOutlet weak var btnGettingAround: UIButton!
    
    // Custom banner ad
    @IBOutlet weak var viewBannerAd: UIView!
    @IBOutlet weak var imgBannerAd: UIImageView!
    @IBOutlet weak var constraintBannerAdHeight: NSLayoutConstraint!
    
    
    // Variables
    var categoryTypes : [FCategoryType]?
    var categories : [FCategoryType: FCategory]?
    var data : [FCategoryType: [FPlace]]?
    
    func setupData(types: [FCategoryType], cats: [FCategoryType: FCategory], places: [FCategoryType: [FPlace]]){
        categoryTypes = types
        categories = cats
        data = places
        if categoryTypes?.count == 2 && data?.count == 2 && categories?.count == 2 {
            // 1
            let type1 = categoryTypes![0]
            TagType1 = type1.rawValue
            labelTitle1.text = categories![type1]?.getName()
            labelNoType1.text = Localized.NoData
            collectionType1.tag = TagType1
            
            // 2
            let type2 = categoryTypes![1]
            TagType2 = type2.rawValue
            labelTitle2.text = categories![type2]?.getName()
            labelNoType2.text = Localized.NoData
            collectionType2.tag = TagType2
        }
    }
    
    class func create(objectId: String, paddingTop: CGFloat, inParentViewController vc: UIViewController) -> ExploreHomeView {
        let home = Bundle.main.loadNibNamed("ExploreHomeView", owner: self, options: nil)?[0] as! ExploreHomeView
        home.parentViewController = vc
        home.exploreKey = objectId
        home.paddingTopDefault = paddingTop
        home.constraintPaddingTop.constant = paddingTop
        return home
    }

    override func awakeFromNib() {
        scrollMain.delegate = self
        collectionRegisterCell(collectionType1)
        collectionType1.delegate = self
        collectionType1.dataSource = self
        collectionRegisterCell(collectionType2)
        collectionType2.delegate = self
        collectionType2.dataSource = self
        
        let cityName = AppState.shared.currentCity?.getName() ?? ""
        btnCityInfo.setTitle(Localized.GetToKnow + " " + cityName, for: .normal)
        btnEmergency.setTitle(Localized.Emergency, for: .normal)
        btnGettingAround.setTitle(Localized.GettingAround, for: .normal)
        
        // check banner ad height
        self.constraintBannerAdHeight.constant = AppState.shared.currentCity?.getBannerUrl() != nil ? 205 : 0
        if let photo = AppState.shared.currentCity?.getBannerPhoto() {
            imgBannerAd.sd_setImage(with: URL(string: photo))
        }
    }
    
    func collectionRegisterCell(_ collection: UICollectionView) {
        collection.register(UINib(nibName: TipCollectionCell.className, bundle: nil), forCellWithReuseIdentifier: TipCollectionCell.className)
        collection.register(UINib(nibName: PlaceCollectionCell.className, bundle: nil), forCellWithReuseIdentifier: PlaceCollectionCell.className)
    }
    
    // MARK: - Scroll action
    override func getContentOffset() -> CGPoint {
        return scrollMain.contentOffset
    }
    
    override func setContentOffsetY(_ y: CGFloat, animated: Bool){
        scrollMain.contentOffset.y = y
    }
    
    override func isMainScroll(_ scrollView: UIScrollView) -> Bool{
        return scrollView == scrollMain
    }
    
    // MARK: - PUBLIC Functions
    func reloadData() {
        needUpdate = false
        // Reload
        reloadType1()
        reloadType2()
    }
    
    func reloadType1(_ i: [IndexPath]? = nil) {
        collectionType1.reloadData()
        // Notip
        reloadUINoType1()
    }
    
    func reloadType2(_ i: [IndexPath]? = nil) {
        collectionType2.reloadData()
        // NO tour
        reloadUINoType2()
    }
    
    func reloadUINoType1(){
        if categoryTypes == nil || categoryTypes!.count < 1 {
            return
        }
        let type1 = categoryTypes![0]
        let list1 = data != nil ? data![type1] : nil
        let noType1 = list1 == nil || list1!.count == 0
        collectionType1.isHidden = noType1
        viewNoType1.isHidden = !noType1
        btnViewAllType1.isHidden = noType1
    }
    
    func reloadUINoType2(){
        if categoryTypes == nil || categoryTypes!.count < 2 {
            return
        }
        let type2 = categoryTypes![1]
        let list2 = data != nil ? data![type2] : nil
        let noType2 = list2 == nil || list2!.count == 0
        collectionType2.isHidden = noType2
        viewNoType2.isHidden = !noType2
        btnViewAllType2.isHidden = noType2
    }
    
    // MARK: - Calculate
    func insertTopPlace(_ p: FPlace, withReload reload: Bool) {
        if categoryTypes == nil || data == nil || categories == nil {
            return
        }
        let cats = p.getCategories()
        for type in categoryTypes! {
            if cats.contains(categories![type]!.objectId!) {
                if data![type] != nil {
                    data![type]!.insert(p, at: 0)
                }
                else{
                    data![type] = [p]
                }
                if reload {
                    if type == categoryTypes![0] {
                        reloadType1()
                    }
                    else{
                        reloadType2()
                    }
                }
            }
        }
    }
    
    func updateChangedPlace(_ p: FPlace, withReload reload: Bool){
        if categoryTypes == nil || data == nil || categories == nil {
            return
        }
        let cats = p.getCategories()
        for type in categoryTypes! {
            if cats.contains(categories![type]!.objectId!) && data![type] != nil {
                var list = data![type]!
                for i in 0 ..< list.count {
                    let old = list[i]
                    if p.objectId == old.objectId {
                        list[i] = p
                        if reload {
                            if type == categoryTypes![0] {
                                reloadType1()
                            }
                            else{
                                reloadType2()
                            }
                        }
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func actionViewAllType1(_ sender: Any) {
        if categoryTypes == nil || categoryTypes!.count == 0 {
            return
        }
        let type = categoryTypes![0]
        viewAll(type: type)
    }
    
    @IBAction func actionViewAllType2(_ sender: Any) {
        if categoryTypes == nil || categoryTypes!.count == 0 {
            return
        }
        let type = categoryTypes![1]
        viewAll(type: type)
    }
    
    func viewAll(type: FCategoryType){
        if delegateHome != nil {
            delegateHome?.exploreHomeViewAll(categoryType: type)
        }
    }
    
    @IBAction func actionShowCityInfo(_ sender: Any) {
        if delegateHome != nil {
            delegateHome?.exploreHomeShowCityInfo()
        }
    }
    
    @IBAction func actionShowEmergency(_ sender: Any) {
        if delegateHome != nil {
            delegateHome?.exploreHomeShowEmergency()
        }
    }
    
    // ~ Transpotation
    @IBAction func actionOpenGettingAround(_ sender: Any) {
        if delegateHome != nil {
            delegateHome?.exploreHomeShowTranspotation()
        }
    }
    
    // Banner ad open
    @IBAction func actionOpenBannerAd(_ sender: Any) {
        guard let city = AppState.shared.currentCity else { return }
        MeasurementHelper.openBannerHome(city: city.getName())
        Utils.openUrl(city.getBannerUrl())
    }
    
}

// MARK: - CollectionviewDataSource
extension ExploreHomeView : UICollectionViewDataSource {
    //2
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if categoryTypes == nil || categoryTypes!.count < 1 || data == nil {
            return 0
        }
        let minimum : Int = 5
        let type1 = categoryTypes![0]
        let list1 = data![type1]
        if collectionView.tag == TagType1 && list1 != nil {
            return min(list1!.count, minimum)
        }
        let list2 = categoryTypes!.count < 2 ? nil : data![categoryTypes![1]]
        if collectionView.tag == TagType2 && list2 != nil {
            return min(list2!.count, minimum)
        }
        return 0
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = FCategoryType(rawValue: collectionView.tag)
        let list = data![type!]
        if list != nil {
            if type == .Tips {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TipCollectionCell.className, for: indexPath) as! TipCollectionCell
                cell.fill(place: list![indexPath.row], parentController: parentViewController, type: .Small)
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceCollectionCell.className, for: indexPath) as! PlaceCollectionCell
                let p = list![indexPath.row]
                cell.makePlace(p, categoryType: type, parentController: parentViewController, isSmall: true)
                return cell
            }
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDelegateFlowLayout
extension ExploreHomeView : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = FCategoryType(rawValue: collectionView.tag)
        let list = data![type!]
        if delegateHome != nil && list != nil {
            delegateHome?.exploreHome(self, didSelectedPlace: list![indexPath.row], type: type!)
        }
    }
    
    // UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 240, height: collectionView.bounds.height)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: AppSetting.Common.margin, bottom: 0, right: AppSetting.Common.margin)
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return AppSetting.Common.margin/2.0
    }
}



