//
//  String+Size.swift
//  trid
//
//  Created by Black on 10/4/16.
//  Copyright © 2016 Black. All rights reserved.
//

import Foundation
import UIKit
import CoreFoundation

extension String {
    // MARK: - calculate size
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return boundingBox.height
    }
    
    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return boundingBox.width
    }
    
    func detectDataType() -> NSAttributedString {
        let attributesDash = [NSAttributedString.Key.foregroundColor: UIColor(netHex: AppSetting.Color.gray),
                              NSAttributedString.Key.font: UIFont(name: AppSetting.Font.roboto, size: 14)!,
                              NSAttributedString.Key.underlineStyle: NSUnderlineStyle.patternDash] as [NSAttributedString.Key : Any]
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor(netHex: AppSetting.Color.gray),
                          NSAttributedString.Key.font: UIFont(name: AppSetting.Font.roboto, size: 14)!] as [NSAttributedString.Key : Any]
        // parse
        let result = NSMutableAttributedString()
        let arr = self.components(separatedBy: CharacterSet(charactersIn: "/"))
        for i in 0..<arr.count {
            let string = arr[i]
            result.append(NSAttributedString(string: string, attributes: attributesDash))
            if i < arr.count - 1 {
                result.append(NSAttributedString(string: "/", attributes: attributes))
            }
        }
        return result
    }
    
    // MARK: - Localization
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func localizedWithComment(comment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
    
    // MARK: - Handle language sign - Loại bỏ dấu tiếng Việt
    func removeVietnameseSign() -> String {
        //        str= str.replace(/àáạảãâầấậẩẫăằắặẳẵ/g,"a");
        //        str= str.replace(/èéẹẻẽêềếệểễ/g,"e");
        //        str= str.replace(/ìíịỉĩ/g,"i");
        //        str= str.replace(/òóọỏõôồốộổỗơờớợởỡ/g,"o");
        //        str= str.replace(/ùúụủũưừứựửữ/g,"u");
        //        str= str.replace(/ỳýỵỷỹ/g,"y");
        //        str= str.replace(/đ/g,"d");
        //        str= str.replace(/!@\$%\^\*\(\)\+\=\<\>\?\/,\.\:\' \"\&\#\[\]~/g,"-");
        //        str= str.replace(/-+-/g,"-"); //thay thế 2- thành 1-
        //        str= str.replace(/^\-+\-+$/g,"");//cắt bỏ ký tự - ở đầu và cuối chuỗi
        var str = self
        str = str.replacingOccurrences(of: "[àáạảãâầấậẩẫăằắặẳẵ]", with: "a", options: .regularExpression, range: nil)
        str = str.replacingOccurrences(of: "[èéẹẻẽêềếệểễ]", with: "e", options: .regularExpression, range: nil)
        str = str.replacingOccurrences(of: "[ìíịỉĩ]", with: "i", options: .regularExpression, range: nil)
        str = str.replacingOccurrences(of: "[òóọỏõôồốộổỗơờớợởỡ]", with: "o", options: .regularExpression, range: nil)
        str = str.replacingOccurrences(of: "[ùúụủũưừứựửữ]", with: "u", options: .regularExpression, range: nil)
        str = str.replacingOccurrences(of: "[ỳýỵỷỹ]", with: "y", options: .regularExpression, range: nil)
        str = str.replacingOccurrences(of: "[đ]", with: "d", options: .regularExpression, range: nil)
        return str
    }
    
    // MARK: validate email
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    
    // MARK: - Datetime
    func toServerDate() -> Date? {
        let formatter = Utils.dateFormatter
        formatter.dateFormat = AppSetting.TimeFormat.full
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: self)
    }
    
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func condenseWhitespace() -> String {
        let str = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return str.joined(separator: "")
    }
}
