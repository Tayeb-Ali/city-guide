//
//  DetailViewController.swift
//  trid
//
//  Created by Black on 10/1/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import MessageUI

struct DetailValue {
    // PhotoShow
    static let PhotoShowHeight : CGFloat = 270.0
    // price
    static let heightPrice : CGFloat = 58.0
    // opening time
    static let heightOpeningTime : CGFloat = 81
    // free facility
    static let heightFreeFacility : CGFloat = 81.0
    // description
    static let descriptionLabelHeightMax : CGFloat = 75.0 // For 3 line
    static let descriptionLabelHeightMin : CGFloat = 25.0
    static let margin : CGFloat = 20.0
    // paid
    static let heightPaidItem : CGFloat = 36
    static let heightPaidItemBig : CGFloat = 46
    // contact
    static let contactItemHeight : CGFloat = 80
}

class DetailViewController: DashboardBaseViewController {
    
    // - Outlet
    // Photoshow
    @IBOutlet weak var viewPhotoShow: UIView!
    @IBOutlet weak var constraintPhotoShowHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintPhotoShowTop: NSLayoutConstraint!
    
    // Scrollview
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var photoSlideshow: ImageSlideshow!
    var slideshowTransitioningDelegate: ZoomAnimatedTransitioningDelegate?
    
    // -- Header
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var constraintHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintHeaderTop: NSLayoutConstraint!
    @IBOutlet weak var constraintLabelPriceHeight: NSLayoutConstraint!
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var constraintFavoriteWidth: NSLayoutConstraint!
    
    // - Opening time
    @IBOutlet weak var viewOpeningTime: UIView!
    @IBOutlet weak var constraintOpeningTimeHeight: NSLayoutConstraint!
    @IBOutlet weak var labelOpeningDay: UILabel!
    @IBOutlet weak var labelOpeningTime: UILabel!
    
    // - Free facilities
    @IBOutlet weak var viewFreeFacilities: UIView!
    @IBOutlet weak var collectionFreeFacility: UICollectionView!
    @IBOutlet weak var constraintFreeFacilityHeight: NSLayoutConstraint!
    var arrFreeFacilities : [FFacility]?
    fileprivate let facilityIdentifier = "FreeFacilityCell"
    fileprivate let facilityItemPerRow : CGFloat = 4.0
    
    // Tour Detail
    @IBOutlet weak var viewTourDetail: UIView!
    @IBOutlet weak var constraintTourDetailHeight: NSLayoutConstraint!
    @IBOutlet weak var labelTourLocationTitle: UILabel!
    @IBOutlet weak var labelTourLocation: UILabel!
    @IBOutlet weak var labelTourDurationTitle: UILabel!
    @IBOutlet weak var labelTourDuration: UILabel!
    @IBOutlet weak var labelTourLanguageTitle: UILabel!
    @IBOutlet weak var labelTourLanguage: UILabel!
    
    @IBOutlet weak var labelTourTranspotTitle: UILabel!
    @IBOutlet weak var labelTourTranspot: UILabel!
    
    @IBOutlet weak var labelTourGroupSizeTitle: UILabel!
    @IBOutlet weak var labelTourGroupSize: UILabel!
    
    
    // - Description
    @IBOutlet weak var labelDescriptionTitle: UILabel!
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var tvDescription: UITextView!
    //    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var btnReadmoreDescription: UIButton!
    @IBOutlet weak var btnReadmoreOverlay: UIButton!
    
    @IBOutlet weak var constraintDescriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintTVDescriptionBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintDescriptionTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintTVDescriptionTop: NSLayoutConstraint!
    
    // Booking
    @IBOutlet weak var viewBookTour: UIView!
    @IBOutlet weak var btnBookTour: UIButton!
    @IBOutlet weak var constraintViewBookTourHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewSleepBookingCom: UIView!
    @IBOutlet weak var btnSleepBookingCom: UIButton!
    @IBOutlet weak var constraintSleepBookingComHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewSleepBookingHostelworld: UIView!
    @IBOutlet weak var btnSleepBookingHostelworld: UIButton!
    @IBOutlet weak var constraintSleepHostelWorldHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewSleepBookingAirbnb: UIView!
    @IBOutlet weak var btnSleepBookingAirbnb: UIButton!
    @IBOutlet weak var constraintSleepBookingAirbnbHeight: NSLayoutConstraint!
    
    
    
