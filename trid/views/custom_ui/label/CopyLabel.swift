//
//  CopyLabel.swift
//  trid
//
//  Created by Black on 2/11/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit

class CopyLabel: UILabel {
    
    func attachTapHandler() {
        self.isUserInteractionEnabled = true
        let touchy = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(touchy)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        attachTapHandler()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        attachTapHandler()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        attachTapHandler()
    }
    
    // MARK: - Clipboard
    
    @objc func actionCopy(_ sender: Any?) {
        debugPrint("Copy handler, label:", self.text ?? "")
        let paste = UIPasteboard.general
        paste.string = self.text ?? ""
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(actionCopy) {
            return true
        }
        return false // action == #selector(copy)
    }
    
    @objc func handleTap(recognizer: UIGestureRecognizer){
        self.becomeFirstResponder()
        if self.superview == nil {
            return
        }
        let menu = UIMenuController.shared
        let item = UIMenuItem(title: "Copy", action: #selector(actionCopy))
        menu.menuItems = [item]
        menu.setTargetRect(self.frame, in: self.superview!)
        menu.setMenuVisible(true, animated: true)
    }
    
    override var canBecomeFirstResponder: Bool{
        get{
            return true
        }
    }

}
