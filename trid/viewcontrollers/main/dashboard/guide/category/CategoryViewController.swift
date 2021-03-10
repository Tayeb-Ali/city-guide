//
//  CategoryViewController.swift
//  trid
//
//  Created by Black on 10/1/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import FirebaseDatabase
import GoogleMaps
import SDWebImage
import PureLayout
import IQKeyboardManagerSwift

fileprivate struct CategoryMode {
    static let Recommended = 0
    static let NearBy = 1
}

class CategoryViewController: DashboardBaseViewController {
    // outlet
    // map
    @IBOutlet weak var mapview: GMSMapView!
    @IBOutlet weak var constraintMappBottom: NSLayoutConstraint!
    
    // content
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var segmentio: Segmentio!
    @IBOutlet weak var tablePlace: UITableView!
    @IBOutlet weak var constraintScrollviewTop: NSLayoutConstraint!
    @IBOutlet weak var constraintTableHeight: NSLayoutConstraint!
    
    // show list
    @IBOutlet weak var btnShowList: UIButton!
    
    // let
    let cellIdentifier = "PlaceCell"
    let dragOffset = AppSetting.App.screenSize.height/6
    
    // variable
    var places : [FPlace]?
    var displayPlaces: [FPlace]?
    var placesNearBy : [FPlace]?
    var currentMode: Int = CategoryMode.Recommended
    var isLoadedSegment = false
    var isShowingFullMap = false
    var selectedPlace : FPlace? = nil
    // filter
    var filter : FilterPlace?
    var filterController : FilterPlaceViewController!
    
    // selected view
    var viewSelected: PlaceMarkerSelectedView?
    
