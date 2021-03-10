//
//  AskShareViewController.swift
//  trid
//
//  Created by Black on 9/1/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit
import PureLayout

class AskShareViewController: DashboardBaseViewController {
    
    @IBOutlet weak var constraintBodyTop: NSLayoutConstraint!
    @IBOutlet weak var body: UIView!
    var tipView : ExploreCollectionView!
    let tipKey = CategoryService.shared.getCategoryKeyForType(.Tips)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.makeHeaderAskShare()
        constraintBodyTop.constant = AppSetting.App.headerHeight
        
        // add tip view collection
        tipView = ExploreCollectionView.create(categoryKey: tipKey, paddingTop: 5, inParentViewController: self)
        body.addSubview(tipView)
        tipView.autoPinEdge(toSuperviewEdge: ALEdge.leading)
        tipView.autoPinEdge(toSuperviewEdge: ALEdge.top)
        tipView.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        tipView.autoPinEdge(toSuperviewEdge: ALEdge.trailing)
        // data
        let catPlaces = PlaceService.placesForCategoryKey(tipKey).sorted(by: {$0.getDateTime() > $1.getDateTime()})
        tipView.list = catPlaces
        tipView.listFilter = catPlaces
        tipView.reloadData()
        // delegate
        tipView.delegateCollection = self
        
        // Register notification to update place
        NotificationCenter.default.addObserver(self, selector: #selector(AskShareViewController.placeServiceAdded), name: Notification.Name(PlaceServiceKey.added), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AskShareViewController.placeServiceChanged), name: Notification.Name(PlaceServiceKey.changed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AskShareViewController.placeServiceRemoved), name: Notification.Name(PlaceServiceKey.removed), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func headerBarGoBackImpl() {
        self.tabBarController?.selectedIndex = 0 // navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Explore CollectionView Delegate
extension AskShareViewController : ExploreCollectionViewDelegate {
    
    func exploreCollection(_ exploreView: ExploreCollectionView, didSelectItemAt indexPath: IndexPath) {
        if exploreView.listFilter != nil
            && exploreView.listFilter!.count > 0
            && indexPath.row < exploreView.listFilter!.count
            && indexPath.row >= 0 {
            let place = exploreView.listFilter?[indexPath.row]
            if place == nil {
                return
            }
            // Tip -> Move to comment page
            let controller = CommentViewController(nibName: "CommentViewController", bundle: nil)
            controller.categoryType = FCategoryType.Tips
            controller.place = place
            _ = self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func exploreCollectionDidLoadMore(_ exploreView: ExploreCollectionView) {
        
    }
    
    func exploreCollectionDidFilter(_ exploreView: ExploreCollectionView, height: CGFloat) {
        
    }
}

// MARK: - PLACE SERVICE DELEGATE | Firebase event
extension AskShareViewController {
    // 1 Add
    @objc func placeServiceAdded(notification: Notification) {
        guard let p = notification.object as? FPlace else {return}
        // Collection
        if p.getCategories().contains(tipKey) {
            tipView.insertTopPlace(p, withReload: true)
        }
    }
    // 2 Changed
    @objc func placeServiceChanged(notification: Notification) {
        guard let p = notification.object as? FPlace else {
            return
        }
        // Collection
        if p.getCategories().contains(tipKey) {
            tipView.updateChangedPlace(p, withReload: true)
        }
    }
    
    // 3 Remove
    @objc func placeServiceRemoved(notification: Notification) {
        
    }
}