    // - Check in/out
    @IBOutlet weak var viewCheckInOut: UIView!
    @IBOutlet weak var labelCheckinTitle: UILabel!
    @IBOutlet weak var labelCheckinValue: UILabel!
    @IBOutlet weak var labelCheckoutTitle: UILabel!
    @IBOutlet weak var labelCheckoutValue: UILabel!
    @IBOutlet weak var constraintCheckInOutHeight: NSLayoutConstraint!
    
    // - Paid facility
    @IBOutlet weak var viewPaidFacility: UIView!
    @IBOutlet weak var collectionPaidFacility: UICollectionView!
    @IBOutlet weak var btnReadmoreFacility: UIButton!
    @IBOutlet weak var constraintPaidHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintCollectionPaidBottom: NSLayoutConstraint!
    var arrPaidFacilities : [String]?
    fileprivate let paidIdentifier = "PaidFacilityCell"
    fileprivate let paidItemPerRow : Int = 2
    fileprivate let paidItemsMax : Int = 4
    
    // - Policy
    @IBOutlet weak var viewPolicy: UIView!
    @IBOutlet weak var labelPolicy: UILabel!
    @IBOutlet weak var btnReadmoreThings: UIButton!
    @IBOutlet weak var constraintThingsHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintLabelThingsBottom: NSLayoutConstraint!
    
    // - Map
    @IBOutlet weak var mapview: GMSMapView!
    @IBOutlet weak var constraintMapHeight: NSLayoutConstraint!
    @IBOutlet weak var imgSeperatorMap: UIImageView!
    
    // - Contact
    @IBOutlet weak var viewContact: UIView!
    
    @IBOutlet weak var labelContactAddressTitle: UILabel!
    @IBOutlet weak var labelContactPhoneTitle: UILabel!
    @IBOutlet weak var labelContactMailTitle: UILabel!
    @IBOutlet weak var labelContactWebTitle: UILabel!
    @IBOutlet weak var labelContactFacebookTitle: UILabel!
    
    @IBOutlet weak var labelContactAddress: UILabel!
    @IBOutlet weak var labelContactPhone: UILabel!
    @IBOutlet weak var labelContactMail: UILabel!
    @IBOutlet weak var labelContactWeb: UILabel!
    @IBOutlet weak var labelContactFacebook: UILabel!
    
    @IBOutlet weak var btnContactAddress: UIButton!
    @IBOutlet weak var btnContactPhone: UIButton!
    @IBOutlet weak var btnContactSendMail: UIButton!
    @IBOutlet weak var btnContactVisitWeb: UIButton!
    @IBOutlet weak var btnContactViewFacebook: UIButton!
    
    @IBOutlet weak var constraintContactHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintContactAddressHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintContactPhoneHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintContactMailHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintContactWebHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintContactFacebookHeight: NSLayoutConstraint!
    
    // near by
    @IBOutlet weak var viewNear: UIView!
    @IBOutlet weak var tableNear: UITableView!
    @IBOutlet weak var constraintNearHeight: NSLayoutConstraint!
    
    // Review
    @IBOutlet weak var viewReview: UIView!
    @IBOutlet weak var btnLove: CountButton!
    @IBOutlet weak var btnReview: CountButton!
    //@IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnWriteComment: UIButton!
    @IBOutlet weak var constraintLovedWith: NSLayoutConstraint!
    
    // variable
    var place : FPlace?
    var categoryType : FCategoryType?

