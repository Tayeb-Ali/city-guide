//
//  GuideViewController.swift
//  trid
//
//  Created by Black on 9/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import PureLayout
import SDWebImage

class GuideViewController: DashboardBaseViewController {

    // photo intro
    @IBOutlet weak var image: UIImageView!
    // category
    @IBOutlet weak var collectionPage: UICollectionView!
    @IBOutlet weak var pagecontrol: UIPageControl!
    
    // header
    @IBOutlet weak var labelCityName: UILabel!
    @IBOutlet weak var labelCityIntro: UILabel!
    
    // variable
    var city : FCity!
    fileprivate let itemPerPage : CGFloat = 9
    
    override func viewDidLoad() {
        super.viewDidLoad()
        city = AppState.shared.currentCity!
        image.sd_setImage(with: URL(string: city.getPhotoUrl()))
        labelCityName.text = city.getName()
        labelCityIntro.text = city[FCity.intro] as? String
        // header
        header.makeHeaderHomeGuide()
        // register cell
        self.collectionPage.isPagingEnabled = true
        self.collectionPage.register(UINib(nibName: CategoryPageCell.className, bundle: nil), forCellWithReuseIdentifier: CategoryPageCell.className)
        
        // page control
        pagecontrol.numberOfPages = Int(ceil(CGFloat(CityCategoryService.shared.categoriesOfCurrentCity.count)/itemPerPage))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppState.clearCurrentCategory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension GuideViewController : UICollectionViewDataSource {
    // MARK: - collectionview data source
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Int(ceil(CGFloat(CityCategoryService.shared.categoriesOfCurrentCity.count)/itemPerPage))
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryPageCell.className, for: indexPath) as! CategoryPageCell
        return cell
    }
}

extension GuideViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CategoryPageCollectionProtocol {
    
    // MARK: - UICollectionViewDelegate
    // 1
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let collectionViewCell = cell as? CategoryPageCell else { return }
        //        collectionViewCell.delegate = self
        let dataSource = CategoryPageCollectionDataSource()
        let count : Int = Int(itemPerPage)
        dataSource.data = Array(CityCategoryService.shared.categoriesOfCurrentCity[(count*indexPath.section)..<min(CityCategoryService.shared.categoriesOfCurrentCity.count, count*(indexPath.section + 1))])
        let delegate = CategoryPageCollectionDelegate()
        delegate.delegate = self
        // init
        collectionViewCell.initializeCollectionViewWithDataSource(dataSource, delegate: delegate, forRow: (indexPath as NSIndexPath).section)
    }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = AppSetting.App.screenSize.width
        return CGSize(width: width, height: width)
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
    
    // Selected item in page
    func categoryPageCollectionSelectedAt(index: Int, ofPage page: Int) {
        // Current category
        let cat = CityCategoryService.shared.categoriesOfCurrentCity[page*Int(itemPerPage) + index]
        AppState.shared.currentCategory = cat
        // Places list for current category
        let catPlaces = PlaceService.placesForCategoryKey(cat.objectId!)
        AppState.shared.placesForCurrentCategory = catPlaces
        
        // Navigate to next page
        if cat.isCityInfoCategory() {
            if catPlaces.count > 0 {
                let info = DetailViewController(nibName: "DetailViewController", bundle: nil)
                info.categoryType = FCategoryType.CityInfo
                info.place = catPlaces[0]
                self.navigationController?.pushViewController(info, animated: true)
            }
            else {
                let popup = PopupText.popupWith(title: AppSetting.App.name, content: "This city doesn't has info yet")
                popup.show()
            }
        }
        else {
            let category = CategoryViewController(nibName: "CategoryViewController", bundle: nil)
            self.navigationController?.pushViewController(category, animated: true)
        }
    }
    
}

extension GuideViewController : UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = AppSetting.App.screenSize.width
        let currentPage : Int = Int(ceil(collectionPage.contentOffset.x / pageWidth))
        
        if (0.0 != fmodf(Float(currentPage), 1.0))
        {
            pagecontrol.currentPage = currentPage + 1
        }
        else
        {
            pagecontrol.currentPage = currentPage
        }
    }
}


