//
//  FPlace.swift
//  trid
//
//  Created by Black on 12/22/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase

class FPlace: FObject {
    // KEY -----------------------------------------------------
    // info
    static let name = "name"
    static let address = "address"
    static let description_ = "description"
    static let photos = "photos"
    static let categories = "categories"
    static let email = "email"
    static let facebook = "facebook"
    static let facilities = "facilities"
    static let fromprice = "fromprice"
    static let toprice = "toprice"
    static let openingday = "openingday"
    static let openingtime = "openingtime"
    static let paidFacilities = "paidFacilities"
    static let phonenumber = "phonenumber"
    static let subcategories = "subcategories"
    static let thingstonote = "thingstonote"
    static let website = "website"
    // location
    static let longitude = "longitude"
    static let latitude = "latitude"
    // for hotel
    static let starlevel = "starlevel"
    static let checkin = "checkin"
    static let checkout = "checkout"
    static let sleepBookingUrl = "sleepBookingUrl"
    static let sleepAirbnbUrl = "sleepAirbnbUrl"
    static let sleepHostelWorldUrl = "sleepHostelWorldUrl"
    
    // status
    static let deactived = "deactived"
    static let commentCount = "commentCount"
    static let loved = "loved"
    static let priority = "priority"
    
    // Tour Only
    static let tourLocation = "tourLocation"
    static let tourDuration = "tourDuration"
    static let tourLanguage = "tourLanguage"
    static let tourTranspotation = "tourTranspotation"
    static let tourGroupSize = "tourGroupSize"
    static let tourBookingUrl = "tourBookingUrl"
    
    // KEY -----------------------------------------------------
    
    // Banner info
    func isBanner() -> Bool {
        return self["isBanner"] as? Bool ?? false
    }
    
    func getWebsite() -> String? {
        return self[FPlace.website] as? String
    }
    
    // MARK: - Get Hotel info
    func getSleepBookingUrl() -> String? {
        var url = self[FPlace.sleepBookingUrl] as? String
        if url != nil {
            if url!.contains("?") && url!.contains("=") {
                url = url! + "&\(AppSetting.booking_com_id)"
            }
            else{
                url = url! + "?\(AppSetting.booking_com_id)"
            }
        }
        return url
    }
    
    func getSleepHostelWorldUrl() -> String? {
        return self[FPlace.sleepHostelWorldUrl] as? String
    }
    
    func getSleepAirbnbUrl() -> String? {
        return self[FPlace.sleepAirbnbUrl] as? String
    }
    
    // MARK: - Get Tour info
    func getTourBookingUrl() -> String? {
        return self[FPlace.tourBookingUrl] as? String
    }
    
    // MARK: - TIP
    class func tipWithContent(_ text: String) -> FPlace? {
        let user = AppState.currentUser //[FUser.userId]!
        let tipKey = CategoryService.shared.getCategoryKeyForType(.Tips)
        if user == nil || tipKey == nil {
            return nil
        }
        let tip = FPlace(path: PlaceService.shared.subpath)
        tip.snapshot = nil
        /* Email ~ UserId */
        /* Description ~ Text */
        let length = min(30, text.count)
        tip.dictionary = [FPlace.name: (text as NSString).substring(to: length),
                          FPlace.email: user!.getEmail(),
                          FPlace.description_: text,
                          FPlace.commentCount: 0,
                          FPlace.loved : "",
                          FPlace.categories : [tipKey!],
                          FPlace.subcategories : [FSubcategory.TipUser]]
        return tip
    }
    
    func getTipEmail() -> String? {
        return self[FPlace.email] as? String
    }
    
    func getTipName() -> String? {
        return self[FPlace.name] as? String
    }
    
    func getTipContent() -> String? {
        return self[FPlace.description_] as? String
    }
    
    func getCommentCount() -> Int {
        return self[FPlace.commentCount] as? Int ?? 0
    }
    
    // MARK: - GET
    func getName() -> String {
        return self[FPlace.name] as? String ?? ""
    }
    
