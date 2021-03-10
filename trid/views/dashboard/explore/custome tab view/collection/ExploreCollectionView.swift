//
//  BCollectionView.swift
//  trid
//
//  Created by Black on 2/14/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit
import PureLayout

protocol ExploreCollectionViewDelegate {
    func exploreCollection(_ exploreView: ExploreCollectionView, didSelectItemAt indexPath: IndexPath)
    func exploreCollectionDidLoadMore(_ exploreView: ExploreCollectionView)
    func exploreCollectionDidFilter(_ exploreView: ExploreCollectionView, height: CGFloat)
}

class ExploreCollectionView: ExploreBaseView {
    
    var delegateCollection : ExploreCollectionViewDelegate?
    
    // Outlet
    var header : ExploreCollectionViewHeader?
    var collection : UICollectionView!
    
    // Variables
    var list : [FPlace]?
    var listFilter : [FPlace]?
    var canDelete = false
    var categoryType : FCategoryType?
    var currentFilter : FilterPlace?
    
    // Callback
    var onOpenFilter : (()->Void)?
    
    // Inspectable
    @IBInspectable var deleteable : Bool {
        get {
            return canDelete
        }
        set(_deleteable) {
            canDelete = _deleteable
        }
    }
    
    // INIT
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setup(categoryKey: String) {
        self.exploreKey = categoryKey
        self.categoryType = CategoryService.shared.getCategoryType(fromKey: categoryKey)
        self.clipsToBounds = false
        self.backgroundColor = .clear
        self.createCollection()
    }
    
    class func create(categoryKey: String, paddingTop: CGFloat, inParentViewController vc: UIViewController) -> ExploreCollectionView {
        let b = ExploreCollectionView(forAutoLayout: ())
        b.parentViewController = vc
        b.paddingTopDefault = paddingTop
        b.setup(categoryKey: categoryKey)
        return b
    }
    
