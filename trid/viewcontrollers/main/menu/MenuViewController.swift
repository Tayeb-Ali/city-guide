//
//  MenuViewController
//  trid
//
//  Created by Black on 9/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import SDWebImage
import PureLayout
import FirebaseAuth
import MessageUI

enum MenuType : Int {
    case allCities = 0
    case bookTicket = 1
    case myPlan = 2
    case myPost = 3
    case favorite = 4
    case profile = 5
    case aboutApp = 6
    case privacy = 7
    case feedback = 8
    case reviewApp = 9
    case setting = 10
    case logOut = 11
    case visaOnline = 12
}

protocol MenuViewControllerDelegate {
    func menuPopToSignIn()
    func menuPopToSignUp()
}

class MenuViewController: UIViewController {
    
    // Outlet
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var viewNotSigned: UIView!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var constraintMenuTrailing: NSLayoutConstraint!
    @IBOutlet weak var tableMenu: UITableView!
    @IBOutlet weak var labelVersion: UILabel!
    
    var delegate : MenuViewControllerDelegate?
    
    // values ==> Tạm thời disable section 1
    let menuSections = ["", Localized.information,
                        "", Localized.aboutApp]
    let menuTitles = [Int(0): [MenuType.allCities,
                               MenuType.bookTicket,
                                MenuType.visaOnline],
                      Int(1): [MenuType.aboutApp,
                               MenuType.privacy,
                               MenuType.feedback,
                               MenuType.reviewApp,
                               // MenuType.setting,
                               MenuType.logOut]]
    
    let menuNotSignedTitles = [Int(0): [MenuType.allCities,
                                        MenuType.bookTicket,
                                        MenuType.visaOnline],
                               Int(1): [MenuType.aboutApp,
                                        MenuType.privacy,
                                        MenuType.feedback,
                                        MenuType.reviewApp
                                        /*MenuType.setting*/]]
    
    let titles = [MenuType.allCities: Localized.AllCities.uppercased(),
                  MenuType.bookTicket: Localized.BookTicket.uppercased(),
                  MenuType.visaOnline: Localized.VisaOnline.uppercased(),
                  MenuType.myPlan: Localized.myPlan,
                  MenuType.myPost: Localized.myPost,
                  MenuType.favorite: Localized.favorite,
                  MenuType.profile: Localized.profile,
                  MenuType.aboutApp: Localized.aboutApp,
                  MenuType.privacy: Localized.privacy,
                  MenuType.feedback: Localized.feedback,
                  MenuType.reviewApp: Localized.reviewApp,
                  MenuType.setting: Localized.setting,
                  MenuType.logOut: Localized.logOut]
    
    let icons = [MenuType.allCities: "menu-allcities",
                 MenuType.bookTicket: "menu-tickets",
                 MenuType.visaOnline: "menu-passport",
                 MenuType.myPlan: "menu-myplan",
                 MenuType.myPost: "menu-mypost",
                 MenuType.favorite: "menu-fav",
                 MenuType.profile: "menu-profile",
                 MenuType.aboutApp: "menu-about",
                 MenuType.privacy: "menu-privacy",
                 MenuType.feedback: "menu-feedback",
                 MenuType.reviewApp: "menu-review",
                 MenuType.setting: "menu-setting",
                 MenuType.logOut: "menu-profile"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(netHex: AppSetting.Color.settingblue)
        // remove header scrollview space
        self.automaticallyAdjustsScrollViewInsets = false
        // margin right
        constraintMenuTrailing.constant = AppSetting.App.screenSize.width/2 - CGFloat(MainViewController.offsetX) + 10.0
        tableMenu.register(UINib(nibName: MenuCell.className, bundle: nil), forCellReuseIdentifier: MenuCell.className)
        if tableMenu.tableHeaderView != nil {
            tableMenu.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: tableMenu.bounds.width, height: 80)
            tableMenu.tableHeaderView?.backgroundColor = .clear
        }
        tableMenu.backgroundColor = .clear
        
        // Header
        imgAvatar.layer.cornerRadius = imgAvatar.bounds.height/2
        imgAvatar.clipsToBounds = true
        imgAvatar.layer.shadowColor = UIColor.gray.cgColor
        imgAvatar.layer.shadowRadius = 2
        imgAvatar.layer.shadowOpacity = 0.6
        
        btnSignIn.layer.borderColor = UIColor.white.cgColor
        btnSignIn.layer.borderWidth = 1
        btnSignIn.layer.cornerRadius = btnSignIn.bounds.height/2
        btnSignIn.clipsToBounds = true
        btnSignIn.setTitle(Localized.signIn, for: UIControl.State.normal)
        btnSignUp.layer.borderColor = UIColor.white.cgColor
        btnSignUp.layer.borderWidth = 1
        btnSignUp.layer.cornerRadius = btnSignIn.bounds.height/2
        btnSignUp.clipsToBounds = true
        btnSignUp.setTitle(Localized.signUp, for: UIControl.State.normal)
        
