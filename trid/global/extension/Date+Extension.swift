//
//  Date+Extension.swift
//  trid
//
//  Created by Black on 12/5/16.
//  Copyright © 2016 Black. All rights reserved.
//

import Foundation

extension Date {
    // convert to display string
    // nếu trước 7 ngày -> "EEE, MMM dd'" + suffix + "' yyyy, hh:mm a"
    // nếu trong vòng 7 ngày -> "EEE, hh:mm a"
    // nếu hôm qua "Yesterday, hh:mm a"
    // nếu hôm nay "hh:mm a"
    // nếu trong vòng 3 tiếng trc "3h ago", "20m ago"
    func toDisplayString() -> String {
        let calendar = Utils.calendar
        let components = calendar.dateComponents([.day, .hour, .minute], from: self, to: Date())
        // hom nay
        if calendar.isDateInToday(self){
            if components.hour! > 3 {
                // hom nay
                return Localized.today + ", " + toStringWith(format: "HH:mm")
            }
            else if components.hour! >= 1 {
                // 3-1 h truoc
                return String(components.hour!) + Localized.hAgo
            }
            else if components.minute! > 0{
                // x ph truoc
                return String(components.minute!) + Localized.mAgo
            }
            else {
                return Localized.justAMoment
            }
        }
        else if calendar.isDateInYesterday(self){
            // hom qua
            return toStringWith(format: "HH:mm") + " " + Localized.yesterday
        }
        else if calendar.isDateInWeekend(self) {
            // trong tuan nay
            return String(components.day!) + Localized.dayAgo
        }
        else {
            // tuần trc
            //let d = calendar.component(.day, from: self)
            //let suffix = Utils.getDayOfMonthSuffix(day: d)
            //let format = "EEE, MMM dd'" + suffix + "' yyyy, HH:mm"
            let format = "HH:mm dd/MM/yyyy" // 1/3/17 a Thọ muốn đổi format ngắn như thế này
            return toStringWith(format: format)
        }   
    }
    
    func toServerString() -> String {
        return toStringWith(format: AppSetting.TimeFormat.full, isUTC: true)
    }
    
    fileprivate func toStringWith(format: String, isUTC: Bool = false) -> String {
        let formatter = Utils.dateFormatter
        formatter.dateFormat = format
        if isUTC {
            formatter.timeZone = TimeZone(identifier: "UTC")
        }
        else{
            // local
            formatter.timeZone = TimeZone.current
            formatter.locale = Locale.current
        }
        return formatter.string(from: self)
    }
    
    func toWeekday() -> String {
        Utils.dateFormatter.dateFormat = "EEE"
        return Utils.dateFormatter.string(from: self)
    }
}
