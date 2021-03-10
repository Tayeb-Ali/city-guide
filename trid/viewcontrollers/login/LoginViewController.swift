//
//  LoginViewController.swift
//  trid
//
//  Created by Black on 9/26/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import FBSDKLoginKit
import TTTAttributedLabel

class LoginViewController: UIViewController {
    
    // Background - Photo Slideshow
    @IBOutlet weak var slideshow: ImageSlideshow!

    // outlet
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    
    // view select mode
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    // email
    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var constraintViewLoginTop: NSLayoutConstraint!
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var labelChooseLoginMethod: UILabel!
    @IBOutlet weak var btnFacebook2: UIButton!
    @IBOutlet weak var segmentioEmailMethod: Segmentio!
    
    
    // email - sign up
    @IBOutlet weak var viewEmailSignUp: UIView!
    @IBOutlet weak var tfSignUpName: TridTextField!
    @IBOutlet weak var tfSignUpEmail: TridTextField!
    @IBOutlet weak var tfSignUpPass: TridTextField!
    @IBOutlet weak var tfSignUpRePass: TridTextField!
    // @IBOutlet weak var btnEmailSignUp: UIButton!
    @IBOutlet weak var btnEmailSignUp: TKTransitionSubmitButton!
    @IBOutlet weak var labelTermOfService: TTTAttributedLabel!
    
    // email - sign in
    @IBOutlet weak var viewEmailSignIn: UIView!
    @IBOutlet weak var tfSignInEmail: TridTextField!
    @IBOutlet weak var tfSignInPass: TridTextField!
    // @IBOutlet weak var btnEmailSignIn: UIButton!
    @IBOutlet weak var btnEmailSignIn: TKTransitionSubmitButton!
    @IBOutlet weak var btnEmailForgotPass: UIButton!
    
    // variables
    var isDisplaying = false
    var isSignUpMode = false
    var isModal = false
    var isSegmentio = false
    var isShowingLoginDetail = false
    
    // Call back
    var callback : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // background
        makeBackgroundSlideshow()
        
        // Info
        labelName.text = Localized.AppFullName
        makeSlogan(index: 0)
        
        // Slideshow lock direction
        slideshow.scrollView.isDirectionalLockEnabled = true
        
        // make button login
        let radius : CGFloat = btnFacebook.bounds.height/2
        // facebook
        self.btnFacebook?.layer.cornerRadius = radius
        self.btnFacebook2?.layer.cornerRadius = radius
        
        // Label term of service
        labelTermOfService.delegate = self
        let str : NSString = "By signing up, you agree to the Terms of Service and Privacy Policy"
        labelTermOfService.setText(str as String, afterInheritingLabelAttributesAndConfiguringWith: {mutableAttributes in
            mutableAttributes?.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(netHex: AppSetting.Color.gray), range: NSMakeRange(0, str.length))
            mutableAttributes?.addAttribute(NSAttributedString.Key.font, value: UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.normalSmall)!, range: NSMakeRange(0, str.length))
            return mutableAttributes
        })
        
        let attributes:[AnyHashable : Any] = [kCTUnderlineStyleAttributeName as AnyHashable : NSNumber(value: false),
                                              kCTForegroundColorAttributeName as AnyHashable : UIColor(netHex: AppSetting.Color.blue)]
        labelTermOfService.linkAttributes = attributes
        
        let activeAttributes:[AnyHashable : Any] = [kCTForegroundColorAttributeName as AnyHashable : UIColor(hex6: UInt32(AppSetting.Color.blue), alpha: 0.4)]
        labelTermOfService.activeLinkAttributes = activeAttributes
        
        let range1 : NSRange = str.range(of: "Terms of Service")
        labelTermOfService.addLink(to: URL(string: AppUrl.term), with: range1)
        let range2 : NSRange = str.range(of: "Privacy Policy")
        labelTermOfService.addLink(to: URL(string: AppUrl.privacy), with: range2)
        
        // Skip
        btnSkip.setTitle(isModal ? Localized.Cancel : Localized.skip, for: .normal)
        
        // EMAIL MODE
        makeUIEmailMode()
        openLoginDetail(isOpen: isModal || isShowingLoginDetail, animated: false)
        
        // register notification
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.handleSignedIn), name: NotificationKey.signedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.handleSignInError), name: NotificationKey.signInError, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isDisplaying = true
        // enable all button
        makeAllButtonEnabled(true)
        // clear sign up form
        clearSignUpForm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isSegmentio = false
        if !isSegmentio {
            setupSegmentioView()
        }
        // page control frame
        slideshow.pageControlPosition = .userCustom
        let y = viewInfo.frame.origin.y + labelDescription.frame.origin.y + labelDescription.frame.size.height + 20
        slideshow.pageControlFrameCustom = CGRect(x: 38, y: y, width: 54, height: 10)
        
        // check online status
