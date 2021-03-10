//
//  DiscoverViewController.swift
//  trid
//
//  Created by Black on 2/13/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit
import PureLayout
import SDWebImage
import GoogleMaps
import Toast_Swift
import SwiftyJSON

class DiscoverViewController: DashboardBaseViewController {
    
    let HomeObjectId = "homeObjectId"
    let size = AppSetting.App.screenSize
    let margin = AppSetting.Common.margin
    let mapHeightDefault : CGFloat = 85
    let duration : Double = 0.25
    let cityIntroBottomDefault : CGFloat = 20
    
    // view selected
    var viewSelected: PlaceMarkerSelectedView!
    // var selectedPlace: FPlace?
    
    // photo intro
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var constraintIntroHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintIntroTop: NSLayoutConstraint!
    
    // Header
    @IBOutlet weak var viewIntroCover: GradientLayer!
    @IBOutlet weak var labelCityName: UILabel!
    @IBOutlet weak var labelCityIntro: UILabel!
    @IBOutlet weak var constraintIntroCoverTop: NSLayoutConstraint!
    @IBOutlet weak var constraintCityIntroBottom: NSLayoutConstraint!
    
    @IBOutlet weak var viewIntroCoverSmall: UIView!
    @IBOutlet weak var labelCityNameSmall: UILabel!
    @IBOutlet weak var constraintCityNameSmallHeight: NSLayoutConstraint!
    
    // Temperature
    @IBOutlet weak var viewTemperature: UIView!
    @IBOutlet weak var iconTemp: UIImageView!
    @IBOutlet weak var labelTemperature: UILabel!
    @IBOutlet weak var btnTemperature: UIButton!
    
    // Segmentio
    @IBOutlet weak var segmentio: Segmentio!
    
    // Map
    @IBOutlet weak var gmap: GMSMapView!
    @IBOutlet weak var constraintMapHeight: NSLayoutConstraint!
    @IBOutlet weak var btnBackToList: UIButton!
    @IBOutlet weak var btnExpandMap: UIButton!
    @IBOutlet weak var constraintButtonBackToListBottom: NSLayoutConstraint!
    
    // Category
    @IBOutlet weak var scrollBody: UIScrollView!
    @IBOutlet weak var viewBody: UIView!
    @IBOutlet weak var constraintBodyWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintBodyTop: NSLayoutConstraint!
    
    // Overlay -> Display overlay to make sure disable all user interaction when animation play
    @IBOutlet weak var viewOverlay: UIView!
    
    // - Variables
    var city : FCity!
    var setSegmentio = false
    var lastScrollOffset : CGFloat = 0
    var paddingTopDefault : CGFloat = 0
    var introHeightDefault : CGFloat = 0
    var introHeightMin : CGFloat = 0
    var isMoving = false
    var isMovingUp = false
    var seperatorOffsetDefault : CGFloat = 0
    var isMapExpanded = false
    var paddingTopMin : CGFloat = 0
    var displayCategories : [FCategory] = [FCategory]()
    var appearing : Bool = false
    
    // - Data
    var collections : [String: Any] = [:] // ExploreCollectionView | ExploreHomeView
    
    // - Map manager
    fileprivate var clusterManager: GMUClusterManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        city = AppState.shared.currentCity!
        image.sd_setImage(with: URL(string: city.getPhotoUrl()), placeholderImage: UIImage(named: "img-default"))
        labelCityName.text = city.getName()
        labelCityIntro.text = city[FCity.intro] as? String
        labelCityNameSmall.text = city.getName()
        constraintCityNameSmallHeight.constant = header.bounds.height - 20
        constraintButtonBackToListBottom.constant = AppSetting.App.tabbarHeight
        
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = MyClusterRenderer(mapView: gmap, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: gmap, algorithm: algorithm, renderer: renderer)
        clusterManager.setDelegate(self, mapDelegate: self)
        
        // Setup selected marker
        setupViewSelectedMarker()
        
        // Display category
        getCityDisplayCategories()
        
        // header
        header.makeHeaderHomeGuide()
        
        // Google Map
        constraintMapHeight.constant = mapHeightDefault
        applyMapCenter()
        applyMapStyle()
        