    func getAddress() -> String {
        return self[FPlace.address] as? String ?? ""
    }
    
    func getLatitude() -> Double {
        let lat = self[FPlace.longitude] as? NSString
        return lat != nil ? lat!.doubleValue : 0
    }
    
    func getLongitute() -> Double {
        let long = self[FPlace.latitude] as? NSString
        return long != nil ? long!.doubleValue : 0
    }
    
    func getCoordinate() -> String {
        let long = self[FPlace.longitude] as? String ?? ""
        let lat = self[FPlace.latitude] as? String ?? ""
        return long + "-" + lat
    }
    
    func getCategories() -> [String] {
        return self[FPlace.categories] as? [String] ?? [String]()
    }
    
    func getSubCategories() -> [String] {
        return self[FPlace.subcategories] as? [String] ?? []
    }
    
    func getFromPrice(categoryType: FCategoryType) -> Float {
        if categoryType == .SeeAndDo {
            return getFromPriceSeeAndDo()
        }
        let p = self[FPlace.fromprice] as? String
        if p != nil {
            return NSString(string: p!).floatValue
        }
        if self[FPlace.toprice] != nil {
            return getToPrice(categoryType: categoryType)
        }
        return MAXFLOAT
    }
    
    func getToPrice(categoryType: FCategoryType) -> Float {
        if categoryType == .SeeAndDo {
            return getToPriceSeeAndDo()
        }
        let p = self[FPlace.toprice] as? String
        if p != nil {
            return NSString(string: p!).floatValue
        }
        if self[FPlace.fromprice] != nil {
            return getFromPrice(categoryType: categoryType)
        }
        return 0
    }
    
    func getFromPriceSeeAndDo() -> Float {
        var p = self[FPlace.fromprice] as? String
        if p != nil {
            p = p!.replacingOccurrences(of: "đ", with: "")
            p = p!.replacingOccurrences(of: ",", with: "")
            return NSString(string: p!).floatValue
        }
        if self[FPlace.toprice] != nil {
            return getToPriceSeeAndDo()
        }
        return MAXFLOAT
    }
    
    func getToPriceSeeAndDo() -> Float {
        var p = self[FPlace.toprice] as? String
        if p != nil {
            p = p!.replacingOccurrences(of: "đ", with: "")
            p = p!.replacingOccurrences(of: ",", with: "")
            return NSString(string: p!).floatValue
        }
        if self[FPlace.fromprice] != nil {
            return getFromPriceSeeAndDo()
        }
        return 0
    }
    
    func getPriceString(categoryType type: FCategoryType?, short: Bool = false) -> String {
        var price = ""
        // Không cần display symbol cho See&Do
        let symbol = type != FCategoryType.SeeAndDo ? CountryService.shared.currentCountry.getDisplayCurrencySymbol() : ""
        var isOnlyFree = false
        // to
        let to = self[FPlace.toprice] as? String
        var toString = ""
        if to != nil {
            if to == Localized.plus {
                toString = to!
            }
            else if to != "" {
                toString = symbol + to!
            }
        }
        // from
        let from = self[FPlace.fromprice] as? String
        if from != nil {
            let a = NSString(string: from!).floatValue
            if a == 0 && toString == "" {
                isOnlyFree = true
                price = Localized.free
            }
            else{
                let link = (toString == "" || toString == Localized.plus) ? "" : "-"
                price = symbol + from! + link + toString
            }
        }
        
        // unit
        if type != nil && price != "" {
            let cat = AppState.getCategory(forType: type!)
            if cat != nil && !isOnlyFree && !short {
                price += cat!.getPriceUnit()
            }
        }
        return price
    }
    
    func getOpeningTime() -> String? {
        return self[FPlace.openingtime] as? String
    }
    
    func getPriority() -> Int {
        let p = self[FPlace.priority]
        if p != nil {
            if p is NSNumber {
                return (p as! NSNumber).intValue
            }
            if p is Int {
                return p as! Int
            }
            if p is String || p is NSString{
                return (p as! NSString).integerValue
            }
        }
        return  0
    }
    