    override func viewDidLoad() {
        super.viewDidLoad()
        // - Header
        header.makeHeaderDetail(title: place?.getName() ?? "")
        
        // Favorited
        if categoryType == nil || !FCategory.DisplayTypes.contains(categoryType!) {
            btnFavorite.isHidden = true
        }
        else{
            btnFavorite.isHidden = false
            self.view.bringSubviewToFront(btnFavorite)
            constraintFavoriteWidth.constant = AppSetting.App.headerHeight - 20
            if place != nil {
                btnFavorite.isSelected = AppState.checkFavorited(ofPlace: place!)
            }
        }
        
        // - Hide tabbar
        tabbar.isHidden = true
        
        // - Register table cell
        // facility
        collectionFreeFacility.register(UINib(nibName: "FreeFacilityCell", bundle: nil), forCellWithReuseIdentifier: facilityIdentifier)
        // paid
        collectionPaidFacility.register(UINib(nibName: "PaidFacilityCell", bundle: nil), forCellWithReuseIdentifier: paidIdentifier)
        
        // - Map style
        makeMapStyle()
        
        // Custom UI
        customUI()
        
        // - Fill title localization
        fillLocalized()
        
        // - Fill data
        fillData()
        
        // - Calculate ui layout
        calculateSubViewLayout()
        
        // - Load comment
        loadComment()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Register Notification
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(placeServiceChanged), name: Notification.Name(PlaceServiceKey.changed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(placeServiceRemoved), name: Notification.Name(PlaceServiceKey.removed), object: nil)
        if place != nil && place!.objectId != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteAdded), name: NotificationKey.favoriteAdded(place!.objectId!), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteDeleted), name: NotificationKey.favoriteDeleted(place!.objectId!), object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func makeMapStyle() {
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
        // Region
        if AppState.shared.currentCity != nil {
            mapview.setCameraFor(place: place!, city: AppState.shared.currentCity!)
        }
        mapview.hiddenLegal()
        // Seperator: Mặc định là off, Hidden map thì mới on
        imgSeperatorMap.isHidden = true
    }
    
    func customUI() {
        // Description
        tvDescription.contentInset = UIEdgeInsets.init(top: 0, left: -4, bottom: 0, right: -4)
        tvDescription.textContainer.maximumNumberOfLines = 0
        tvDescription.textContainer.lineBreakMode = .byTruncatingTail
        
        // Booking
        btnBookTour.layer.cornerRadius = btnBookTour.bounds.height/2
        btnBookTour.clipsToBounds = true
        
        btnSleepBookingCom.layer.cornerRadius = btnSleepBookingCom.bounds.height/2
        btnSleepBookingCom.clipsToBounds = true
        
        btnSleepBookingHostelworld.layer.cornerRadius = btnSleepBookingHostelworld.bounds.height/2
        btnSleepBookingHostelworld.clipsToBounds = true
        
        btnSleepBookingAirbnb.layer.cornerRadius = btnSleepBookingAirbnb.bounds.height/2
        btnSleepBookingAirbnb.clipsToBounds = true
    }
    
    func fillLocalized() {
        // Description
        btnReadmoreDescription.setTitle(Localized.Readmore, for: .normal)
        
        // Check in/out
        labelCheckinTitle.text = Localized.checkin
        labelCheckoutTitle.text = Localized.checkout
        
        // Paid facility
        btnReadmoreFacility.setTitle(Localized.viewAll, for: .normal)
        
        // Things
        btnReadmoreThings.setTitle(Localized.viewAll, for: .normal)
        
        // Contact
        labelContactAddressTitle.text = Localized.Address
        btnContactAddress.setTitle(Localized.Direction, for: .normal)
        labelContactPhoneTitle.text = Localized.Phone
        btnContactPhone.setTitle(Localized.Call, for: .normal)
        labelContactMailTitle.text = Localized.Mail
        btnContactSendMail.setTitle(Localized.Send, for: .normal)
        labelContactWebTitle.text = Localized.Web
        btnContactVisitWeb.setTitle(Localized.Visit, for: .normal)
        labelContactFacebookTitle.text = Localized.Facebook
        btnContactViewFacebook.setTitle(Localized.View, for: .normal)
        
        // Tour
        labelTourLocationTitle.text = Localized.Location
        labelTourDurationTitle.text = Localized.Duration
        labelTourLanguageTitle.text = Localized.Languages
        labelTourTranspotTitle.text = Localized.Transpotation
        labelTourGroupSizeTitle.text = Localized.GroupSize
        
        // Booking Sleep
        btnBookTour.setTitle(Localized.BookNow, for: .normal)
        btnSleepBookingCom.setTitle(Localized.CheckAvailability, for: .normal)
        btnSleepBookingHostelworld.setTitle(Localized.CheckAvailability, for: .normal)
        btnSleepBookingAirbnb.setTitle(Localized.CheckAvailability, for: .normal)
    }
    
    func loadComment(){
        if place == nil {
            return
        }
        let count = place!.getCommentCount()
        self.btnReview.text = "\(count)" //+ " " + (count > 1 ? Localized.reviews : Localized.review)
    }
    
    func fillData(){
        constraintOpeningTimeHeight.constant = 0
        constraintFreeFacilityHeight.constant = 0
        constraintCheckInOutHeight.constant = 0
        constraintPaidHeight.constant = 0
        constraintThingsHeight.constant = 0
        constraintMapHeight.constant = 0
        constraintContactHeight.constant = 0
        constraintTourDetailHeight.constant = 0
        
        if place == nil {
            return
        }
        // - Photo slide
        fillDataPhotoSlide()
        // - Header + Price
        fillDataHeader()
        
        // - Description
        fillDataDescription()
        
        if categoryType != .CityInfo && categoryType != .Emergency && categoryType != .Transport {
            // Tour
            fillDataTour()
            // - Opening time
            fillDataOpenTime()
            // - Facility
            fillDataFacility()
            // - Check in/out
            fillDataCheckInOut()
            // - Paid facility
            fillDataPaidFacility()
            // - Policy - Things to note
            fillDataPolicy()
            // - Map
            makeMap()
            // contact
            fillDataContact()
        }
        
        // Loved
        fillDataLoved()
        
        // Sleep & Tour booking
        fillTourBooking()
        fillSleepBookingCom()
        fillSleepBookingHostelworld()
        fillSleepBookingAirbnb()
    }
    
    func calculateSubViewLayout() {
        // description
        calculateDescriptionLayout()
    }
    
    func calculateDescriptionLayout(){
        let pDescription = tvDescription.attributedText
        if pDescription == nil || (pDescription?.length)! <= 0 { // nil or empty
            viewDescription.isHidden = true
            constraintDescriptionHeight.constant = 0
        }
        else{
            let full = isShowFullDescription()
            viewDescription.isHidden = false
            // Max height = 60 for 3 line
            var heightDescriptionLabel : CGFloat = tvDescription.getHeight(width: AppSetting.App.screenSize.width - DetailValue.margin * 2)
            if !full {
                btnReadmoreDescription.isHidden = heightDescriptionLabel <= DetailValue.descriptionLabelHeightMax
            }
            else{
                btnReadmoreDescription.isHidden = true
            }
            btnReadmoreOverlay.isHidden = btnReadmoreDescription.isHidden
            if heightDescriptionLabel < DetailValue.descriptionLabelHeightMin {
                heightDescriptionLabel = DetailValue.descriptionLabelHeightMin
            }
            // Giới hạn > 3 line trong trường hợp không show full
            if heightDescriptionLabel > DetailValue.descriptionLabelHeightMax && !isShowFullDescription() {
                heightDescriptionLabel = DetailValue.descriptionLabelHeightMax
            }
            constraintTVDescriptionBottom.constant = DetailValue.margin/2
            constraintDescriptionHeight.constant = heightDescriptionLabel + DetailValue.margin * (full ? 2 : 3.5)
        }
    }
    
    // show full screen for photo slider
    @objc func slideShowFullScreen() {
        let ctr = FullScreenSlideshowViewController()
        ctr.pageSelected = {(page: Int) in
            self.photoSlideshow.setScrollViewPage(page, animated: false)
        }
        ctr.initialPage = photoSlideshow.scrollViewPage
        ctr.inputs = photoSlideshow.images
        slideshowTransitioningDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: photoSlideshow, slideshowController: ctr)
        // self.transitionDelegate?.slideToDismissEnabled = false // disable the slide-to-dismiss full screen
        ctr.transitioningDelegate = slideshowTransitioningDelegate
        self.present(ctr, animated: true, completion: nil)
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
    
    // MARK: - Handle Notification
    @objc func handleFavoriteAdded(notification: Notification){
        btnFavorite.isSelected = true
    }
    
    @objc func handleFavoriteDeleted(notification: Notification){
        btnFavorite.isSelected = false
    }
    
    
    @objc func placeServiceChanged(notification: Notification) {
        let place_ = notification.object as! FPlace
        // check category
        if !checkEqualPlace(place_) {
            return
        }
        place = place_
        // update
        fillData()
    }
    
    @objc func placeServiceRemoved(notification: Notification) {
        let place_ = notification.object as! FPlace
        // check category
        if !checkEqualPlace(place_) {
            return
        }
        // action
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func checkEqualPlace(_ place_: FPlace) -> Bool {
        return place_.snapshot!.key == place?.snapshot!.key
    }
    
    // MARK: - action
    func gotoReadmore(index: Int){
        let readmore = DetailReadmoreViewController(nibName: "DetailReadmoreViewController", bundle: nil)
        readmore.place = place
        let name = labelName.text ?? ""
        let pdescription = place?.getDescription_(full: true)
        let arrayPaids = arrPaidFacilities
        let thingsToNote = place?.getThingsToNoteNew(full: true)
        readmore.setup(title: name, description: pdescription, facility: arrayPaids, note: thingsToNote, index: index)
        self.navigationController?.pushViewController(readmore, animated: true)
    }
    
    @IBAction func actionReadmoreDescriptionOver(_ sender: Any) {
        gotoReadmore(index: 0)
    }
    
    @IBAction func actionReadmoreDescription(_ sender: AnyObject) {
        gotoReadmore(index: 0)
        // let popup = PopupText.popupWith(title: "Description", attributedContent: Place.parseDescription(place))
        // popup.show()
    }
    
    @IBAction func actionReadmorePaidFacilities(_ sender: AnyObject) {
        gotoReadmore(index: 1)
        // let popup = PopupPaidFacility.popupWith(title: "Facilities", content: arrPaidFacilities!)
        // popup.show()
    }
    
    @IBAction func actionReadmoreThingtonote(_ sender: AnyObject) {
        gotoReadmore(index: 2)
        // let popup = PopupText.popupWith(title: "Things to note", attributedContent: Place.parseThingsToNote(place, true))
        // popup.show()
    }
    
    @IBAction func actionLove(_ sender: Any) {
        if place == nil {
            return
        }
        if place!.checkLoved() {
            place?.removeLoved()
        }
        else{
            // Login only -> After logged in, user press LOVE again
            Utils.viewController(self, isSignUp: false, checkLoginWithCallback: {
                self.place?.addLoved()
            })
        }
    }
    
    @IBAction func actionReview(_ sender: Any) {
        if place == nil || place?.snapshot == nil {
            return
        }
        MeasurementHelper.openComment(city: AppState.shared.currentCity?.getName() ?? "NULL")
        let controller = CommentViewController(nibName: "CommentViewController", bundle: nil)
        controller.place = place
        _ = self.navigationController?.pushViewController(controller, animated: true)
    }
    
//    @IBAction func actionShare(_ sender: Any) {
//        let textToShare = place?[FPlace.name] as? String ?? ""
//        let des = place?.getDescription_(full: false).string ?? ""
//        var objectsToShare = [textToShare, des] as [Any]
//        
//        let bounds = UIScreen.main.bounds
//        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
//        self.view.drawHierarchy(in: bounds, afterScreenUpdates: false)
//        let img = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        if img != nil {
//            objectsToShare.append(img!)
//        }
//        
//        if let myWebsite = NSURL(string: AppSetting.App.website) {
//            objectsToShare.append(myWebsite)
//            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//            activityVC.popoverPresentationController?.sourceView = self.view
//            self.present(activityVC, animated: true, completion: nil)
//        }
//    }
    
    // contact
    @IBAction func actionDirection(_ sender: Any) {
        Utils.openMapDirection(place: place!)
    }
    
    @IBAction func actionCall(_ sender: Any) {
        let phone = place?[FPlace.phonenumber] as? String ?? ""
        if phone == "" {
            return
        }
        if phone.contains("/") {
            let phones = phone.components(separatedBy: CharacterSet(charactersIn: "/"))
            if phones.count > 0 {
                let actionSheet = UIActionSheet(title: Localized.Call, delegate: self, cancelButtonTitle: Localized.Cancel, destructiveButtonTitle: nil)
                actionSheet.tag = 1
                for p in phones {
                    actionSheet.addButton(withTitle: p)
                }
                actionSheet.show(in: self.view)
            }
        }
        else{
            Utils.call(phoneNumber: phone)
        }
    }
    
    @IBAction func actionSendMail(_ sender: Any) {
        let mail = place?[FPlace.email] as? String
        if mail == nil || mail == "" {
            return
        }
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            // Configure the fields of the interface.
            composeVC.setToRecipients([mail!])
            composeVC.setSubject("")
            composeVC.setMessageBody("", isHTML: false)
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
        }
        else{
            // send by gmail
            GmailManager.shared.composeMailTo(email: mail!, name: nil, viewController: self)
        }
    }
    
    @IBAction func actionVisitWeb(_ sender: Any) {
        let urlString = place?[FPlace.website] as? String
        if urlString == nil {
            return
        }
        Utils.openUrl(urlString)
    }
    
    @IBAction func actionViewFacebook(_ sender: Any) {
        let urlString = place?[FPlace.facebook] as? String
        if urlString == nil {
            return
        }
        Utils.openUrl(urlString)
    }
    
    @IBAction func actionFavorite(_ sender: Any) {
        if place == nil || place?.objectId == nil {
            return
        }
        if btnFavorite.isSelected {
            // Remove
            AppState.removeFavorited(place: place!, finish: {
                self.view.makeToast(Localized.Removed)
            })
        }
        else{
            // Add
            AppState.addFavorite(place: place!, finish: {
                self.view.makeToast(Localized.Saved)
            })
        }
    }
    
    @IBAction func actionBookTour(_ sender: Any) {
        let url = place?.getTourBookingUrl()
        if url ?? "" == "" {
            self.view.makeToast("Url not found")
            return
        }
        // Open url
        Utils.openUrl(url)
    }
    
    @IBAction func actionSleepBookingCom(_ sender: Any) {
        MeasurementHelper.openBooking()
        let url = place?.getSleepBookingUrl()
        if url ?? "" == "" {
            self.view.makeToast("Url not found")
            return
        }
        // Open url
        Utils.openUrl(url)
    }
    
    @IBAction func actionSleepBookingHostelworld(_ sender: Any) {
        let url = place?.getSleepHostelWorldUrl()
        if url ?? "" == "" {
            self.view.makeToast("Url not found")
            return
        }
        // Open url
        Utils.openUrl(url)
    }
    
    @IBAction func actionSleepBookingAirbnb(_ sender: Any) {
        let url = place?.getSleepAirbnbUrl()
        if url ?? "" == "" {
            self.view.makeToast("Url not found")
            return
        }
        // Open url
        Utils.openUrl(url)
    }
    
    
}