        // Position
        introHeightDefault = (size.width + margin) * 0.6
        introHeightMin = size.width * 0.6
        paddingTopDefault = introHeightDefault + constraintMapHeight.constant - AppSetting.App.headerHeight
        seperatorOffsetDefault = paddingTopDefault / 4.0
        constraintBodyTop.constant = AppSetting.App.headerHeight + segmentio.frame.height
        paddingTopMin = paddingTopDefault - mapHeightDefault
        moveToCenterPosition(animated: false, mapAnimate: false)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Get city temperature
        loadCityForecast()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setOverlay(show: false)
        appearing = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appearing = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !setSegmentio {
            // Loading
            AppLoading.showLoading()
            AppLoading.showSuccess()
            
            setSegmentio = true
            // Body | Setup Body trước để change call update data trong header setup
            setupBody()
            // Header
            setupSegmentHeader()
            // Register notification to update place
            NotificationCenter.default.addObserver(self, selector: #selector(DiscoverViewController.placeServiceAdded), name: Notification.Name(PlaceServiceKey.added), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(DiscoverViewController.placeServiceChanged), name: Notification.Name(PlaceServiceKey.changed), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(DiscoverViewController.placeServiceRemoved), name: Notification.Name(PlaceServiceKey.removed), object: nil)
        }
        else{
            for c in collections {
                if c.value is ExploreCollectionView {
                    let view = c.value as! ExploreCollectionView
                    if view.needUpdate {
                        view.reloadData()
                        view.needUpdate = false
                    }
                }
                else if c.value is ExploreHomeView {
                    let view = c.value as! ExploreHomeView
                    if view.needUpdate {
                        view.reloadData()
                        view.needUpdate = false
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func headerBarGoBackImpl() {
        self.tabBarController?.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup UI
    func setupViewSelectedMarker(){
        // ADD place marker selected view
        viewSelected = Bundle.main.loadNibNamed(PlaceMarkerSelectedView.className, owner: self, options: nil)?[0] as? PlaceMarkerSelectedView
        self.view.addSubview(viewSelected!)
        viewSelected?.autoPinEdge(toSuperviewEdge: ALEdge.leading)
        viewSelected?.autoPinEdge(toSuperviewEdge: ALEdge.trailing)
        viewSelected?.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: 64)
        viewSelected?.autoSetDimension(ALDimension.height, toSize: 70)
        viewSelected?.isHidden = true
        viewSelected?.clipsToBounds = true
        viewSelected?.delegate = self
    }
    
    // Display category
    func getCityDisplayCategories(){
        displayCategories.removeAll()
        for cat in CityCategoryService.shared.categoriesOfCurrentCity {
            if cat.getName() != "", let type = cat.getType(), FCategory.DisplayTypes.contains(type) {
                displayCategories.append(cat)
            }
        }
        displayCategories = displayCategories.sorted(by: {$0.getPriority() > $1.getPriority()})
    }
    
    // Setup Segment Categories
    fileprivate func setupSegmentHeader(){
        // Make segment categories of this city
        var segments = [SegmentioItem]()
        let home = SegmentioItem(title: Localized.Home, image: UIImage(named: ""))
        segments.append(home)
        for cat in displayCategories {
            if let catType = cat.getType(), catType != .Tips {
                let n = cat.getName().uppercased()
                let s = SegmentioItem(title: n, image: UIImage(named: ""))
                segments.append(s)
            }
        }
        let option = segmentio.segmentioOptions(background: UIColor(netHex: AppSetting.Color.blue),
                                                maxVisibleItems: 4,
                                                font: UIFont(name: AppSetting.Font.roboto_medium, size: AppSetting.FontSize.normal)!,
                                                textColor: UIColor(netHex: 0xc3e3fa),
                                                textColorSelected: UIColor.white,
                                                verticalColor: UIColor.clear,
                                                horizontalColor: UIColor.clear,
                                                isFlexibleWidth: true)
        segmentio.setup(
            content: segments,
            style: SegmentioStyle.onlyLabel,
            options: option
        )
        segmentio.valueDidChange = { [weak self] _, segmentIndex in
            // scroll change page
            let offset = self?.scrollBody.contentOffset
            let x = CGFloat(segmentIndex) * AppSetting.App.screenSize.width
            self?.scrollBody.contentOffset = CGPoint(x: x, y: (offset?.y)!)
            // Update content
            self?.setCurrentCategoryForSegmentIndex(segmentIndex)
        }
        // Default tab = 0
        segmentio.selectedSegmentioIndex = 0
    }
    
    func setCurrentCategoryForSegmentIndex(_ index: Int) {
        AppState.shared.currentCategory = displayCategories.count > 0 && index > 0 ? displayCategories[index - 1] : nil
        MeasurementHelper.openCategory(name: AppState.shared.currentCategory?.getName() ?? "NULL")
        let newItem = makeContentForCategory(AppState.shared.currentCategory, atIndex: index - 1)
        let catType = AppState.shared.currentCategory?.getType()
        // Move content
        if !isMapExpanded {
            // Hidden Map If Tip
            if AppState.shared.currentCategory != nil && catType == .Tips {
                gmap.isHidden = true
                btnExpandMap.isHidden = true
            }
            else{
                gmap.isHidden = false
                btnExpandMap.isHidden = false
            }
            // Move All To Top or Center
            if lastScrollOffset >= seperatorOffsetDefault { // IF: để xác định xem trạng thái hiện tại là TOP hay CENTER
                moveToTopPosition(exploreView: nil, offset: paddingTopDefault - mapHeightDefault, animated: false, mapAnimate: false, isInitial: newItem)
            }
            else{
                moveToCenterPosition(animated: false, mapAnimate: false)
            }
        }
        else if catType == .Tips {
            // Nếu đang expand map + move to Tip -> Collapse map + View Tip
            collapseMap(animate: false)
            // Hide map
            gmap.isHidden = true
            btnExpandMap.isHidden = true
        }
    }
    
    // Setup Categories Body
    fileprivate func setupBody(){
        // Make scroll body for categories of this city
        // Body width
        constraintBodyWidth.constant = AppSetting.App.screenSize.width * CGFloat(displayCategories.count + 1)
        // Make default tab
//         makeContentForCategory(nil, atIndex: -1)
//        for i in 0..<displayCategories.count {
//            _ = makeContentForCategory(displayCategories[i], atIndex: i)
//        }
    }
    
    
    /*
     Return: Nếu là Initial (init mới) -> lúc moveToTop cần có animated = true để collectionview có thể move top được
     */
    func makeContentForCategory(_ category: FCategory?, atIndex index: Int) -> Bool{
        let objectId = category != nil ? category!.objectId! : HomeObjectId
        // check
        if collections[objectId] != nil {
            // already created
            // Create map data
            createMapData(category: category)
            return false
        }
        // --------- UI ---------
        let width = AppSetting.App.screenSize.width
        var exploreView : Any
        if category != nil {
            // Tips thì ko show map
            let padding = category!.getType() == FCategoryType.Tips ? paddingTopDefault - mapHeightDefault : paddingTopDefault
            // Create collection
            exploreView = ExploreCollectionView.create(categoryKey: objectId, paddingTop: padding, inParentViewController: self)
            let exp = exploreView as! ExploreCollectionView
            exp.delegateCollection = self
            exp.onOpenFilter = {
                MeasurementHelper.openFilter()
                let filter = FilterPlaceViewController(nibName: "FilterPlaceViewController", bundle: nil)
                filter.allPlaces = exp.list
                filter.categoryType = exp.categoryType
                filter.subcategories = category!.getSubcategories() ?? []
                filter.filter = exp.currentFilter
                filter.onApplyFilter = {filter_, subs in
                    exp.applyFilter(filter_, subcategories: subs)
                    exp.setContentOffsetY(self.lastScrollOffset, animated: true)
                }
                filter.onDismiss = {
                    exp.setContentOffsetY(self.lastScrollOffset, animated: false)
                }
                self.present(filter, animated: true, completion: nil)
            }
        }
        else{
            // Create Home
            
            exploreView = ExploreHomeView.create(objectId: objectId, paddingTop: paddingTopDefault, inParentViewController: self)
            (exploreView as! ExploreHomeView).delegateHome = self
        }
        let explore = exploreView as! ExploreBaseView
        explore.delegate = self
        viewBody.addSubview(explore)
        explore.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: width * CGFloat(index + 1))
        explore.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: 0)
        explore.autoPinEdge(toSuperviewEdge: ALEdge.bottom, withInset: 0)
        explore.autoSetDimension(ALDimension.width, toSize: width)
        
        // Saved
        collections[objectId] = explore
        
        // load content
        loadContentForTabKey(objectId, finish: nil)
        
        // Create map data
        createMapData(category: category)
        
        return true
    }
    
    // Show|Hide view weather
    func makeViewWeather(show: Bool, weather: WeatherToday? = nil) {
        viewTemperature.isHidden = !show || weather == nil
        if viewTemperature.isHidden == false {
            labelTemperature.text = weather!.tempC
            iconTemp.image = UIImage(named: weather!.icon)
        }
    }
    
    
    // MARK: - LOAD CONTENT
    func loadCityForecast() {
        let forecastApi = city.getWeatherForecastApi()
        let todayApi = city.getWeatherConditionsApi()
        if todayApi == nil {
            // Hide
            return
        }
        // Create weather object
        let weather = city.weather ?? FWeather(path: FWeather.path, objectId: city.objectId)
        weather.fetchInBackground(finish: {err in
            var expired : Bool = (err != nil)
            var expiredForecast : Bool = (err != nil)
            if err == nil {
                let updated = weather.getUpdatedTime()
                // check data
                if weather.forecast == nil {
                    expiredForecast = true
                }
                if weather.today == nil {
                    expired = true
                }
                // Check time
                if updated == nil {
                    expired = true
                    expiredForecast = true
                }
                else {
                    let now = Date()
                    expired = now.timeIntervalSince(updated!) > 3 * 60 * 60 /* 1h = 3600s */
                    expiredForecast = NSCalendar.current.compare(now, to: updated!, toGranularity: .day) != .orderedSame
                }
            }
            let total = NSNumber(value: expiredForecast).intValue + NSNumber(value: expired).intValue
            var current = 0
            // finish
            let completed : (() -> Void) = {
                if current == total {
                    weather.saveInBackground()
                    self.city.weather = weather
                }
            }
            // get forecast
            if expiredForecast {
                Le2Network.get(forecastApi!, finish: {json in
                    current += 1
                    weather.setForecastJson(json)
                    completed()
                })
            }
            else{
                weather.setForecastJson(weather.getForecastJson())
            }
            // check expired & get online if need
            if expired {
                Le2Network.get(todayApi!, finish: {json in
                    current += 1
                    if json != JSON.null {
                        weather.setTodayJson(json)
                        // display
                        self.makeViewWeather(show: true, weather: weather.today)
                    }
                    else {
                        // Hide
                        self.makeViewWeather(show: false, weather: nil)
                    }
                    completed()
                })
            }
            else {
                weather.setTodayJson(weather.getTodayJson())
                // Display
                self.makeViewWeather(show: true, weather: weather.today)
            }
            if total == 0 {
                self.city.weather = weather
            }
        })
    }
    
    func loadContentForTabKey(_ tabKey: String, finish: (() -> Void)?){
        let collection = collections[tabKey]
        if collection == nil {
            return
        }
        if tabKey != HomeObjectId {
            let exploreCollection = collection as! ExploreCollectionView
            var catPlaces = PlaceService.placesForCategoryKey(tabKey)
            if exploreCollection.categoryType == .Tips {
                // sort by time
                catPlaces = catPlaces.sorted(by: {$0.getDateTime() > $1.getDateTime()})
            }
            exploreCollection.list = catPlaces
            exploreCollection.listFilter = catPlaces
            exploreCollection.reloadData()
        }
        else if collection is ExploreHomeView {
            // Get HOME DATA
            var list = CityCategoryService.shared.cityCategories
            list = list.sorted(by: {$0.getOrder() > $1.getOrder()})
            var types : [FCategoryType] = []
            var categories : [FCategoryType : FCategory] = [:]
            var data : [FCategoryType : [FPlace]] = [:]
            for i in 0 ..< list.count {
                let a = list[i]
                if let cat = displayCategories.first(where: {$0.objectId == a.getCategoryKey()}) {
                    if let t = cat.getType() {
                        types.append(t)
                        categories[t] = cat
                        var places = PlaceService.placesForCategoryKey(cat.objectId!)
                        if t == .Tips {
                            places = places.sorted(by: {$0.getDateTime() > $1.getDateTime()})
                        }
                        data[t] = places
                        if types.count >= 2 {
                            break
                        }
                    }
                }
            }
            let home = collection as! ExploreHomeView
            home.setupData(types: types, cats: categories, places: data)
            // Reload
            home.reloadData()
        }
    }
    
    // MARK: - ACTION
    @IBAction func actionBackToList(_ sender: Any) {
        MeasurementHelper.collapsedMap()
        // Collapsed map
        collapseMap(animate: true)
    }
    
    @IBAction func actionExpandMap(_ sender: Any) {
        MeasurementHelper.expandMap()
        // expand map
        expandMap(animate: true)
    }
    
    func setOverlay(show: Bool) {
        // viewOverlay.isHidden = !show
        viewOverlay.isHidden = true
        segmentio.isUserInteractionEnabled = !show
        scrollBody.isScrollEnabled = !show
    }
    
    @IBAction func actionGotoFullForecast(_ sender: Any) {
        if city.weather?.forecast?.count == 0 {
            return
        }
        MeasurementHelper.openWeather(city: city.getName())
        // Go to forecast screen
        let vc = WeatherViewController(nibName: "WeatherViewController", bundle: nil)
        vc.city = self.city
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - Scroll Delegate
extension DiscoverViewController : UIScrollViewDelegate {
    // Begin drag
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    // did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    // Using for body change page
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Body only scroll horizontal -> Change page
        if (scrollView == self.scrollBody){
            // ScrollBody Change Page
            let pageWidth = AppSetting.App.screenSize.width
            let currentPage : Int = min(segmentio.segmentioItems.count - 1, max(0, Int(ceil(scrollBody.contentOffset.x / pageWidth))))
            segmentio.selectedSegmentioIndex = currentPage
        }
    }
}

// MARK: - BCollection Delegate
extension DiscoverViewController : ExploreBaseViewDelegate {
    
    func collectionWillBeginDragging(_ exploreView: Any, offset: CGFloat) {
        lastScrollOffset = offset
        isMoving = true
    }
    
    // Kéo xuống dưới -> offset < 0
    // Kéo lên trên -> offset > 0
    func collection(_ exploreView: Any, didScroll offset: CGFloat) {
        if isMoving {
            isMovingUp = offset > 0
            moveToPosition(lastScrollOffset + offset, animated: false, mapAnimate: false)
        }
    }
    
    func collection(_ exploreView: Any, scrollViewWillBeginDecelerating scrollView: UIScrollView) {
        //
    }
    
    func collectionDidEndDrag(_ exploreView: Any, willDecelerate decelerate: Bool) {
        if decelerate {
            setOverlay(show: true)
        }
        else{
            collectionDidEndMoving(exploreView)
        }
    }
    
    func collectionDidEndMoving(_ exploreView: Any) {
        setOverlay(show: false)
        isMoving = false
        // 
        // Nếu dừng lại ở lưng chừng -> move to TOP | CENTER
        if lastScrollOffset > 0 && lastScrollOffset < paddingTopDefault {
            if lastScrollOffset < seperatorOffsetDefault {
                moveToCenterPosition(animated: true, mapAnimate: true)
            }
            else {
                moveToTopPosition(exploreView: exploreView, offset: lastScrollOffset, animated: true, mapAnimate: true)
            }
        }
    }
}

// MARK: - Calculate animation when scroll
extension DiscoverViewController {
    func moveToTopPosition(exploreView: Any?, offset: CGFloat, animated: Bool, mapAnimate: Bool, isInitial: Bool = false){
        moveToPosition(offset, animated: animated, mapAnimate: mapAnimate, isTop: true)
        // collection offset
        let expBase = exploreView as? ExploreBaseView
        for obj in collections {
            // Move to top
            let exc = obj.value as! ExploreBaseView
            // Tất cả các view đều phải move về top, trừ view hiện tại <expBase>
            if expBase == nil || (expBase != nil && exc.exploreKey != expBase?.exploreKey)
                || (expBase != nil && exc.exploreKey == expBase?.exploreKey && offset < paddingTopMin)
            {
                if animated && !isInitial{
                    self.setOverlay(show: true)
                    // Stop current animating
                    exc.layer.removeAllAnimations()
                    // Start new animation
                    UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                        exc.setContentOffsetY(self.paddingTopMin, animated: false)
                    }, completion: {f in
                        self.setOverlay(show: false)
                    })
                }
                else{
                    exc.setContentOffsetY(paddingTopMin, animated: isInitial)
                }
            }
        }
    }
    
    func moveToPosition(_ offset_: CGFloat, animated: Bool, mapAnimate: Bool, isTop: Bool = false){
        // calculate
        var offset = offset_
        if isTop && offset < paddingTopDefault - mapHeightDefault {
            offset = paddingTopDefault - mapHeightDefault
        }
        
        let alpha = offset / (paddingTopDefault - mapHeightDefault)
        
        // Intro Height
        let introHeight = max(introHeightDefault - offset, introHeightMin)
        // Intro Move up không lớn hơn 0, và không nhỏ hơn header.height
        let moveUp = max(min(introHeightDefault - offset - introHeightMin, 0), header.bounds.height - introHeightMin)
        // Map Height
        let mapHeight = max(min(mapHeightDefault, paddingTopDefault - offset), 0)
        // City Intro Bottom
        let cityIntroBottom = cityIntroBottomDefault + max(offset, 0)
        if !animated {
            // Height
            constraintIntroHeight.constant = introHeight
            // Top
            constraintIntroTop.constant = moveUp
            constraintIntroCoverTop.constant = moveUp
            // Map
            constraintMapHeight.constant = mapHeight
            // Cover small color & alpha
            viewIntroCoverSmall.alpha = alpha
            viewIntroCoverSmall.backgroundColor = UIColor(netHex: AppSetting.Color.blue).withAlphaComponent(alpha)
            // Label City Intro Bottom
            constraintCityIntroBottom.constant = cityIntroBottom
        }
        else{
            if !mapAnimate {
                // Map
                self.constraintMapHeight.constant = mapHeight
            }
            setOverlay(show: true)
            // Stop current animation
            self.view.layer.removeAllAnimations()
            
            // Trong trường hợp animation -> move tất cả các collection về vị trí cần đến
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                // Height
                self.constraintIntroHeight.constant = introHeight
                self.constraintIntroTop.constant = moveUp
                // Top
                self.constraintIntroCoverTop.constant = moveUp
                // Map
                if mapAnimate {
                    self.constraintMapHeight.constant = mapHeight
                }
                // Cover small color & alpha
                self.viewIntroCoverSmall.alpha = alpha
                self.viewIntroCoverSmall.backgroundColor = UIColor(netHex: AppSetting.Color.blue).withAlphaComponent(alpha)
                // Label City Intro Bottom
                self.constraintCityIntroBottom.constant = cityIntroBottom
                // Update layout
                self.view.layoutIfNeeded()
            }, completion: {f in
                self.setOverlay(show: false)
            })
        }
        lastScrollOffset = offset
    }
    
