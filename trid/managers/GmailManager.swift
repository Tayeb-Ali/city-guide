//
//  GmailManager.swift
//  trid
//
//  Created by Black on 2/11/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit
import Firebase
import GoogleAPIClientForREST
import GTMAppAuth
import AppAuth
import GTMSessionFetcher
import Toast_Swift

class GmailManager: NSObject {
    // static service
    fileprivate let kExampleAuthorizerKey = "Google Authorization"
    fileprivate let kKeychainItemName = "Gmail API"
    fileprivate let scopes = [OIDScopeProfile, OIDScopeEmail, kGTLRAuthScopeGmailCompose] // "https://www.googleapis.com/auth/userinfo.profile"
    fileprivate let kIssuer = "https://accounts.google.com"
    // kidchanel11@gmail.com
    fileprivate var kClientID = ""
    fileprivate var kRedirectURI = ""
    
    // shared
    static let shared = GmailManager()
    
    // variables
    var authorization : GTMAppAuthFetcherAuthorization?
    let service = GTLRGmailService()
    var rootVC : UIViewController?
    var email_ : String?
    var name_ : String?
    
    override init() {
        super.init()
        kClientID = (FirebaseApp.app()?.options.clientID)!
        kRedirectURI = "com.googleusercontent.apps." + kClientID.replacingOccurrences(of: ".apps.googleusercontent.com", with: "") + ":/oauthredirect"
    }
    
    func composeMailTo(email: String, name: String?, viewController: UIViewController!){
        rootVC = viewController
        email_ = email
        name_ = name
        loadState()
    }
    
    // send email
    func composeMail(email: String, name: String?){
        let vc = MailComposeViewController(nibName: "MailComposeViewController", bundle: nil)
        vc.email = email_
        vc.name = name_
        vc.callbackCancel = {
            self.rootVC?.dismiss(animated: true, completion: nil)
        }
        vc.callbackSend = {subject, content in
            self.sendEmail(email: email, name: name, subject: subject, content: content)
            self.rootVC?.dismiss(animated: true, completion: nil)
        }
        rootVC?.present(vc, animated: true, completion: nil)
    }
    
    func sendEmail(email: String, name: String?, subject s: String, content c: String) {
        let gtlMessage = GTLRGmail_Message()
        gtlMessage.raw = self.generateRawString(email: email, name: name, subject: s, content: c)
        let query = GTLRGmailQuery_UsersMessagesSend.query(withObject: gtlMessage, userId: (authorization?.userEmail)!, uploadParameters: nil)
        service.executeQuery(query, completionHandler: {(ticket, response, error) in
            debugPrint("ticket \(ticket)")
            debugPrint("response", response ?? "")
            debugPrint("error", error ?? "")
            if error == nil {
                self.rootVC?.view.makeToast(Localized.Sent, duration: 3, position: .center)
            }
            else {
                self.rootVC?.view.makeToast((error?.localizedDescription)!, duration: 3, position: .center)
            }
        })
    }
    
    func generateRawString(email: String, name: String?, subject: String, content: String) -> String {
        let dateFormatter = Utils.Formatter.date
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"; //RFC2822-Format
        let todayString:String = dateFormatter.string(from: Date())
        let rawMessage = "" +
            "Date: \(todayString)\r\n" +
            "From: \((authorization?.userEmail)!)\r\n" +
            (name != nil ? "To: \(name ?? "") <\(email)>\r\n" : "To: \"\" <\(email)>\r\n") +
            "Subject: \(AppSetting.App.name) \(subject) \r\n\r\n" +
        "\(content)"
        return GTLREncodeWebSafeBase64(rawMessage.data(using: String.Encoding.utf8))!
    }
}

extension GmailManager {
    func saveState(auth: GTMAppAuthFetcherAuthorization?) {
        if auth != nil && ((auth?.canAuthorize) != nil) {
            GTMAppAuthFetcherAuthorization.save(auth!, toKeychainForName: kExampleAuthorizerKey)
        }
        else {
            GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: kExampleAuthorizerKey)
        }
    }
    
    func loadState() {
        if email_ == nil {
            return
        }
        let auth = GTMAppAuthFetcherAuthorization(fromKeychainForName: kExampleAuthorizerKey)
        if auth != nil && (auth?.canAuthorize())! {
            handleAuthorizationChanged(auth: auth)
        }
        else{
            authWithAutoCodeExchange()
        }
    }
    
    func handleAuthorizationChanged(auth: GTMAppAuthFetcherAuthorization?){
        authorization = auth
        saveState(auth: auth)
        if authorization != nil && (authorization?.canAuthorize())!{
            // state changed -> next step
            service.authorizer = authorization
            composeMail(email: email_!, name: name_)
        }
    }
    
    func authWithAutoCodeExchange(){
        let issuer = URL(string: kIssuer)
        let redirectURI = URL(string: kRedirectURI)
        
        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer!, completion: {configuration,error in
            if configuration == nil {
                self.handleAuthorizationChanged(auth: nil)
                return
            }
            // builds authentication request
            let request = OIDAuthorizationRequest(configuration: configuration!,
                                                  clientId: self.kClientID,
                                                  scopes: self.scopes,
                                                  redirectURL: redirectURI!,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: nil)
            // performs authentication request
            Global.appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request,
                                                                                 presenting: self.rootVC!,
                                                                                 callback: {authState, error in
                                                                                    if authState != nil {
                                                                                        let auth = GTMAppAuthFetcherAuthorization(authState: authState!)
                                                                                        self.handleAuthorizationChanged(auth: auth)
                                                                                    }
                                                                                    else {
                                                                                        self.handleAuthorizationChanged(auth: nil)
                                                                                    }
            })
            
        })
    }
}

extension GmailManager : OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    // OIDAuthStateChangeDelegate
    func didChange(_ state: OIDAuthState) {
        // do nothing
    }
    
    // OIDAuthStateErrorDelegate
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error){
        if rootVC != nil {
            rootVC?.view.makeToast(error.localizedDescription)
        }
    }
    
}