extension DetailViewController : UICollectionViewDataSource {
    // MARK: - collectionview data source
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 && arrFreeFacilities != nil {
            return arrFreeFacilities!.count
        }
        else if collectionView.tag == 2 && arrPaidFacilities != nil {
            return min(arrPaidFacilities!.count, paidItemsMax) // tag = 2
        }
        return 0
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: facilityIdentifier, for: indexPath) as! FreeFacilityCell
            cell.make(facility: arrFreeFacilities![indexPath.row])
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: paidIdentifier, for: indexPath) as! PaidFacilityCell
            cell.makeName((arrPaidFacilities?[indexPath.row])!, size: AppSetting.FontSize.big)
            return cell
        }
    }
}

extension DetailViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDelegate
    // flow layout
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // tag = 1 -> free
        // tag = 2 -> paid
        if collectionView.tag == 1{
            let widthPerItem : CGFloat = AppSetting.App.screenSize.width / facilityItemPerRow
            return CGSize(width: widthPerItem, height: DetailValue.heightFreeFacility)
        }
        else {
            let widthPerItem : CGFloat = AppSetting.App.screenSize.width / CGFloat(paidItemPerRow) - 5
            return CGSize(width: widthPerItem, height: DetailValue.heightPaidItem)
        }
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Map data
extension DetailViewController {
    func makeMap() {
        mapview.clear()
        let art = GooglePlace.fromPlace(place!, categoryType: categoryType)
        if art != nil && categoryType != nil{
            let marker = PlaceMarker(googlePlace: art!, index: 1, categoryType: categoryType!)
            marker.map = self.mapview
            constraintMapHeight.constant = 130
        }
        else{
            constraintMapHeight.constant = 0
            imgSeperatorMap.isHidden = false
        }
    }
    
}

