//
//  AppSetting.swift
//  trid
//
//  Created by Black on 9/26/16.
//  Copyright © 2016 Black. All rights reserved.
//

import Foundation
import PureLayout

struct AppUrl {
    static let website = "https://your.url"
    static let term = "https://your.url/terms/"
    static let privacy = "https://your.url/privacy-policy/"
}

struct AppSetting {
    
    // Booking.com
    static let booking_com_id = "your.booking.id"
    
    struct Visa {
        static let id = "your.id"
        static let url = "visa.url"
    }
    
    // App name
    struct App {
        static let name = "trid"
        static let email = "demo@trid.com"
        static let teamName = "LeBro Team"
        static let appStoreId = ""
        static let iOSAppStoreURLFormat = "itms-apps://itunes.apple.com/app/id" // 7 and down
        // dashboard
        static var headerHeight : CGFloat {
            if Global.isRabitPhone {
                return 85
            }
            return 64
        }
        static var tabbarHeight : CGFloat {
            if Global.isRabitPhone {
                return 84
            }
            return 54
        }
        static let screenSize = UIScreen.main.bounds.size
        
        // rate
        static let timesToAskRate = 5 // 31/08/17 request change from Mr.Tho
    }
    
    // Weather
    struct Weather {
        // OpenWeather
        // http://api.openweathermap.org/data/2.5/weather?lat=21.0227003&lon=105.8018582&appid=f68bff9ead757dae52583e0ab5ce908c
        // http://api.openweathermap.org/data/2.5/forecast/daily?lat=21.0227003&lon=105.8018582&appid=f68bff9ead757dae52583e0ab5ce908c
        static let key = "649c9d257dea4e1bb3c256c27cbb6168" //"your.open.weather.id"
        static func buildConditionApi(lat: Double, long: Double) -> String {
            return "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=\(Weather.key)&units=metric"
        }
        static func buildForecastApi(lat: Double, long: Double) -> String {
            return "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(lat)&lon=\(long)&appid=\(Weather.key)&units=metric"
        }
    }
    
    // Color info
    struct Color {
        static let blue = 0x2196F1
        static let black = 0x212121
        static let gray = 0x727272
        static let lightGray = 0xB6B6B6
        static let settingblue = 0x1780D1
        static let whitesmoke = 0xF5F5F5
        static let veryLightGray = 0xeeeeee
        // category style
        static let orange = 0xF7A421
        static let pink = 0xEA4C88
        static let deepOrange = 0xF75C4C
        static let cyan = 0x27CBC0
        static let violet = 0x8E44AD
        static let deepYellow = 0xFBC73E
        static let darkPeach = 0xF3825B
        static let brown = 0x8B572A
        static let lightGreen = 0x7ED321
        static let yellow = 0xF8E71C
        static let green = 0x44A044
    };
    
    // Time format
    struct TimeFormat {
        static let full = "hh:mm a yyyy/MM/dd";
    };
    
    // Font
    struct Font {
        static let roboto = "Roboto-Regular"
        static let roboto_medium = "Roboto-Medium"
        static let roboto_bold = "Roboto-Bold"
        static let roboto_light = "Roboto-Light"
    }
    struct FontSize {
        static let verySmall : CGFloat = 10
        static let small : CGFloat = 12
        static let normalSmall : CGFloat = 14
        static let normal : CGFloat = 15
        static let big : CGFloat = 16
        static let veryBig : CGFloat = 18
    };
    
    // text - paragraph
    struct Text {
        static let lineSpacing : CGFloat = 4
        static let paragraphSpacing : CGFloat = 10
    }
    
    // common
    struct Common {
        static let margin : CGFloat = 20
    }
    
    // Popup title
    struct PopupTitle {
        static let error = "Error"
        static let warning = "Warning"
        static let notice = "Notice"
        static let app = AppSetting.App.name
    }
    
    // Map
    struct Map {
        static let zoomDefault : Float = 14
    }
}

// MARK: - Firebase remote config key
struct FBConfigKey {
    static let visaHomeShow = "visa_home_show"
    static let visaTabShow = "visa_tab_show"
}







