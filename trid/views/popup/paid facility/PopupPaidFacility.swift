//
//  PopupPaidFacility.swift
//  trid
//
//  Created by Black on 10/10/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import PureLayout

class PopupPaidFacility: PopupBase, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var labelTitle : UILabel!
    var collectionPaid : UICollectionView!
    
    // variable
    fileprivate let paidIdentifier = NSStringFromClass(PaidFacilityCell.classForCoder())
    fileprivate let paidItemPerRow : Int = 2
    fileprivate let paidItemsMax : Int = 6
    var arrayPaids : Array<String>?
    
    public static func popupWith(title: String, content: Array<String>) -> PopupPaidFacility {
        let popup = PopupPaidFacility(forAutoLayout: ())
        popup.make(title: title, content: content)
        return popup
    }
    
    func makeUI(){
        // title
        labelTitle = UILabel(forAutoLayout: ())
        labelTitle.textAlignment = NSTextAlignment.center
        labelTitle.numberOfLines = 0
        labelTitle.textColor = UIColor(netHex: AppSetting.Color.black)
        labelTitle.font = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.veryBig)
        self.viewBg.addSubview(labelTitle)
        labelTitle.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: AppSetting.Common.margin)
        labelTitle.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: AppSetting.Common.margin)
        labelTitle.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        // content

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        
        collectionPaid = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionPaid.configureForAutoLayout()
        collectionPaid.backgroundColor = UIColor.clear
        collectionPaid.register(UINib(nibName: "PaidFacilityCell", bundle: nil), forCellWithReuseIdentifier: paidIdentifier)
        collectionPaid.delegate = self
        collectionPaid.dataSource = self
        collectionPaid.allowsSelection = false
        collectionPaid.isScrollEnabled = false
        self.viewBg.addSubview(collectionPaid)
        collectionPaid.autoPinEdge(toSuperviewEdge: ALEdge.leading)
        collectionPaid.autoPinEdge(toSuperviewEdge: ALEdge.trailing)
        collectionPaid.autoPinEdge(toSuperviewEdge: ALEdge.bottom, withInset: AppSetting.Common.margin)
        collectionPaid.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: labelTitle, withOffset: AppSetting.Common.margin)
    }
    
    func make(title: String, content: Array<String>){
        makeUI()
        // assign text
        labelTitle.text = title
        // collection
        arrayPaids = content
        collectionPaid.reloadData()
        
        // calculate popup height
        let heightTitle = title.heightWithConstrainedWidth(width: self.widthContent, font: labelTitle.font)
        let heightContent = DetailValue.heightPaidItem * CGFloat((arrayPaids?.count)!)/CGFloat(paidItemPerRow)
        // set constraint
        labelTitle.autoSetDimension(ALDimension.height, toSize: heightTitle)
        collectionPaid.autoSetDimension(ALDimension.height, toSize: heightContent)
        makePopupHeight(contentHeight: heightTitle + heightContent + AppSetting.Common.margin * 3)
    }
    
    // MARK: - collectionview data source
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return (arrayPaids?.count)!
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: paidIdentifier, for: indexPath) as! PaidFacilityCell
        cell.makeName((arrayPaids?[indexPath.row])!)
        return cell
    }
    // UICollectionViewDelegateFlowLayout
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthPerItem : CGFloat = self.width / CGFloat(paidItemPerRow) - 2
        return CGSize(width: widthPerItem, height: DetailValue.heightPaidItem)
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