// MARK: - GMSMapViewDelegate
extension DetailViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.selectedMarker = nil
        return false
    }
    
}

// MARK: - MFMailComposeViewController Delegate
extension DetailViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIScrollView Delegate
extension DetailViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        // Header Color, offse > 0 -> UP
        let alpha : CGFloat = offset <= 0 ? 0 : min(1, (offset/DetailValue.PhotoShowHeight))
        header.backgroundColor = UIColor(hex6: UInt32(AppSetting.Color.blue), alpha: alpha)
        header.labelCategoryName.alpha = alpha
        
        
        // PHOTO SHOW bounce
        if offset <= 0 {
            let height = DetailValue.PhotoShowHeight + abs(offset)
            // Pulldown -> scale photo show
            constraintPhotoShowTop.constant = 0
            constraintPhotoShowHeight.constant = height
            // Header
            constraintHeaderTop.constant = 0
            constraintHeaderHeight.constant = height
        }
        else {
            let top = Int(offset) > 2 ? -CGFloat(sqrt(Double(offset * offset - offset*2.0))) : offset
            // Pullup -> move photo show up (parallax)
            constraintPhotoShowHeight.constant = DetailValue.PhotoShowHeight
            constraintPhotoShowTop.constant = top
            // Header
            constraintHeaderTop.constant = top
            constraintHeaderHeight.constant = DetailValue.PhotoShowHeight
        }
    }
}