    func moveToCenterPosition(animated: Bool, mapAnimate: Bool){
        moveToPosition(0, animated: animated, mapAnimate: mapAnimate)
        // collection offset
        for obj in collections {
            let exc = obj.value as! ExploreBaseView
            // Tất cả các view đều move về center
            if exc.getContentOffset().y != 0 {
                if animated {
                    self.setOverlay(show: true)
                    // Stop current animating
                    exc.layer.removeAllAnimations()
                    // Start
                    UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                        exc.setContentOffsetY(0, animated: animated)
                    }, completion: {f in
                        self.setOverlay(show: false)
                    })
                }
                else{
                    exc.setContentOffsetY(0, animated: animated)
                }
            }
        }
    }
}

// MARK: - ==========> GoogleMap <===========
extension DiscoverViewController : GMSMapViewDelegate {
    
    // Map View Action
    func expandMap(animate: Bool) {
        let fullMapHeight = size.height - header.bounds.height - segmentio.bounds.height - tabbar.bounds.height - btnBackToList.bounds.height
        if constraintMapHeight.constant <= mapHeightDefault && !isMapExpanded{
            moveToTopPosition(exploreView: nil, offset: 0, animated: true, mapAnimate: false)
            isMapExpanded = true
            if animate {
                btnExpandMap.isEnabled = false
                btnBackToList.isEnabled = false
                btnBackToList.isHidden = false
                btnBackToList.alpha = 0.5
                setOverlay(show: true)
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                    self.btnBackToList.alpha = 1
                    self.constraintMapHeight.constant = fullMapHeight
                    self.view.layoutIfNeeded()
                }, completion: {finish in
                    self.btnBackToList.isHidden = false
                    self.btnBackToList.isEnabled = true
                    self.btnExpandMap.isHidden = true
                    self.btnExpandMap.isEnabled = true
                    self.setOverlay(show: false)
                    // Show My location button
                    self.gmap.settings.myLocationButton = true
                })
            }
            else{
                constraintMapHeight.constant = fullMapHeight
                btnBackToList.isHidden = false
                btnExpandMap.isHidden = true
                // Show My location button
                self.gmap.settings.myLocationButton = true
            }
        }
    }
    
    func collapseMap(animate: Bool){
        // Hide selected view
        hideSelectedPlaceView()
        // Action
        if constraintMapHeight.constant > mapHeightDefault && isMapExpanded {
            // Show My location button
            self.gmap.settings.myLocationButton = false
            isMapExpanded = false
            if animate {
                btnExpandMap.isEnabled = false
                btnBackToList.isEnabled = false
                btnBackToList.alpha = 1
                setOverlay(show: true)
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                    self.btnBackToList.alpha = 0
                    self.constraintMapHeight.constant = self.mapHeightDefault
                    self.view.layoutIfNeeded()
                }, completion: {finish in
                    self.btnBackToList.isHidden = true
                    self.btnBackToList.isEnabled = true
                    self.btnExpandMap.isHidden = false
                    self.btnExpandMap.isEnabled = true
                    self.setOverlay(show: false)
                })
            }
            else{
                constraintMapHeight.constant = mapHeightDefault
                btnBackToList.isHidden = true
                btnExpandMap.isHidden = false
            }
        }
    }
    
    // Create data
    func createMapData(category: FCategory?) {
        // Get current category
        var places = [FPlace]()
        if category == nil {
            places = PlaceService.shared.places 
        }
        else{
            for collection in collections {
                if collection.key == HomeObjectId {
                    continue
                }
                else if category != nil && category?.objectId == collection.key {
                    places.append(contentsOf: (collection.value as! ExploreCollectionView).list ?? [])
                    break
                }
                
            }
        }
        // Map data
        gmap.clear()
        clusterManager.clearItems()
        var dict = [String: Bool]()
        for i in 0..<places.count {
            let p = places[i]
            var categoryType : FCategoryType? = nil
            let cats = p.getCategories()
            for cat in cats {
                let catType = CategoryService.shared.getCategoryType(fromKey: cat)
                if catType != nil && FCategory.DisplayTypes.contains(catType!){
                    categoryType = catType
                }
            }
            if categoryType == nil {
                continue
            }
            let coor = p.getCoordinate()
            let art = GooglePlace.fromPlace(p, categoryType: categoryType)
            if art != nil && categoryType != nil && (dict[coor] == nil){
                // googlePlaces.append(art!)
//                let marker = PlaceMarker(googlePlace: art!, index: i+1, categoryType: categoryType!)
//                marker.map = self.gmap
                let item = PlaceItem(position: art!.coordinate, place: art!)
                clusterManager.add(item)
                dict[coor] = true
            }
        }
        clusterManager.cluster()
    }
    
    // Init UI
    func applyMapCenter(){
        // isCenteringMap = true
        gmap.isMyLocationEnabled = true
        
        // City location
        if AppState.shared.currentCity != nil {
            gmap.setCameraFor(city: AppState.shared.currentCity!)
        }
    }
    
    func applyMapStyle() {
        // Apply map style
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
                gmap.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
        }
        gmap.delegate = self
    }
    
    // Map Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (gesture) {
            mapView.selectedMarker = nil
            // hide selected view
            hideSelectedPlaceView()
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let iconview = marker.iconView
        if iconview != nil{
            let tr1 = (iconview?.transform)!
            let tr2 = (iconview?.transform)!.scaledBy(x: 1.2, y: 1.2)
            UIView.animate(withDuration: 0.1, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {()-> Void in
                iconview?.transform = tr2
            }, completion: {(finish: Bool) -> Void in
                UIView.animate(withDuration: 0.1, animations: {() -> Void in
                    iconview?.transform = tr1
                })
            })
        }
        // show selected view
        showSelectedPlaceView(item: marker.userData as? PlaceItem)
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.selectedMarker = nil
        // hide selected view
        hideSelectedPlaceView()
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        debugPrint("didTap overlay")
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        debugPrint("didTapAt coordinate", coordinate)
        
    }
}