    // MAP
    let regionRadius: CLLocationDistance = 5000
    var artworks = [Artwork]()
    var googlePlaces = [GooglePlace]()
    var markers = [PlaceMarker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Init data
        places = AppState.shared.placesForCurrentCategory
        filter = nil
        applyCurrentFilter(subs: nil)
        
        // table
        tablePlace.register(UINib(nibName: "PlaceCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        // header
        header.makeHeaderCategory(name: (AppState.shared.currentCategory?.getName())!)
        
        // register notification to update place
        NotificationCenter.default.addObserver(self, selector: #selector(CategoryViewController.placeServiceAdded), name: Notification.Name(PlaceServiceKey.added), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CategoryViewController.placeServiceChanged), name: Notification.Name(PlaceServiceKey.changed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CategoryViewController.placeServiceRemoved), name: Notification.Name(PlaceServiceKey.removed), object: nil)
        
        // Setup UI
        setupUI()
        
        // Map data
        createMapData()
        // Apply map style
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
                mapview.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("The style definition could not be loaded: \(error)")
        }
        mapview.delegate = self
        // City location
        if AppState.shared.currentCity != nil {
            mapview.setCameraFor(city: AppState.shared.currentCity!)
        }
        mapview.hiddenLegal()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isLoadedSegment{
            setupSegmentioView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK : - Override header action
    override func headerBarGoBackImpl() {
        if !isShowingFullMap{
            super.headerBarGoback()
            return
        }
        showFullList()
    }
    
    // MARK : - Setup UI
    fileprivate func setupSegmentioView() {
        let segments = [SegmentioItem(title: "Recommended", image: UIImage(named: "")),
                        SegmentioItem(title: "Near by", image: UIImage(named: ""))]
        let options = segmentio.segmentioOptions(maxVisibleItems: 2)
        print(segmentio)
        segmentio.setup(
            content: segments,
            style: SegmentioStyle.onlyLabel,
            options: options
        )
        segmentio.valueDidChange = { [weak self] _, segmentIndex in
            // Change tab - Recommend | Near by
            self?.currentMode = segmentIndex
            self?.setupUI()
            self?.tablePlace.reloadData()
            
        }
        segmentio.selectedSegmentioIndex = 0
    }
    
    fileprivate func setupUI(){
        // map constraint
        constraintMappBottom.constant = mapConstraintBottomNormal()

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
    
    func calculateTableHeight() {
        var count = 0
        switch currentMode {
        case CategoryMode.Recommended:
            count = (displayPlaces?.count)!
            break
        case CategoryMode.Recommended:
            count = (placesNearBy?.count)!
            break
        default:
            break
        }
        constraintTableHeight.constant = CGFloat(count) * self.tableView(tablePlace, heightForRowAt: IndexPath(row: 0, section: 0))
    }
    
    fileprivate func mapConstraintBottomNormal() -> CGFloat{
        let size = AppSetting.App.screenSize
        return size.height - 60 /* navigation bar */ - (size.width/(375/200)) /* map window */;
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Action
    @IBAction func actionShowFullMap(_ sender: AnyObject) {
        showFullMap()
    }
    
    @IBAction func actionShowList(_ sender: AnyObject) {
        showFullList()
    }
    
    override func headerBarFilterImpl() {
        if (self.navigationController != nil) {
            if filterController == nil {
                filterController = FilterPlaceViewController(nibName: "FilterPlaceViewController", bundle: nil)
                filterController.onApplyFilter = {filter_, subs in
                    self.filter = filter_
                    self.applyCurrentFilter(subs: subs)
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
            _ = self.navigationController?.pushViewController(filterController, animated: true)
        }
    }
    
}

extension CategoryViewController : UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table delegate & datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentMode {
        case CategoryMode.Recommended:
            return displayPlaces!.count
        case CategoryMode.NearBy:
            return placesNearBy != nil ? (placesNearBy?.count)! : 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PlaceCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PlaceCell;
        // parse data
        var place : FPlace? = nil
        if currentMode == CategoryMode.Recommended {
            place = displayPlaces![indexPath.row]
        }
        else if currentMode == CategoryMode.NearBy {
            place = placesNearBy![indexPath.row]
        }
        // init cell
        if place != nil {
            cell .makePlace(place!, categoryType: nil, parentController: self)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detail.place = displayPlaces?[indexPath.row]
        self.navigationController?.pushViewController(detail, animated: true)
    }
}

extension CategoryViewController : UIScrollViewDelegate {
    // MARK: - Scroll view delegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollview.contentOffset.y
        let mapBottom = mapConstraintBottomNormal()
        if y < 0 && !isShowingFullMap{
            constraintMappBottom.constant = mapBottom + y
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let y = scrollview.contentOffset.y
        if y < -dragOffset && !isShowingFullMap {
            // show full map
            showFullMap()
        }
    }
}

extension CategoryViewController {
    // MARK: - Expand & collapse map
    func showFullMap() {
        if isShowingFullMap {
            return
        }
        // disable selected
        viewSelected?.isHidden = true
        // showing
        isShowingFullMap = true
        // scroll variables
        scrollview.isScrollEnabled = false
        scrollview.bounces = false
        // button show list
        btnShowList.isHidden = false
        btnShowList.alpha = 0
        btnShowList.isEnabled = false
        let size = AppSetting.App.screenSize
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {() -> Void in
            // scroll view
            self.scrollview.setContentOffset(CGPoint(x: 0, y: -(size.height - 94 - (size.width/(375/200)))), animated: false)
            self.constraintScrollviewTop.constant = size.height - 94
            // Map
            self.constraintMappBottom.constant = 94
            // btn show list
            self.btnShowList.alpha = 1
            // layout
            self.view.layoutIfNeeded()
            }, completion: {(finish: Bool) -> Void in
                self.btnShowList.isEnabled = true
                self.scrollview.isHidden = true
        })
    }
    
    func showFullList() {
        if !isShowingFullMap {
            return
        }
        // disable selected
        viewSelected?.isHidden = true
        // !showing
        isShowingFullMap = false
        // btn show list
        btnShowList.isEnabled = false
        // scroll
        scrollview.isHidden = false
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {() -> Void in
            // scroll
            self.scrollview.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            self.constraintScrollviewTop.constant = 64
            // map
            self.constraintMappBottom.constant = self.mapConstraintBottomNormal()
            // btn show list
            self.btnShowList.alpha = 0
            // layout
            self.view.layoutIfNeeded()
            
            }, completion: {(finish: Bool) -> Void in
                // btn show list
                self.btnShowList.isEnabled = true
                self.btnShowList.isHidden = true
                self.btnShowList.alpha = 1
                // scroll
                self.scrollview.isScrollEnabled = true
                self.scrollview.bounces = true
                // full
                self.isShowingFullMap = false
        })
    }
}

extension CategoryViewController {
    // MARK: - Firebase event
    // Place protocol
    // 1 Add
    @objc func placeServiceAdded(notification: Notification) {
        let p = notification.object as! FPlace
        // check
        if !p.isInCurrentCategory() {
            return
        }
        // add
        places?.append(p)
        tablePlace.beginUpdates()
        let indexpath = IndexPath(row: (places?.count)!-1, section: 0)
        
        tablePlace.insertRows(at: [indexpath], with: .top)
        tablePlace.endUpdates()
    }
    // 2 Changed
    @objc func placeServiceChanged(notification: Notification) {
        let updatedPlace = notification.object as! FPlace
        // check
        if places == nil {
            return
        }
        let newDeactived = updatedPlace.isDeactived()
        // update
        var exist = false
        for i in (0 ..< (places?.count)!){
            let place = places?[i]
            if place?.snapshot?.key == updatedPlace.snapshot?.key {
                exist = true
                let indexpath = IndexPath(row: i, section: 0)
                let oldDeactived = (place?.isDeactived())!
                if !oldDeactived && newDeactived {
                    // deactive -> place đã bị deactived
                    places?.remove(at: i)
                    tablePlace.deleteRows(at: [indexpath], with: .fade)
                    break
                }
                else if !updatedPlace.isInCurrentCategory() {
                    // check category -> place đã bị chuyển qua category khác
                    places?.remove(at: i)
                    tablePlace.deleteRows(at: [indexpath], with: .fade)
                    break
                }
                else{
                    // Update place
                    places?[i] = updatedPlace
                    // reload cell
                    tablePlace.reloadRows(at: [indexpath], with: .top)
                    break
                }
            }
        }
        // active
        if !exist && updatedPlace.isInCurrentCategory() && !newDeactived {
            self.placeServiceAdded(notification: notification)
        }
    }
    
    // 3 Remove
    @objc func placeServiceRemoved(notification: Notification) {
        let p = notification.object as! FPlace
        // check
        if places == nil || (places?.count)! <= 0 {
            return
        }
        // check category
        if !p.isInCurrentCategory() {
            return
        }
        // remove
        for i in (0 ..< (places?.count)!){
            let place = places?[i]
            if place?.snapshot?.key == p.snapshot?.key {
                places?.remove(at: i)
                // reload cell
                let indexpath = IndexPath(row: i, section: 0)
                tablePlace.deleteRows(at: [indexpath], with: .fade)
                break
            }
        }
    }
}

// MARK: - Map data
extension CategoryViewController {
    func createMapData() {
        mapview.clear()
        for i in 0..<(places?.count)! {
            let p = places?[i]
            let currentCategoryType = AppState.getCurrentCategoryType()
            let art = GooglePlace.fromPlace(p!, categoryType: currentCategoryType)
            if art != nil && currentCategoryType != nil{
                googlePlaces.append(art!)
                let marker = PlaceMarker(googlePlace: art!, index: i+1, categoryType: currentCategoryType!)
                marker.map = self.mapview
                markers.append(marker)
            }
        }
    }
    
}

// MARK: - GMSMapViewDelegate
extension CategoryViewController: GMSMapViewDelegate {
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
        let placeMarker = marker as! PlaceMarker
        let iconview = placeMarker.iconView
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
        showSelectedPlaceView(index: placeMarker.index)
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.selectedMarker = nil
        // hide selected view
        hideSelectedPlaceView()
        return false
    }
    
}

extension CategoryViewController {
    // MARK: - selected marker
    func showSelectedPlaceView (index: Int) {
        if index > (places?.count)! {
            hideSelectedPlaceView()
            return
        }
        viewSelected?.isHidden = false
        selectedPlace = places?[index - 1]
        viewSelected?.makePlace(place: selectedPlace!, categoryType: nil)
        // animate
        viewSelected?.alpha = 0
        UIView.animate(withDuration: 0.15, animations: {() -> Void in
                self.viewSelected?.alpha = 1
            }, completion: {(finish: Bool) -> Void in
        
        })
    }
    
    func hideSelectedPlaceView(){
        selectedPlace = nil
        viewSelected?.alpha = 1
        UIView.animate(withDuration: 0.15, animations: {() -> Void in
                self.viewSelected?.alpha = 0
            }, completion: {(finish: Bool) -> Void in
                self.viewSelected?.isHidden = true
                self.viewSelected?.makeEmpty()
        })
    }
}

extension CategoryViewController : PlaceMarkerSelectedViewProtocol {
    func markerSelectedViewTouched(view: PlaceMarkerSelectedView) {
        let detail = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detail.place = selectedPlace
        self.navigationController?.pushViewController(detail, animated: true)
    }
}

// MARK: - Header function
extension CategoryViewController {
    
    func applyCurrentFilter(subs: [FSubcategory]?){
//        if filter == nil {
//            displayPlaces = places
//            tablePlace.reloadData()
//            // table view height
//            calculateTableHeight()
//            return
//        }
//        // else
//        let min = (filter?.minPrice)!
//        let max = (filter?.maxPrice)!
//        displayPlaces = places?.filter({p in
//            let pSubs = p.getSubCategories()
//            let checkSub = (subs?.filter({pSubs.contains($0.objectId!)}).count)! > 0
//            if checkSub {
//                let from = p.getFromPrice(categoryType: <#FCategoryType#>)
//                let to = p.getToPrice()
//                let checkPrice = from >= min && to <= max
//                return checkPrice
//            }
//            return false
//        })
//        tablePlace.reloadData()
//        // table view height
//        calculateTableHeight()
    }
}