        // User Info
        handleSigned(out: AppState.currentUser == nil)
        
        // App Version
        labelVersion.text = Localized.Version + " " + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
        
        // Register Notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserSignedIn), name: NotificationKey.signedIn, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - HANDLE Notification
    @objc func handleUserSignedIn(notification: Notification) {
        handleSigned(out: false)
    }
    
    // MARK: - UI
    func handleSigned(out: Bool){
        imgAvatar.isHidden = out
        labelName.isHidden = out
        imgAvatar.image = nil
        labelName.text = ""
        
        viewNotSigned.isHidden = !out
        
        // info
        if !out{
            makeUserInfo()
        }
        // table menu
        tableMenu.reloadData()
    }
    
    func makeUserInfo() {
        let user = AppState.currentUser
        if user != nil {
            imgAvatar.sd_setImage(with: URL(string: user!.getAvatar()), placeholderImage: UIImage(named: "avatar-default"))
            labelName.text = user?.getName()
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
    @IBAction func actionOpenSignIn(_ sender: Any) {
        if delegate?.menuPopToSignIn != nil {
            delegate?.menuPopToSignIn()
        }
    }
    
    @IBAction func actionOpenSignUp(_ sender: Any) {
        if delegate?.menuPopToSignUp != nil {
            delegate?.menuPopToSignUp()
        }
    }
    
    func actionFeedback(){
        Global.sendFeedback(controller: self)
    }
    
    func actionRateApp(){
        Global.openRateApp()
    }
    
    func actionOpenAbout(){
        let url = AppUrl.website
        openWeb(url: url, title: Localized.aboutApp)
    }
    
    func actionOpenPrivacy(){
        let url = AppUrl.privacy
        openWeb(url: url, title: Localized.privacy)
    }
    
    func openWeb(url: String, title: String){
        Utils.openWeb(url: url, title: title, controller: self, navigation: self.navigationController)
    }
    
    func actionAllCities() {
        
    }
    
    func actionBookTicket(){
    }
}

// MARK: - Table delegate
extension MenuViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let header = menuSections[section]
        if header == "" {
            return 20.0
        }
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let height = self.tableView(tableView, heightForHeaderInSection: section)
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: height))
        header.backgroundColor = .clear
        // add separator line
        let sep = UIImageView(frame: CGRect(x: 0, y: 9, width: tableView.bounds.width, height: 1))
        sep.backgroundColor = UIColor(netHex: 0x106AB0)
        sep.alpha = 0.4
        header.addSubview(sep)
        // add title
        let title = menuSections[section]
        if title != "" {
            let label = UILabel(frame: CGRect(x: 0, y: height - 20 - 10, width: tableView.bounds.width, height: 20))
            label.backgroundColor = .clear
            label.alpha = 0.6
            label.textColor = .white
            label.font = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.normal)
            label.text = title
            header.addSubview(label)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = (AppState.currentUser != nil) ? menuTitles[indexPath.section]?[indexPath.row] : menuNotSignedTitles[indexPath.section]?[indexPath.row]
        switch type! as MenuType{
        case .allCities:
            actionAllCities()
            break
        case .bookTicket:
            actionBookTicket()
            break
        case .visaOnline:
            Utils.openUrl(AppSetting.Visa.url)
            break
        case MenuType.myPlan:
            break
        case MenuType.myPost:
            break
        case MenuType.favorite:
            break
        case MenuType.profile:
            break
        case MenuType.aboutApp:
            actionOpenAbout()
            break
        case MenuType.privacy:
            actionOpenPrivacy()
            break
        case MenuType.feedback:
            actionFeedback()
            break
        case MenuType.reviewApp:
            actionRateApp()
            break
        case MenuType.setting:
            break
        case MenuType.logOut:
            // action logout
            debugPrint("LOG OUT")
            do{
                // signout
                try Auth.auth().signOut()
                // #set-current-user
                AppState.currentUser = nil
                // clear credential
                AppState.setSignInInfo(nil)
                // Notification
                NotificationCenter.default.post(name: NotificationKey.signedOut, object: nil)
                // ui
                handleSigned(out: true)
            }
            catch {
                self.view.makeToast(error.localizedDescription)
            }
            break
        }
    }
}

// MARK: - Table datasource
extension MenuViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int{
        return AppState.currentUser != nil ? menuTitles.keys.count : menuNotSignedTitles.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return AppState.currentUser != nil ? menuTitles[section]!.count : menuNotSignedTitles[section]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.className) as! MenuCell
        let type = AppState.currentUser != nil ? menuTitles[indexPath.section]?[indexPath.row] : menuNotSignedTitles[indexPath.section]?[indexPath.row]
        cell.fill(type: type!, icon: icons[type!]!, text: titles[type!]!, section: indexPath.section)
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - MFMailComposeViewController Delegate
//extension MenuViewController : MFMailComposeViewControllerDelegate {
//    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
//        // Check the result or perform other tasks.
//        // Dismiss the mail compose view controller.
//        controller.dismiss(animated: true, completion: nil)
//    }
//}