// MARK: - Explore HomeView Delegate
extension DiscoverViewController : ExploreHomeViewDelegate {
    // Delegate
//    func exploreHomeAddTip() {
//        // Check if not loged in -> Go to login page ELSE Perform action
//        Utils.viewController(self, isSignUp: false, checkLoginWithCallback: {
//            self.showPopupAddTip()
//        })
//    }
    
    func exploreHomeViewAll(categoryType: FCategoryType) {
        if categoryType == .Tips {
            self.setTabbarIndex(2)
            self.tabbar.selectedOnTab(index: self.tabbar.btnAskShare.tag)
        }
        else {
            // Other type
            for i in 0 ..< displayCategories.count {
                let cat = displayCategories[i]
                if cat.getType() == categoryType {
                    // Move segment to i
                    segmentio.selectedSegmentioIndex = i+1
                    return
                }
            }
        }
    }
    
    func exploreHome(_ explore: ExploreHomeView, didSelectedPlace p: FPlace, type: FCategoryType) {
        if p.isBanner() {
            Utils.openUrl(p.getWebsite())
            return
        }
        for cat in displayCategories {
            if cat.getType() == type {
                AppState.shared.currentCategory = cat
                break
            }
        }
        // Move to Tip Detail page
        if type == .Tips {
            let controller = CommentViewController(nibName: "CommentViewController", bundle: nil)
            controller.categoryType = type
            controller.place = p
            _ = self.navigationController?.pushViewController(controller, animated: true)
        }
        else{
            let detail = DetailViewController(nibName: "DetailViewController", bundle: nil)
            detail.place = p
            detail.categoryType = type
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func exploreHomeShowCityInfo() {
        MeasurementHelper.openCityInfo(city: city.getName())
        gotoDetailType(.CityInfo)
    }
    
    func exploreHomeShowEmergency() {
        MeasurementHelper.openCityEmergency(city: city.getName())
        gotoDetailType(.Emergency)
    }
    
    func exploreHomeShowTranspotation() {
        MeasurementHelper.openCityTransport(city: city.getName())
        gotoDetailType(.Transport)
    }
    
    // Extra functions
    private func gotoDetailType(_ type: FCategoryType){
        AppState.shared.currentCategory = AppState.getCategory(forType: type)
        // Just for CityInfo & Emergency
        if type != .Emergency && type != .CityInfo && type != .Transport {
            return
        }
        let key = CategoryService.shared.getCategoryKeyForType(type)
        let places_ = PlaceService.placesForCategoryKey(key!)
        if places_.count > 0 {
            let vc = DetailViewController(nibName: "DetailViewController", bundle: nil)
            vc.categoryType = type
            vc.place = places_[0]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            self.view.makeToast(Localized.ComingSoon)
        }
    }
}

// MARK: - Explore CollectionView Delegate
extension DiscoverViewController : ExploreCollectionViewDelegate {
    
    func exploreCollection(_ exploreView: ExploreCollectionView, didSelectItemAt indexPath: IndexPath) {
        if exploreView.listFilter != nil
            && exploreView.listFilter!.count > 0
            && indexPath.row < exploreView.listFilter!.count
            && indexPath.row >= 0 {
            guard let place = exploreView.listFilter?[indexPath.row] else { return }
            if place.isBanner() {
                // open to website
                Utils.openUrl(place.getWebsite())
                return
            }
            if AppState.shared.currentCategory != nil && AppState.shared.currentCategory?.getType() == FCategoryType.Tips {
                // Tip -> Move to comment page
                let controller = CommentViewController(nibName: "CommentViewController", bundle: nil)
                controller.categoryType = FCategoryType.Tips
                controller.place = place
                _ = self.navigationController?.pushViewController(controller, animated: true)
            }
            else{
                // Place -> Move to Detail Page
                let detail = DetailViewController(nibName: "DetailViewController", bundle: nil)
                detail.categoryType = exploreView.categoryType
                detail.place = place
                _ = self.navigationController?.pushViewController(detail, animated: true)
            }
        }
    }
    
    func exploreCollectionDidLoadMore(_ exploreView: ExploreCollectionView) {
        
    }
    
    func exploreCollectionDidFilter(_ exploreView: ExploreCollectionView, height: CGFloat) {
        // Check on top
        if lastScrollOffset < seperatorOffsetDefault {
            // Scroll at Center -> irnoge
            return
        }
        // Check collection height
        if height < size.height - AppSetting.App.headerHeight - segmentio.bounds.height - mapHeightDefault - AppSetting.App.tabbarHeight{
            moveToCenterPosition(animated: false, mapAnimate: false)
        }
    }
}

// MARK: - PLACE SERVICE DELEGATE | Firebase event
extension DiscoverViewController {
    // 1 Add
    @objc func placeServiceAdded(notification: Notification) {
        guard let p = notification.object as? FPlace, setSegmentio else { return }
        // Home
        if let home = collections[HomeObjectId] as? ExploreHomeView {
            home.insertTopPlace(p, withReload: appearing)
            home.needUpdate = !appearing
        }
        // Collection
        let pCategories = p.getCategories()
        for c in collections {
            if let col = c.value as? ExploreCollectionView, pCategories.contains(c.key) && c.key != HomeObjectId {
                col.insertTopPlace(p, withReload: appearing)
                col.needUpdate = !appearing
            }
        }
    }
    // 2 Changed
    @objc func placeServiceChanged(notification: Notification) {
        guard let p = notification.object as? FPlace, setSegmentio else { return }
        // Home
        if let home = collections[HomeObjectId] as? ExploreHomeView {
            home.updateChangedPlace(p, withReload: appearing)
            home.needUpdate = !appearing
        }
        // Collection
        let pCategories = p.getCategories()
        for c in collections {
            if let col = c.value as? ExploreCollectionView,  pCategories.contains(c.key) && c.key != HomeObjectId{
                col.updateChangedPlace(p, withReload: appearing)
                col.needUpdate = !appearing
            }
        }
    }
    
    // 3 Remove
    @objc func placeServiceRemoved(notification: Notification) {
        
    }
}

// MARK: - Selected Marker Delegate
extension DiscoverViewController {
    // MARK: - selected marker
    func showSelectedPlaceView(item: PlaceItem?) {
        if item == nil || item?.place == nil || viewSelected == nil {
            return
        }
        let gplace = item!.place
        viewSelected?.isHidden = false
        // selectedPlace = marker.place
        viewSelected?.makePlace(place: gplace!.currentPlace!, categoryType: gplace!.type)
        // animate
        viewSelected?.alpha = 0
        UIView.animate(withDuration: 0.15, animations: {() -> Void in
            self.viewSelected?.alpha = 1
        }, completion: {(finish: Bool) -> Void in
            
        })
    }
    
    func hideSelectedPlaceView(){
        if viewSelected == nil {
            return
        }
        // selectedPlace = nil
        viewSelected?.alpha = 1
        UIView.animate(withDuration: 0.15, animations: {() -> Void in
            self.viewSelected?.alpha = 0
        }, completion: {(finish: Bool) -> Void in
            self.viewSelected?.isHidden = true
            self.viewSelected?.makeEmpty()
        })
    }
}

extension DiscoverViewController : PlaceMarkerSelectedViewProtocol {
    func markerSelectedViewTouched(view: PlaceMarkerSelectedView) {
        let detail = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detail.categoryType = view.categoryType
        detail.place = view.place // selectedPlace
        self.navigationController?.pushViewController(detail, animated: true)
    }
}


extension DiscoverViewController : GMUClusterManagerDelegate {
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: gmap.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        gmap.moveCamera(update)
        return true
    }
}

extension DiscoverViewController : GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if marker.userData is PlaceItem {
            let pi = marker.userData as! PlaceItem
            marker.title = pi.place.name
            let icon = MarkerIconView.create(target: self)
            icon.make(type: pi.place.type, text: "")
            marker.iconView = icon// [self imageForItem:person];
            // Center the marker at the center of the image.
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        }
//        else if ([marker.userData conformsToProtocol:@protocol(GMUCluster)]) {
//            marker.icon = [self imageForCluster:marker.userData];
//        }
    }
}