    func createCollection(){
        let size = self.bounds.size
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collection = UICollectionView(frame: rect, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.clipsToBounds = false
        collection.dataSource = self
        collection.delegate = self
        
        // Register Place cell
        if categoryType! == FCategoryType.Tips {
            collection.register(UINib(nibName: TipCollectionCell.className, bundle: nil), forCellWithReuseIdentifier: TipCollectionCell.className)
        }
        else{
            collection.register(UINib(nibName: PlaceCollectionCell.className, bundle: nil), forCellWithReuseIdentifier: PlaceCollectionCell.className)
            collection.register(UINib(nibName: VisaCollectionViewCell.name, bundle: nil), forCellWithReuseIdentifier: VisaCollectionViewCell.name)
        }
        self.addSubview(collection)
        collection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collection.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        // Add header
        header = ExploreCollectionViewHeader.create(categoryType: categoryType)
        header!.backgroundColor = .red
        header!.frame = CGRect(x: 0, y: paddingTopDefault, width: size.width, height: ExploreCollectionViewHeader.Height)
        self.addSubview(header!)
        header!.autoresizingMask = [.flexibleWidth]
        header?.callbackFilter = {
            if self.onOpenFilter != nil {
                self.onOpenFilter!()
            }
        }
        header?.callbackRecentTips = {
            self.applyRecentTips()
        }
        header?.callbackTopTips = {
            self.applyTopTips()
        }
    }
    
    // MARK: - Filter data
    func applyRecentTips() {
        if categoryType != .Tips {
            return
        }
        listFilter = list
        reloadData()
    }
    
    func applyTopTips(){
        if categoryType != .Tips {
            return
        }
        listFilter = list?.filter({$0.getSubCategories().contains(FSubcategory.TipAdmin)})
        reloadData()
    }
    
    func applyFilter(_ filter: FilterPlace?, subcategories subs: [FSubcategory]?){
        currentFilter = filter
        if list == nil || list!.count == 0 {
            header?.changeStateFiltering(false)
            return
        }
        if filter == nil {
            header?.changeStateFiltering(false)
            listFilter = list
            reloadData()
            return
        }
        // else
        let min = (filter?.minPrice)!
        let max = (filter?.maxPrice)!
        listFilter = list!.filter({p in
            let pSubs = p.getSubCategories()
            let checkSub = subs != nil ? (subs?.filter({pSubs.contains($0.objectId!)}).count)! > 0 : true
            if checkSub {
                let from = p.getFromPrice(categoryType: self.categoryType!)
                let to = p.getToPrice(categoryType: self.categoryType!)
                let checkPrice = from >= min && to <= max
                return checkPrice
            }
            return false
        })
        header?.changeStateFiltering(listFilter?.count != list?.count)
        reloadData()
        if delegateCollection != nil && listFilter != nil {
            let s = collectionView(collection, layout: collection.collectionViewLayout, sizeForItemAt: IndexPath(row: 0, section: 0))
            delegateCollection?.exploreCollectionDidFilter(self, height: CGFloat(listFilter!.count) * s.height)
        }
    }
    
    // MARK: - PUBLIC Functions
    func reloadData(_ i: [IndexPath]? = nil) {
        collection.reloadData()
        reContentOffset()
        
        needUpdate = false
        // Đoạn này bị crash -> Tạm thời reload all
//        collection.performBatchUpdates({
//            self.collection.reloadItems(at: i!)
//        }, completion: nil)
    }
    
    func reContentOffset(){
        self.layoutIfNeeded()
        collection.contentOffset.y = lastContentOffset
    }
    
    func insertItems(at i: [IndexPath]?) {
        if i == nil {
            return
        }
        collection.insertItems(at: i!)
    }
    
    func deleteItems(at i: [IndexPath]) {
        collection.deleteItems(at: i)
    }
    
    // MARK: - ACTION
    func insertTopPlace(_ p : FPlace, withReload reload: Bool){
        if list == nil {
            list = [p]
        }
        else{
            list?.insert(p, at: 0)
        }
        if listFilter == nil {
            listFilter = [p]
        }
        else{
            listFilter?.insert(p, at: 0)
        }
        if reload {
            insertItems(at: [IndexPath(row: 0, section: 0)])
        }
    }
    
    func updateChangedPlace(_ p: FPlace, withReload reload: Bool){
        if list == nil || p.objectId == nil{
            return
        }
        for i in 0..<list!.count {
            let t = list![i]
            if t.objectId == p.objectId {
                list![i] = p
            }
        }
        for i in 0..<listFilter!.count {
            let t = listFilter![i]
            if t.objectId == p.objectId {
                listFilter![i] = p
                if reload {
                    reloadData([IndexPath(row: i, section: 0)])
                }
            }
        }
    }
    
    func setHeaderPosition(contentOffsetY y: CGFloat){
        if header != nil {
            header?.frame = CGRect(x: 0, y: y, width: AppSetting.App.screenSize.width, height: ExploreCollectionViewHeader.Height)
        }
    }
    
    // MARK: - Scroll action
    override func getContentOffset() -> CGPoint {
        return collection.contentOffset
    }
    
    override func setContentOffsetY(_ y: CGFloat, animated: Bool){
        collection.setContentOffset(CGPoint(x: collection.contentOffset.x, y: y), animated: animated)
    }
    
    override func isMainScroll(_ scrollView: UIScrollView) -> Bool{
        return true
    }
    
    override func disableScroll(_ isDisable: Bool){
        collection.isScrollEnabled = !isDisable
    }
}

// MARK: - CollectionviewDataSource
extension ExploreCollectionView : UICollectionViewDataSource {
    //2
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = (listFilter == nil ? 0 : listFilter!.count)
        if categoryType != .Tips {
            count += (AppState.checkVisaTabShow() ? 1 : 0)
        }
        return count
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if categoryType == FCategoryType.Tips {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TipCollectionCell.className, for: indexPath) as! TipCollectionCell
            let p = listFilter?[indexPath.row]
            cell.fill(place: p!, parentController: parentViewController, type: .Normal)
            return cell
        }
        // Else not TIP -> Put Visa cell on bottom
        if indexPath.row >= (listFilter?.count)! {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VisaCollectionViewCell.name, for: indexPath) as! VisaCollectionViewCell
            cell.onBookVisa = {[unowned self] in
                if let type = self.categoryType {
                    MeasurementHelper.openVisaCategory("\(type)")
                }
                Utils.openUrl(AppSetting.Visa.url)
            }
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceCollectionCell.className, for: indexPath) as! PlaceCollectionCell
        let p = listFilter?[indexPath.row]
        cell.makePlace(p!, categoryType: categoryType, parentController: parentViewController, isSmall: false)
        return cell
    }
    
    
}

// MARK: - UICollectionViewDelegate & UICollectionViewDelegateFlowLayout
extension ExploreCollectionView : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= 0 && delegateCollection != nil {
            delegateCollection?.exploreCollection(self, didSelectItemAt: indexPath)
        }
    }
    
    // UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if categoryType == FCategoryType.Tips {
            let p = listFilter?[indexPath.row]
            if p != nil {
                let text = p?.getTipContent() ?? ""
                let height = TipView.calculateHeightWithText(text, type: .Normal)
                return TipCollectionCell.sizeFull(withHeight: height)
            }
            return TipCollectionCell.sizeFull()
        }
        return PlaceCollectionCell.size()
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: paddingTopDefault + ExploreCollectionViewHeader.Height, left: 0, bottom: AppSetting.App.tabbarHeight, right: 0)
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if categoryType == FCategoryType.Tips {
            return 0
        }
        return 1
    }
}

// MAKR: - Override Scroll Function
extension ExploreCollectionView {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        // This func just for main scroll
        if !isMainScroll(scrollView){
            return
        }
        let y = max(0, paddingTopDefault - scrollView.contentOffset.y)
        setHeaderPosition(contentOffsetY: y)
    }
    
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        // This func just for main scroll
        if isMainScroll(scrollView){
            // collection get more data
            let bottomOffset = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height
            // This scrollView is a UITableView
            if bottomOffset > 60 && delegate != nil && delegateCollection != nil{
                // load more
                delegateCollection?.exploreCollectionDidLoadMore(self)
            }
        }
        else {
            super.scrollViewWillBeginDecelerating(scrollView)
        }
    }
}





