//
//  CommentViewController.swift
//  trid
//
//  Created by Black on 12/5/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase

class CommentViewController: DashboardBaseViewController {

    // - Tip
    
    // - Outlet
    @IBOutlet weak var tableComment: UITableView!
    @IBOutlet weak var viewComment: UIView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var tfComment: UITextField!
    @IBOutlet weak var constraintCommentHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintTableCommentTop: NSLayoutConstraint!
    
    var tipViewHeader: TipView?
    
    // variable
    var categoryType : FCategoryType?
    var place: FPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI
        setupUI()
        constraintTableCommentTop.constant = AppSetting.App.headerHeight
        
        // hide tabbar
        tabbar.isHidden = true
        
        // table
        tableComment.register(UINib(nibName: CommentCell.className, bundle: nil), forCellReuseIdentifier: CommentCell.className)
        
        // Implement later: Register notification keyboard show/hide
        if place != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(handlePlaceChanged), name: NotificationKey.placeUpdated(place!.objectId!), object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadComment()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // remove comment delegate
        CommentService.shared.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadComment() {
        if place == nil || place?.objectId == nil {
            return
        }
        if TridService.shared.isOnline {
            AppLoading.showLoading()
            CommentService.shared.configureDatabase(placeKey: place!.objectId!, finish: {
                AppLoading.hideLoading()
                // REload
                self.tableComment.reloadData()
                // add comment delegate
                CommentService.shared.delegate = self
            })
        }
        else {
            self.view.makeToast("Please check internet connection and try again")
        }
    }
    
    // MARK: - SETUP UI
    func setupUI() {
        // Header
        setupHeader()
        // Comment View
        tfComment.placeholder = Localized.writeComment
    }
    
    func setupHeader() {
        let size = AppSetting.App.screenSize
        // Header
        if categoryType != nil && categoryType == FCategoryType.Tips {
            var height : CGFloat = 0
            if place != nil {
                header.makeHeaderDetailReadmorePlace(name: AppState.shared.currentCity?.getName() ?? "")
                // TIP
                if tipViewHeader == nil {
                    tipViewHeader = TipView.makeTip()
                    tableComment.tableHeaderView?.addSubview(tipViewHeader!)
                    tipViewHeader?.autoPinEdgesToSuperviewEdges()
                }
                tipViewHeader?.fill(place: place!, parentController: self, type: .Full)
                height = TipView.calculateHeightWithText(place!.getTipContent() ?? "", type: .Full)
            }
            tableComment.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: size.width, height: height)
        }
        else{
            // OTHER
            if place != nil {
                header.makeHeaderDetailReadmorePlace(name: place!.getName())
            }
            tableComment.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: size.width, height: 0)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Actions
    @IBAction func actionSend(_ sender: Any) {
        // Login only -> After logged in, user press LOVE again
        Utils.viewController(self, isSignUp: false, checkLoginWithCallback: {
            let text = self.tfComment.text
            if text ?? "" == "" {
                self.view.makeToast(Localized.commentEmpty)
                return
            }
            // send comment
            CommentService.shared.addComment(text!)
            // clear text
            self.tfComment.text = ""
            self.tfComment.resignFirstResponder()
        })
    }
    
    // MARK: - Notification Handler
    @objc func handlePlaceChanged(notification: Notification) {
        let p = notification.object as? FPlace
        if p == nil {
            return
        }
        place = p
        setupHeader()
    }

}

extension CommentViewController : UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table delegate & datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CommentService.shared.comments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let comment = CommentService.shared.comments[indexPath.row]
        let height = CommentCell.heightForComment(comment[FComment.text] as! String, categoryType: categoryType ?? .Sleep)
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.className, for: indexPath) as! CommentCell
        let comment = CommentService.shared.comments[indexPath.row]
        cell.fill(comment: comment, categoryType: categoryType, isLastCell: indexPath.row == CommentService.shared.comments.count - 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension CommentViewController : CommentServiceProtocol {
    func commentServiceAdded(_ comment: FComment) {
        // reload table => comment mới nhất sẽ đưa lên đầu
        tableComment.beginUpdates()
        let indexpath = IndexPath(row: 0, section: 0)
        tableComment.insertRows(at: [indexpath], with: .fade)
        tableComment.endUpdates()
        // Nếu là comment của mình thì scroll đến nó -> scroll to it
        if AppState.currentUser != nil && (comment[FComment.senderId] as! String) == (AppState.currentUser?[FUser.userId] as! String){
            tableComment.scrollToRow(at: indexpath, at: .middle, animated: true)
        }
    }
}