    // Tour
    func getTourLocation() -> String {
        return self[FPlace.tourLocation] as? String ?? ""
    }
    
    func getTourDuration() -> String {
        return self[FPlace.tourDuration] as? String ?? ""
    }
    
    func getTourLanguage() -> String {
        return self[FPlace.tourLanguage] as? String ?? ""
    }
    
    func getTourTranspotation() -> String {
        return self[FPlace.tourTranspotation] as? String ?? ""
    }
    
    func getTourGroupSize() -> String {
        return self[FPlace.tourGroupSize] as? String ?? ""
    }
    
    // MARK: - Update place
    func retainCommentCount(){
        let count : Int = self.getCommentCount()
        self[FPlace.commentCount] = count + 1
    }
    
    // MARK: - Checking
    func isInCurrentCategory() -> Bool {
        let cats = self[FPlace.categories] as? [String]
        if cats == nil {
            return false
        }
        return AppState.shared.currentCategory != nil && cats!.contains((AppState.shared.currentCategory?.objectId)!)
    }
    
    func isDeactived() -> Bool {
        return self[FPlace.deactived] as? Bool ?? false
    }
    
    
    // MARK: - Convert tool
    func getTextPrice() -> NSAttributedString {
        let fromprice = self[FPlace.fromprice] as? String
        let toprice = self[FPlace.toprice] as? String
        // price
        let price = NSMutableAttributedString()
        // attributes
        let prefixAttributes = [NSAttributedString.Key.foregroundColor: UIColor(netHex: AppSetting.Color.lightGray), NSAttributedString.Key.font: UIFont(name: AppSetting.Font.roboto, size: 14)!]
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor(netHex: AppSetting.Color.black), NSAttributedString.Key.font: UIFont(name: AppSetting.Font.roboto_medium, size: 14)!]
        // create string
        var hasFrom = false
        if (fromprice != nil && fromprice != "") {
            hasFrom = true
            let prefixFrom = NSMutableAttributedString(string: "\(Localized.From) ", attributes: prefixAttributes)
            let from = NSMutableAttributedString(string: fromprice!, attributes: textAttributes)
            price.append(prefixFrom)
            price.append(from)
        }
        if (toprice != nil && toprice != ""){ // toprice != nil
            let prefixTo = NSMutableAttributedString(string: hasFrom ? " \(Localized.to) " : "\(Localized.To) ", attributes: prefixAttributes)
            let to = NSMutableAttributedString(string: toprice!, attributes: textAttributes)
            price.append(prefixTo)
            price.append(to)
        }
        return price
    }
    
    func getDescription_(full: Bool) -> NSAttributedString {
        let description = self[FPlace.description_] as? String
        if description ?? "" == "" {
            return NSAttributedString(string: "")
        }
        var pDescription : String = description!.trimmingCharacters(in: .whitespacesAndNewlines)
        pDescription = pDescription.replacingOccurrences(of: "\\n+", with: "\n", options: .regularExpression)
        // paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = AppSetting.Text.lineSpacing
        paragraphStyle.paragraphSpacing = AppSetting.Text.paragraphSpacing
        // style
        let size : CGFloat = full ? AppSetting.FontSize.big : AppSetting.FontSize.big
        let color = full ? UIColor(netHex: AppSetting.Color.gray) : UIColor(netHex: AppSetting.Color.gray)
        let textAttributes = [NSAttributedString.Key.foregroundColor: color,
                              NSAttributedString.Key.font: UIFont(name: AppSetting.Font.roboto, size: size)!,
                              NSAttributedString.Key.paragraphStyle: paragraphStyle]
        // Result
        let result = NSMutableAttributedString(string: pDescription, attributes: textAttributes)
        return result
    }
    
    // 9/2/17 New UI Design -> Seperate check in/out in other cell
    func getThingsToNoteNew(full: Bool) -> NSAttributedString {
        var thingstonote = self[FPlace.thingstonote] as? String
        if thingstonote ?? "" == "" {
            return NSAttributedString(string: "")
        }
        thingstonote = thingstonote!.trimmingCharacters(in: .whitespacesAndNewlines)
        thingstonote = thingstonote!.replacingOccurrences(of: "\\n+", with: "\n", options: .regularExpression)
        // Paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = AppSetting.Text.paragraphSpacing
        paragraphStyle.lineSpacing = AppSetting.Text.lineSpacing
        // Attribute
        let size = full ? AppSetting.FontSize.big : AppSetting.FontSize.big
        let color = full ? UIColor(netHex: AppSetting.Color.gray) : UIColor(netHex: AppSetting.Color.gray)
        let textAttributes = [NSAttributedString.Key.foregroundColor: color,
                              NSAttributedString.Key.font: UIFont(name: AppSetting.Font.roboto, size: size)!,
                              NSAttributedString.Key.paragraphStyle: paragraphStyle]
        // Text
        let things = NSMutableAttributedString(string: thingstonote!, attributes: textAttributes)
        return things
    }
    
    func getCheckin() -> String {
        return self[FPlace.checkin] as? String ?? ""
    }
    
    func getCheckout() -> String {
        return self[FPlace.checkout] as? String ?? ""
    }
    
    func getPaidFacility() -> [String] {
        var paids = self[FPlace.paidFacilities] as? String
        paids = (paids ?? "").trimmingCharacters(in: CharacterSet(charactersIn: "@ "))
        if paids == "" {
            return []
        }
        return paids?.components(separatedBy: "@") ?? []
    }
    
    func getLovedCount() -> Int {
        let loved = self[FPlace.loved] as? String ?? ""
        return loved.filter({$0 == "#"}).count
    }
    
    func checkLoved() -> Bool {
        let loved = self[FPlace.loved] as? String ?? ""
        if AppState.currentUser == nil {
            return false
        }
        let userId = AppState.currentUser?.getUserId()
        if userId == nil {
            return false
        }
        return loved.contains(userId!)
    }
    
    
    // MARK: - LOVED
    func addLoved() {
        let loved = self[FPlace.loved] as? String ?? ""
        if AppState.currentUser == nil {
            return
        }
        let userId = AppState.currentUser?.getUserId()
        if userId == nil {
            return
        }
        if loved.contains(userId!) {
            // This user already loved
            return
        }
        self[FPlace.loved] = loved + "#" + userId!
        self.saveInBackground()
    }
    
    func removeLoved() {
        let loved = self[FPlace.loved] as? String ?? ""
        if AppState.currentUser == nil {
            return
        }
        let userId = AppState.currentUser?.getUserId()
        if userId == nil {
            return
        }
        if loved.contains(userId!) {
            self[FPlace.loved] = loved.replacingOccurrences(of: "#" + userId!, with: "")
            self.saveInBackground()
            return
        }
    }
    
    
    
    
    
    // DONT need this func anymore
//    func resavePrice(){
//        let fromPrice = self[FPlace.fromprice] as? String
//        let toPrice = self[FPlace.toprice] as? String
//        // from
//        let key = CharacterSet(charactersIn: "$+/N")
//        var fb = false
//        if fromPrice ?? "" != "" {
//            let afp = fromPrice!.components(separatedBy: key)
//            if afp.count > 1 {
//                debugPrint("FROM:", fromPrice!, afp)
//                self[FPlace.fromprice] = afp[1]
//                fb = true
//            }
//        }
//        
//        // to
//        var tb = false
//        if toPrice ?? "" != "" {
//            let atp = toPrice!.components(separatedBy: key)
//            if atp.count > 1 {
//                debugPrint("TO:", toPrice!, atp)
//                self[FPlace.toprice] = atp[1]
//                tb = true
//            }
//        }
//        if fb || tb {
//            self.saveInBackground({e in
//                if e != nil {
//                    debugPrint(e?.localizedDescription ?? "")
//                }
//                else{
//                    debugPrint("save successful", self[FPlace.name] ?? "")
//                }
//            })
//        }
//    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
