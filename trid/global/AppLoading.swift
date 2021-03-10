//
//  AppLoading.swift
//  trid
//
//  Created by Black on 9/29/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Foundation

class AppLoading: NSObject {
    
    private static var shownLoadingProgress = false
    
    static func showLoading() {
        if ARSLineProgress.shown {
            return
        }
        ARSLineProgress.showWithPresentCompetionBlock { () -> Void in
            print("Showed with completion block")
        }
    }
    
    static func hideLoading() -> Void {
        ARSLineProgress.hideWithCompletionBlock({ () -> Void in
            print("Hidden with completion block")
            AppLoading.shownLoadingProgress = false
        })
    }
    
    static func showLoadingWithProgress(value: CGFloat) {
        if ARSLineProgress.shown && shownLoadingProgress {
            ARSLineProgress.updateWithProgress(value)
        }
        else {
            ARSLineProgress.showWithProgress(initialValue: value)
            shownLoadingProgress = true
        }
    }
    
    // MARK: In case you want, you can use regular CGFloat value with showWithProgress(initialValue: 1.0) method.
    static func showLoadingWithProgress(progressObject: Progress){
        showLoadingWithProgress(progressObject: progressObject, successCheckmard: false)
    }
    
    static func showLoadingWithProgress(progressObject: Progress, successCheckmard: Bool) {
        if ARSLineProgress.shown {
            return
        }
        ARSLineProgressConfiguration.showSuccessCheckmark = successCheckmard
        ARSLineProgress.showWithProgressObject(progressObject, completionBlock: {
            print("Success completion block")
        })
    }
    
    static func cancelLoadingWithFailAnimation(){
        ARSLineProgress.cancelPorgressWithFailAnimation(true, completionBlock: {
            print("Cancel loading - Hidden with completion block")
        })
    }
    
    static func showSuccess() {
        ARSLineProgress.showSuccess()
    }
    
    static func showFail() {
        ARSLineProgress.showFail()
    }
    
    //        DispatchQueue.main.asyncAfter(deadline: NSEC_PER_SEC, execute: { () -> Void in
    //        })
}