//        if !TridService.shared.isOnline {
//            self.view.makeToast(Localized.YouAreOffline)
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        // Config button
        btnEmailSignIn.size = btnEmailSignIn.bounds.size
        btnEmailSignUp.size = btnEmailSignUp.bounds.size
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupSegmentioView() {
        let segments = [SegmentioItem(title: "LOGIN", image: UIImage(named: "")),
                        SegmentioItem(title: "SIGN UP", image: UIImage(named: ""))]
        let options = segmentioEmailMethod.segmentioOptions(background: UIColor.clear,
                                                maxVisibleItems: 2,
                                                font: UIFont(name: AppSetting.Font.roboto_medium, size: AppSetting.FontSize.big)!,
                                                textColor: UIColor(netHex: AppSetting.Color.gray),
                                                textColorSelected: UIColor(netHex: AppSetting.Color.blue),
                                                verticalColor: UIColor.clear,
                                                horizontalColor: UIColor(netHex: AppSetting.Color.veryLightGray),
                                                isFlexibleWidth: false,
                                                indicatorColor: UIColor(netHex: AppSetting.Color.blue),
                                                indicatorHeight: 2,
                                                indicatorOverSeperator: true)
        segmentioEmailMethod.setup(
            content: segments,
            style: SegmentioStyle.onlyLabel,
            options: options
        )
        segmentioEmailMethod.valueDidChange = { [weak self] _, segmentIndex in
            // Change tab - Login = 0 | Sign Up = 1
            self?.changeEmailMode(isSignUp: segmentIndex == 1)
        }
        segmentioEmailMethod.selectedSegmentioIndex = isSignUpMode ? 1 : 0
        isSegmentio = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - UI
    
    // Photo slideshow
    func makeSlogan(index: Int){
        switch index % 3 {
        case 1:
            labelDescription.text = Localized.AppSlogan2
            break
        case 2:
            labelDescription.text = Localized.AppSlogan3
            break
        default:
            labelDescription.text = Localized.AppSlogan1
        }
    }
    
    func makeBackgroundSlideshow() {
        slideshow.backgroundColor = UIColor.clear
        slideshow.slideshowInterval = 2.0 // 31/08/17 request change from Mr.Tho
        slideshow.pageControlPosition = PageControlPosition.insideScrollView
        slideshow.contentScaleMode = UIView.ContentMode.scaleAspectFill
        // source
        let photos = ["app-bg-1", "app-bg-2", "app-bg-3"]
        let source : Array<InputSource> = [ImageSource(image: UIImage(named: photos[0])!),
                                           ImageSource(image: UIImage(named: photos[1])!),
                                           ImageSource(image: UIImage(named: photos[2])!)]
        slideshow.setImageInputs(source)
        slideshow.currentPageChanged = {page in
            self.makeSlogan(index: page)
        }
    }
    
    func makeUIEmailMode(){
        // top
        changeEmailMode(isSignUp: isSignUpMode)
        // sign in
        tfSignInEmail.makeIcon(name: "icon-email")
        tfSignInPass.makeIcon(name: "icon-password")
        btnEmailSignIn.setTitle(Localized.signIn, for: UIControl.State.normal)
        btnEmailForgotPass.setTitle(Localized.forgotPassword, for: UIControl.State.normal)
        btnEmailSignIn.normalCornerRadius = btnEmailSignIn.bounds.height/2
        // sign up
        tfSignUpName.makeIcon(name: "icon-username")
        tfSignUpEmail.makeIcon(name: "icon-email")
        tfSignUpPass.makeIcon(name: "icon-password")
        tfSignUpRePass.makeIcon(name: "icon-password")
        btnEmailSignUp.setTitle(Localized.signUp, for: UIControl.State.normal)
        btnEmailSignUp.normalCornerRadius = btnEmailSignUp.bounds.height/2
    }
    
    func changeEmailMode(isSignUp: Bool) {
        isSignUpMode = isSignUp
        if isSegmentio {
            segmentioEmailMethod.selectedSegmentioIndex = isSignUpMode ? 1 : 0
        }
        // content
        viewEmailSignIn.isHidden = isSignUp
        viewEmailSignUp.isHidden = !isSignUp
    }
    
    func openLoginDetail(isOpen: Bool, animated: Bool = false){
        let height = AppSetting.App.screenSize.height
        isShowingLoginDetail = isOpen
        if !animated {
            constraintViewLoginTop.constant = isOpen ? 0 : height
        }
        else{
            constraintViewLoginTop.constant = isOpen ? height : 0
            UIView.animate(withDuration: 0.25, delay: 0, options:(isOpen ? .curveLinear : .curveEaseOut), animations: {
//            UIView.animate(withDuration: 0.2, animations: {
                self.constraintViewLoginTop.constant = isOpen ? 0 : height
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func makeAllButtonEnabled(_ enabled: Bool){
        self.btnFacebook.isEnabled = enabled
        self.btnFacebook2.isEnabled = enabled
        self.btnSkip.isEnabled = enabled
    }
    
    func letgo(_ animate: Bool = true){
        self.makeAllButtonEnabled(true)
        self.isDisplaying = false
        if isModal {
            dismissModal()
        }
        else{
            // Normal case. Login at first page
            let main = MainViewController()
            self.navigationController?.pushViewController(main, animated: animate)
        }
    }
    
    func clearSignUpForm(){
        // clear sign up
        tfSignUpName.text = ""
        tfSignUpEmail.text = ""
        tfSignUpPass.text = ""
        tfSignUpRePass.text = ""
    }
    
    func clearSignInForm(){
        // clear sign in
        // tfSignInEmail.text = ""
        tfSignInPass.text = ""
    }
    
    // MARK: - Actions
    @IBAction func actionSkip(_ sender: AnyObject) {
        makeAllButtonEnabled(false)
        letgo()
    }
    
    //    @IBAction func actionSignInWithGoogle(_ sender: Any) {
    //        makeAllButtonEnabled(false)
    //        GIDSignIn.sharedInstance().signIn()
    //        AppLoading.showLoading()
    //    }
    
    @IBAction func actionSignInWithFacebook(_ sender: Any) {
        makeAllButtonEnabled(false)
        let manager = LoginManager()
        manager.logOut()
        manager.logIn(permissions: ["email"], from: self, handler: {(result: LoginManagerLoginResult?, error: Error?) in
            if error != nil || result == nil{
                self.handleSignInError(notification: Notification(name: NotificationKey.signInError, object: error))
            }
            else if result!.isCancelled {
                // do nothing
            }
            else if !(result!.grantedPermissions.contains("email")) {
                self.view.makeToast("Please provide your email address", duration: 4, position: .center)
            }
            else if result!.token != nil, let tokenString = AccessToken.current?.tokenString {
                print("Logged in")
                let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
                Global.appDelegate.firebaseLoginWith(credential: credential, info: SignInInfo.makeFacebook(accessToken: tokenString))
            }
            else {
                self.view.makeToast(Localized.SomethingWrong)
            }
        })
    }
    
    @IBAction func actionEmailSignUp(_ sender: Any) {
        let name = tfSignUpName.text
        let email = tfSignUpEmail.text
        let password = tfSignUpPass.text
        let rePassword = tfSignUpRePass.text
        // check
        if name == nil || name == "" {
            self.view.makeToast(Localized.nameEmpty)
        }
        else if email == nil || email == "" {
            self.view.makeToast(Localized.emailEmpty)
        }
        else if !(email?.isValidEmail())! {
            self.view.makeToast(Localized.emailInvalid)
        }
        else if password == nil || password == "" {
            self.view.makeToast(Localized.passwordEmpty)
        }
        else if password != rePassword {
            self.view.makeToast(Localized.passwordDontMatch)
        }
        else {
            // AppLoading.showLoading()
            btnEmailSignUp.startLoadingAnimation()
            // request create user
            Auth.auth().createUser(withEmail: email!, password: password!) { (result, error) in
                if let user = result?.user {
                    // set display name
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = name
                    changeRequest.commitChanges(){ (error2) in
                        if let error2 = error2 {
                            self.view.makeToast(error2.localizedDescription)
                            AppLoading.hideLoading()
                            self.btnEmailSignUp.stopAnimation()
                            return
                        }
                        // save user to DB
                        let fu = FUser.userWith(firUser: user, loginProvider: EmailAuthProviderID)
                        fu.saveInBackground({er3 in
                            if er3 == nil {
                                // Sign in & Save sign method
                                self.signInWithUser(fu, credential: SignInInfo.makeEmail(email!, password: password!))
                            }
                            else{
                                self.handleSignInError(notification: Notification(name: NotificationKey.signInError, object: er3, userInfo: nil))
                            }
                        })
                    }
                }
                else {
                    self.view.makeToast(error?.localizedDescription ?? Localized.SomethingWrong)
                    AppLoading.hideLoading()
                    self.btnEmailSignUp.stopAnimation()
                    return
                }
            }
        }
    }
    
    @IBAction func actionEmailSignIn(_ sender: Any) {
        let email = tfSignInEmail.text
        let password = tfSignInPass.text
        // check
        if email == nil || email == "" {
            self.view.makeToast(Localized.emailEmpty)
        }
        else if !(email?.isValidEmail())! {
            self.view.makeToast(Localized.emailInvalid)
        }
        else if password == nil || password == "" {
            self.view.makeToast(Localized.passwordEmpty)
        }
        else {
            // AppLoading.showLoading()
            btnEmailSignIn.startLoadingAnimation()
            // sign in
            Auth.auth().signIn(withEmail: email!, password: password!, completion: {(result, error) in
                if let result = result {
                    // Sign in & Save sign in method
                    let fu = FUser.userWith(firUser: result.user, loginProvider: EmailAuthProviderID)
                    fu.fetchInBackground(finish: {e in
                        if e == nil && fu.snapshot != nil {
                            self.signInWithUser(fu, credential: SignInInfo.makeEmail(email!, password: password!))
                            // done
                            self.clearSignInForm()
                            return
                        }
                        else{
                            // Error
                            self.view.makeToast(Localized.SomethingWrong)
                            self.btnEmailSignIn.stopAnimation()
                            AppLoading.hideLoading()
                            return
                        }
                    })
                }
                else {
                    self.view.makeToast(error?.localizedDescription ?? "")
                    AppLoading.hideLoading()
                    self.btnEmailSignIn.stopAnimation()
                    return
                }
            })
        }
    }
    
    @IBAction func actionEmailForgotPass(_ sender: Any) {
        let popup = PopupForgotPassword.create()
        popup.sendEvent = {mail in
            // Send event reload
            AppLoading.showLoading()
            Auth.auth().sendPasswordReset(withEmail: mail) { (error) in
                AppLoading.hideLoading()
                if error != nil && error?.localizedDescription != nil {
                    self.view.makeToast((error?.localizedDescription)!)
                }
                else {
                    // done
                    AppLoading.showSuccess()
                }
            }
        }
        popup.show()
    }
    
    @IBAction func actionCloseEmailMode(_ sender: Any) {
        if isModal {
            dismissModal()
        }
        else{
            openLoginDetail(isOpen: false, animated: true)
        }
    }
    
    @IBAction func actionChangeEmailSignMode(_ sender: Any) {
        changeEmailMode(isSignUp: !isSignUpMode)
    }
    
    @IBAction func actionOpenLogin(_ sender: Any) {
        changeEmailMode(isSignUp: false)
        openLoginDetail(isOpen: true, animated: true)
    }
    
    @IBAction func actionOpenSignUp(_ sender: Any) {
        changeEmailMode(isSignUp: true)
        openLoginDetail(isOpen: true, animated: true)
    }
    
    // MARK: - FIREBASE action
    func signInWithUser(_ user: FUser, credential: SignInInfo){
        // Check user info: inactive, uncommentable, ...
        Utils.signInWith(user: user, signinInfo: credential)
    }
    
    
    // MARK: - HANDLE Notifications
    @objc func handleSignedIn(notification: Notification){
        if !isDisplaying {
            return
        }
        self.btnEmailSignIn.stopAnimation()
        self.btnEmailSignUp.stopAnimation()
        // save credential
        let info = notification.object as! SignInInfo
        AppState.setSignInInfo(info)
        // go
        letgo()
    }
    
    @objc func handleSignInError(notification: Notification){
        if self.btnEmailSignUp.isAnimating {
            self.btnEmailSignUp.stopAnimation()
        }
        if self.btnEmailSignIn.isAnimating {
            self.btnEmailSignIn.stopAnimation()
        }
        let error = notification.object as? Error
        let message = error == nil ? "" : error?.localizedDescription
        handleSignInErrorWithMessage(message!)
    }
    
    func handleSignInErrorWithMessage(_ message: String) {
        if !isDisplaying {
            return
        }
        // hide loading
        AppLoading.hideLoading()
        makeAllButtonEnabled(true)
        // show error message
        if message != "" {
            self.view.makeToast(message)
        }
    }
    
    func dismissModal() {
        if isModal {
            // Login as Modal present
            self.dismiss(animated: true, completion: {
                if self.callback != nil {
                    self.callback?()
                }
            })
        }
    }
    
}

//extension LoginViewController : GIDSignInUIDelegate {
//    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
//        // hide loading
//        AppLoading.hideLoading()
//    }
//}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LoginViewController : TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        var title = Localized.privacy
        if url.absoluteString.contains("term") {
            title = "Terms of Service"
        }
        Utils.openWeb(url: url.absoluteString, title: title, controller: self, navigation: self.navigationController)
    }
}
