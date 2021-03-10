//
//  DetailReadmoreViewController.swift
//  trid
//
//  Created by Black on 10/12/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DetailReadmoreViewController: DashboardBaseViewController {
    // outlet
    @IBOutlet weak var segmentio: Segmentio!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var constraintSegmentHeight: NSLayoutConstraint!
    
    // description
    @IBOutlet weak var tvDescription: UITextView!
    
    // facility
    @IBOutlet weak var collectionPaids: UICollectionView!
    @IBOutlet weak var constraintFacilityWidthEqualDescription: NSLayoutConstraint!
    
    // things to note
    @IBOutlet weak var tvThings: UITextView!
    @IBOutlet weak var constraintNoteWidthEqualDescription: NSLayoutConstraint!
    

    // variable
    var place : FPlace?
    // facility
    fileprivate let paidItemPerRow : Int = 2
    fileprivate let paidItemsMax : Int = 6
    var placename: String?
    var arrayPaids : Array<String>?
    var pdescription: NSAttributedString?
    var thingsToNote : NSAttributedString?
    var selectedIndex : Int = 0
    var setup = false
    var segments : Array<SegmentioItem> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // header
        header.makeHeaderDetailReadmorePlace(name: placename!)
        // hide tabbar
        tabbar.isHidden = true
        
        // Paid facility - collection view
        collectionPaids.register(UINib(nibName: PaidFacilityCell.className, bundle: nil), forCellWithReuseIdentifier: PaidFacilityCell.className)
        
        // description
        tvDescription.attributedText = pdescription
        tvDescription.textContainerInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        
        // things to note
        tvThings.attributedText = thingsToNote
        tvThings.textContainerInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        
        
        // segment
        if !setup{
            if (arrayPaids == nil || (arrayPaids?.count)! == 0) && (thingsToNote == nil || (thingsToNote?.length)! == 0){
                setupSegmentioView()
                setup = true
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tvDescription.setContentOffset(CGPoint.zero, animated: false)
        tvThings.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !setup {
            setupSegmentioView()
            setup = true
        }
    }
    
    public func setup(title: String, description: NSAttributedString?, facility: [String]?, note: NSAttributedString?, index: Int){
        selectedIndex = index
        placename = title
        pdescription = description
        arrayPaids = facility
        thingsToNote = note
    }
    
    fileprivate func setupSegmentioView() {
        // make arr
        if (arrayPaids == nil || (arrayPaids?.count)! == 0) && (thingsToNote == nil || (thingsToNote?.length)! == 0) {
            // hide segment
            constraintSegmentHeight.constant = 0
            // move description to top
            header.makeHeaderDetailReadmorePlace(name: "Description")
            // scrollview content size
            constraintFacilityWidthEqualDescription.constant = -AppSetting.App.screenSize.width
            constraintNoteWidthEqualDescription.constant = -AppSetting.App.screenSize.width
        }
        else{
            if pdescription != nil && (pdescription?.length)! > 0 {
                segments.append(SegmentioItem(title: "Description", image: UIImage(named: "")))
            }
            if arrayPaids != nil && (arrayPaids?.count)! > 0 {
                segments.append(SegmentioItem(title: "Facilities", image: UIImage(named: "")))
            }
            if thingsToNote != nil && (thingsToNote?.length)! > 0 {
                segments.append(SegmentioItem(title: "Note", image: UIImage(named: "")))
            }
        }
        // setup
        segmentio.setup(
            content: segments,
            style: SegmentioStyle.onlyLabel,
            options: segmentio.segmentioOptions(maxVisibleItems: 3)
        )
        segmentio.valueDidChange = { [weak self] _, segmentIndex in
            if let scrollViewWidth = self?.scrollview.frame.width {
                let contentOffsetX = scrollViewWidth * CGFloat(segmentIndex)
                self?.scrollview.setContentOffset(CGPoint(x: contentOffsetX, y: 0), animated: true)
            }
        }
        segmentio.selectedSegmentioIndex = selectedIndex
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
    
    // MARK: - Segmentio
//    fileprivate func segmentioContent() -> [SegmentioItem] {
//        return
//    }
    
//    fileprivate func segmentioOptions() -> SegmentioOptions {
//        let imageContentMode = UIViewContentMode.center
//        return SegmentioOptions(
//            backgroundColor: .white,
//            maxVisibleItems: 3,
//            scrollEnabled: true,
//            indicatorOptions: segmentioIndicatorOptions(),
//            horizontalSeparatorOptions: segmentioHorizontalSeparatorOptions(),
//            verticalSeparatorOptions: segmentioVerticalSeparatorOptions(),
//            imageContentMode: imageContentMode,
//            labelTextAlignment: .center,
//            segmentStates: segmentioStates()
//        )
//    }
//    
//    fileprivate func segmentioStates() -> SegmentioStates {
//        let font = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.normal)
//        return SegmentioStates(
//            defaultState: segmentioState(
//                backgroundColor: .white,
//                titleFont: font!,
//                titleTextColor: UIColor(netHex: AppSetting.Color.gray)
//            ),
//            selectedState: segmentioState(
//                backgroundColor: .white,
//                titleFont: font!,
//                titleTextColor: UIColor(netHex: AppSetting.Color.blue)
//            ),
//            highlightedState: segmentioState(
//                backgroundColor: .white,
//                titleFont: font!,
//                titleTextColor: UIColor(netHex: AppSetting.Color.gray)
//            )
//        )
//    }
//    
//    fileprivate func segmentioState(backgroundColor: UIColor, titleFont: UIFont, titleTextColor: UIColor) -> SegmentioState {
//        return SegmentioState(backgroundColor: backgroundColor, titleFont: titleFont, titleTextColor: titleTextColor)
//    }
//    
//    fileprivate func segmentioIndicatorOptions() -> SegmentioIndicatorOptions {
//        return SegmentioIndicatorOptions(type: .bottom, ratio: 1, height: 2, color: UIColor(netHex: AppSetting.Color.blue))
//    }
//    
//    fileprivate func segmentioHorizontalSeparatorOptions() -> SegmentioHorizontalSeparatorOptions {
//        return SegmentioHorizontalSeparatorOptions(type: .topAndBottom, height: 0.5, color: UIColor(netHex: AppSetting.Color.whitesmoke))
//    }
//    
//    fileprivate func segmentioVerticalSeparatorOptions() -> SegmentioVerticalSeparatorOptions {
//        return SegmentioVerticalSeparatorOptions(ratio: 1, color: UIColor(netHex: AppSetting.Color.whitesmoke))
//    }
}

extension DetailReadmoreViewController : UICollectionViewDataSource {
    // MARK: - collectionview data source
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if arrayPaids != nil {
            return (arrayPaids?.count)!
        }
        return 0
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaidFacilityCell.className, for: indexPath) as! PaidFacilityCell
        cell.makeName((arrayPaids?[indexPath.row])!, color: UIColor(netHex: AppSetting.Color.gray), size: AppSetting.FontSize.big)
        return cell
    }

}

extension DetailReadmoreViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // UICollectionViewDelegateFlowLayout
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthPerItem : CGFloat = AppSetting.App.screenSize.width / CGFloat(paidItemPerRow) - 2
        return CGSize(width: widthPerItem, height: DetailValue.heightPaidItemBig)
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

extension DetailReadmoreViewController : UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = AppSetting.App.screenSize.width
        let currentPage : Int = Int(ceil(scrollview.contentOffset.x / pageWidth))
        let max = segments.count - 1
        if (0.0 != fmodf(Float(currentPage), 1.0)) {
            segmentio.selectedSegmentioIndex = min(currentPage + 1, max)
        } else {
            segmentio.selectedSegmentioIndex = min(currentPage, max)
        }
    }
}