// MARK: - FILL DATA
extension DetailViewController {
    // Photo slideshow
    func fillDataPhotoSlide() {
        let photos = place?[FPlace.photos] as? [String]
        if photos != nil && photos!.count > 0 {
            photoSlideshow.backgroundColor = UIColor.clear
            photoSlideshow.slideshowInterval = 4.0
            photoSlideshow.pageControlPosition = PageControlPosition.insideScrollView
            photoSlideshow.contentScaleMode = UIView.ContentMode.scaleAspectFill
            // source
            var source : Array<InputSource> = []
            for photo in photos! {
                source.append(SDWebImageSource(url: URL(string: photo)!, placeholder: UIImage(named: "img-default")!))
            }
            photoSlideshow.setImageInputs(source)
            // full screen
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.slideShowFullScreen))
            photoSlideshow.addGestureRecognizer(recognizer)
        }
    }
    
    // Name + Price (if has)
    func fillDataHeader() {
        // Name
        labelName.text = place != nil ? place!.getName() : ""
        // Price
        labelPrice.text = place != nil ? place!.getPriceString(categoryType: categoryType) : ""
        constraintLabelPriceHeight.constant = labelPrice.text == "" ? 0 : 20
    }
    
    // Open Time
    func fillDataOpenTime() {
        let openingday = place?[FPlace.openingday] as? String
        let openingtime = place?[FPlace.openingtime] as? String
        if ((openingday ?? "") == "") && ((openingtime ?? "") == "") {
            // both of opening is empty
            constraintOpeningTimeHeight.constant = 0
        }
        else{
            constraintOpeningTimeHeight.constant = DetailValue.heightOpeningTime
            labelOpeningDay.text = openingday
            labelOpeningTime.text = openingtime
        }
    }
    
    // Facility Free
    func fillDataFacility() {
        let freefacilitieskey = place?[FPlace.facilities] as! [String]?
        if (freefacilitieskey != nil) && (freefacilitieskey?.count)! > 0 {
            arrFreeFacilities = FacilityService.facilitiesFor(keys: freefacilitieskey!)
            constraintFreeFacilityHeight.constant = DetailValue.heightFreeFacility
        }
        else{
            arrFreeFacilities = []
            constraintFreeFacilityHeight.constant = 0
        }
    }
    
    // Description
    func isShowFullDescription() -> Bool{
        return categoryType == .CityInfo || categoryType == .Emergency || categoryType == .Transport
    }
    
    func fillDataDescription() {
        let full = isShowFullDescription()
        tvDescription.attributedText = place?.getDescription_(full: full)
        btnReadmoreDescription.isHidden = full
        btnReadmoreOverlay.isHidden = full
        
        constraintDescriptionTitleHeight.constant = full ? 0 : 20
        constraintTVDescriptionTop.constant = full ? 20 : 50
    }
    
    // Check In/Out
    func fillDataCheckInOut(){
        labelCheckinValue.text = place?.getCheckin()
        labelCheckoutValue.text = place?.getCheckout()
        if labelCheckinValue.text ?? "" == "" && labelCheckoutValue.text ?? "" == "" {
            constraintCheckInOutHeight.constant = 0
        }
        else{
            constraintCheckInOutHeight.constant = 85
        }
    }
    
    // Paid Facility
    func fillDataPaidFacility(){
        arrPaidFacilities = place?.getPaidFacility()
        if (arrPaidFacilities?.count)! == 0 {
            constraintPaidHeight.constant = 0
            btnReadmoreFacility.isHidden = true
        }
        else { // > 4
            let isMore = (arrPaidFacilities?.count)! > Int(paidItemsMax)
            btnReadmoreFacility.isHidden = !isMore
            constraintCollectionPaidBottom.constant = 20
            let items : Double = isMore ? Double(paidItemsMax) : Double((arrPaidFacilities?.count)!)
            let rows = ceil(items/Double(paidItemPerRow))
            constraintPaidHeight.constant = 20 + 20 + 10 + CGFloat(rows) * DetailValue.heightPaidItem + constraintCollectionPaidBottom.constant
        }
    }
    
    // Policy
    func fillDataPolicy(){
        let things = place?.getThingsToNoteNew(full: false)
        labelPolicy.attributedText = things
        if things != nil && (things?.length)! > 0 {
            var thingsHeight = labelPolicy.getHeight(width: AppSetting.App.screenSize.width - 40)
            btnReadmoreThings.isHidden = thingsHeight <= DetailValue.descriptionLabelHeightMax
            if thingsHeight > DetailValue.descriptionLabelHeightMax{
                thingsHeight = DetailValue.descriptionLabelHeightMax
            }
            if thingsHeight < DetailValue.descriptionLabelHeightMin {
                thingsHeight = DetailValue.descriptionLabelHeightMin
            }
            constraintLabelThingsBottom.constant = AppSetting.Common.margin
            constraintThingsHeight.constant = thingsHeight + AppSetting.Common.margin * 4
        }
        else{
            constraintThingsHeight.constant = 0
        }
    }
    
    // Contact
    func fillDataContact() {
        let address = place?[FPlace.address] as? String
        if (address ?? "") != "" {
            labelContactAddress.text = address
            constraintContactAddressHeight.constant = DetailValue.contactItemHeight
        }
        else {
            constraintContactAddressHeight.constant = 0
        }
        
        let phone = place?[FPlace.phonenumber] as? String
        if (phone ?? "") != "" {
            labelContactPhone.text = phone
            constraintContactPhoneHeight.constant = DetailValue.contactItemHeight
        }
        else {
            constraintContactPhoneHeight.constant = 0
        }
        
        let mail = place?[FPlace.email] as? String
        if (mail ?? "") != "" {
            labelContactMail.text = mail
            constraintContactMailHeight.constant = DetailValue.contactItemHeight
        }
        else{
            constraintContactMailHeight.constant = 0
        }
        
        let web = place?[FPlace.website] as? String
        if (web ?? "") != "" {
            labelContactWeb.text = web
            constraintContactWebHeight.constant = DetailValue.contactItemHeight
        }
        else{
            constraintContactWebHeight.constant = 0
        }
        
        let fb = place?[FPlace.facebook] as? String
        if (fb ?? "") != "" {
            labelContactFacebook.text = fb
            constraintContactFacebookHeight.constant = DetailValue.contactItemHeight
        }
        else{
            constraintContactFacebookHeight.constant = 0
        }
        constraintContactHeight.constant = constraintContactAddressHeight.constant + constraintContactPhoneHeight.constant + constraintContactMailHeight.constant + constraintContactWebHeight.constant + constraintContactFacebookHeight.constant
    }
    
    // Loved
    func fillDataLoved() {
        let loved = Utils.formatNumber((place?.getLovedCount())!)
        btnLove.text = loved
        constraintLovedWith.constant = 25 + loved.widthWithConstrainedHeight(height: 20, font: (btnLove.label?.font)!)
        btnLove.isSelected = (place?.checkLoved())!
    }
    
    // Tour
    func fillDataTour(){
        if categoryType == .Tours {
            labelTourLocation.text = place?.getTourLocation()
            labelTourDuration.text = place?.getTourDuration()
            labelTourLanguage.text = place?.getTourLanguage()
            labelTourTranspot.text = place?.getTourTranspotation()
            labelTourGroupSize.text = place?.getTourGroupSize()
            constraintTourDetailHeight.constant = 300
        }
        else{
            constraintTourDetailHeight.constant = 0
        }
    }
    
    func fillTourBooking() {
        let bookingUrl = place != nil ? place?.getTourBookingUrl() : nil
        if bookingUrl != nil && self.categoryType == .Tours {
            constraintViewBookTourHeight.constant = 90
        }
        else{
            constraintViewBookTourHeight.constant = 0
        }
    }
    
    // Sleep booking
    func fillSleepBookingCom() {
        let bookingUrl = place != nil ? place?.getSleepBookingUrl() : nil
        if bookingUrl != nil && self.categoryType == .Sleep {
            constraintSleepBookingComHeight.constant = 90
        }
        else{
            constraintSleepBookingComHeight.constant = 0
        }
    }
    
    func fillSleepBookingHostelworld() {
        let bookingUrl = place != nil ? place?.getSleepHostelWorldUrl() : nil
        if bookingUrl != nil && self.categoryType == .Sleep {
            constraintSleepHostelWorldHeight.constant = 90
        }
        else{
            constraintSleepHostelWorldHeight.constant = 0
        }
    }
    
    func fillSleepBookingAirbnb() {
        let bookingUrl = place != nil ? place?.getSleepAirbnbUrl() : nil
        if bookingUrl != nil && self.categoryType == .Sleep {
            constraintSleepBookingAirbnbHeight.constant = 90
        }
        else{
            constraintSleepBookingAirbnbHeight.constant = 0
        }
    }
}

// MARK: - ACTION SHEET delegate
extension DetailViewController : UIActionSheetDelegate {
    // ACTION SHEET DELEGATE
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        // Phone
        if actionSheet.tag == 1 {
            switch (buttonIndex){
            case 0:
                return
            default:
                let number = actionSheet.buttonTitle(at: buttonIndex)
                if number ?? "" != "" {
                    Utils.call(phoneNumber: number!)
                }
            }
        }
        
    }
}


