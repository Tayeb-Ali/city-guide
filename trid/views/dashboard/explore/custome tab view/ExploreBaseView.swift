//
//  ExploreBaseView.swift
//  trid
//
//  Created by Black on 2/17/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

protocol ExploreBaseViewDelegate {
    func collectionWillBeginDragging(_ exploreView: Any, offset: CGFloat)
    func collectionDidEndDrag(_ exploreView: Any, willDecelerate decelerate: Bool)
    func collection(_ exploreView: Any, didScroll offset: CGFloat)
    func collectionDidEndMoving(_ exploreView: Any)
    func collection(_ exploreView: Any, scrollViewWillBeginDecelerating scrollView: UIScrollView)
}

class ExploreBaseView: UIView {
    
    // Variables
    var exploreKey = ""
    var lastContentOffset : CGFloat = 0
    var paddingTopDefault : CGFloat = 0
    var parentViewController : UIViewController?
    var needUpdate : Bool = false

    // Delegate
    var delegate : ExploreBaseViewDelegate?
    
    // Action for override
    func getContentOffset() -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    func setContentOffsetY(_ y: CGFloat, animated: Bool) {
        // For override
    }
    
    func isMainScroll(_ scrollView: UIScrollView) -> Bool{
        return false
    }
    
    func disableScroll(_ isDisable: Bool){
        // For override
    }

}

// MARK: - Scrollview delegate
extension ExploreBaseView : UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // This func just for main scroll
        if !isMainScroll(scrollView){
            return
        }
        // ------------------------------
        // update the new position acquired
        // if in search mode -> fix header
        lastContentOffset = scrollView.contentOffset.y
        if delegate != nil {
            delegate?.collectionWillBeginDragging(self, offset: lastContentOffset)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // This func just for main scroll
        if !isMainScroll(scrollView){
            return
        }
        // ------------------------------
        if delegate != nil {
            delegate?.collection(self, didScroll: scrollView.contentOffset.y - lastContentOffset)
        }
        lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // This func just for main scroll
        if !isMainScroll(scrollView){
            return
        }
        // ------------------------------
        if delegate != nil {
            delegate?.collectionDidEndDrag(self, willDecelerate: decelerate)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // This func just for main scroll
        if !isMainScroll(scrollView){
            return
        }
        // ------------------------------
        if delegate != nil{
            delegate?.collectionDidEndMoving(self)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        // This func just for main scroll
        if !isMainScroll(scrollView){
            return
        }
        if delegate != nil {
            delegate?.collection(self, scrollViewWillBeginDecelerating: scrollView)
        }
        
//        // ------------------------------
//        // collection get more data
//        let bottomOffset = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height
//        // This scrollView is a UITableView
//        if bottomOffset > 60 && delegate != nil && delegate?.collectionDidPullBottom != nil{
//            // load more
//            delegate?.collectionDidPullBottom(self)
//        }
//        else if delegate != nil {
//            delegate?.collection(self, scrollViewWillBeginDecelerating: scrollView)
//        }
    }
}
