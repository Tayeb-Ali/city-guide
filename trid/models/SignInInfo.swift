//
//  SignInInfo.swift
//  trid
//
//  Created by Black on 12/5/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInInfo: NSObject, NSCoding {    
    // property
    var provider : String!
    // mail
    var mail : String?
    var pass : Data?
    // facebook
    var fbAccessToken: String?
    // google
    var googleIdToken : String?
    var googleAccessToken: String?
    
    func encode(with aCoder: NSCoder){
        //aCoder.encodeInteger(words.count, forKey: countKey)
        aCoder.encode(provider, forKey: "provider")
        aCoder.encode(mail, forKey: "mail")
        aCoder.encode(pass, forKey: "pass")
        aCoder.encode(fbAccessToken, forKey: "fbAccessToken")
        aCoder.encode(googleIdToken, forKey: "googleIdToken")
        aCoder.encode(googleAccessToken, forKey: "googleAccessToken")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        provider = aDecoder.decodeObject(forKey: "provider") as? String
        mail = aDecoder.decodeObject(forKey: "mail") as? String
        pass = aDecoder.decodeObject(forKey: "pass") as? Data
        fbAccessToken = aDecoder.decodeObject(forKey: "fbAccessToken") as? String
        googleIdToken = aDecoder.decodeObject(forKey: "googleIdToken") as? String
        googleAccessToken = aDecoder.decodeObject(forKey: "googleAccessToken") as? String
    }
    
    override init() {
        super.init()
        provider = ""
    }
    
    class func makeEmail(_ email: String, password: String) -> SignInInfo{
        let info = SignInInfo()
        info.provider = EmailAuthProviderID
        info.mail = email
        info.pass = NSKeyedArchiver.archivedData(withRootObject: password)
        return info
    }
    
    class func makeFacebook(accessToken: String) -> SignInInfo {
        let info = SignInInfo()
        info.provider = FacebookAuthProviderID
        info.fbAccessToken = accessToken
        return info
    }
    
    class func makeGoogle(idToken: String, accessToken: String) -> SignInInfo {
        let info = SignInInfo()
        info.provider = GoogleAuthProviderID
        info.googleIdToken = idToken
        info.googleAccessToken = accessToken
        return info
    }
    
    func credential() -> AuthCredential?{
        if provider == EmailAuthProviderID && mail != nil && pass != nil{
            let p = NSKeyedUnarchiver.unarchiveObject(with: pass!) as? String
            return EmailAuthProvider.credential(withEmail: mail!, password: p!)
        }
        else if provider == FacebookAuthProviderID && fbAccessToken != nil{
            return FacebookAuthProvider.credential(withAccessToken: fbAccessToken!)
        }
        else if provider == GoogleAuthProviderID && googleIdToken != nil && googleAccessToken != nil {
            return GoogleAuthProvider.credential(withIDToken: googleIdToken!, accessToken: googleAccessToken!)
        }
        return nil
    }

}
