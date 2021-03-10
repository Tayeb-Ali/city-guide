//
//  FWeather.swift
//  trid
//
//  Created by Black on 4/18/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit
import SwiftyJSON

class UtilWeather : NSObject {
    static func temperature(_ temp: Int) -> String {
        return String(temp) + "\u{00B0}C"
    }
}

class ForecastDay : NSObject {
    var date : Date?
    var tempHighF : String = FWeather.tempNull
    var tempLowF : String = FWeather.tempNull
    var tempHighC : String = FWeather.tempNull
    var tempLowC : String = FWeather.tempNull
    var condition : String = ""
    // Icon name for condition
    var icon : String = ""
    // Probability of Precipitation
    var pop : String = ""
    var humidity : String = ""
    
    func weekday() -> String {
        if self.date == nil {
            return ""
        }
        return self.date!.toWeekday()
    }
}

class WeatherToday: NSObject {
    var date : Date?
    var tempC : String = FWeather.tempNull
    var tempF : String = FWeather.tempNull
    var icon : String = ""
    var humidity : String = ""
    var condition : String = ""
    var windSpeed : String = ""
}

class FWeather: FObject {
    static let path = "weather"
    
    static let tempNull = "-"
    
    // Weather -> CityKey -> Weather Object
    // KEY -----------------------------------------------------
    static let forecastJson = "forecastJson"
    static let conditionJson = "conditionJson"
    // KEY -----------------------------------------------------
    var forecast : [ForecastDay]?
    var today : WeatherToday?
    
    func getForecastJson() -> JSON {
        let str = self[FWeather.forecastJson] as? String
        return (str ?? "" == "") ? JSON.null : JSON(parseJSON: str!)
    }
    
    func getTodayJson() -> JSON {
        let str = self[FWeather.conditionJson] as? String
        return (str ?? "" == "") ? JSON.null : JSON(parseJSON: str!)
    }
    
    func setForecastJson(_ j: JSON) {
        self[FWeather.forecastJson] = j != JSON.null ? j.rawString() : nil
        self.forecast = FWeather.parseForecast(json: j)
    }
    
    func setTodayJson(_ j: JSON) {
        self[FWeather.conditionJson] = j != JSON.null ? j.rawString() : nil
        self.today = FWeather.parseCondition(json: j)
    }
    
    // MARK: - WEATHER PARSER FUNC
    // MARK: - For wunderground
//    static func parseForecast(json: JSON) -> [ForecastDay]? {
//        if json == JSON.null {
//            return nil
//        }
//        var forecast : [ForecastDay] = []
//        // forecast -> simpleforecast -> forecastday array
//        let days = json["forecast"]["simpleforecast"]["forecastday"].arrayValue
//        for jsonday in days {
//            let day = ForecastDay()
//            // date
//            let a = jsonday["date"]["epoch"].rawString()
//            if a != nil {
//                day.date = Date(timeIntervalSince1970: (a! as NSString).doubleValue)
//            }
//            if day.date == nil {
//                continue
//            }
//            // high | low
//            let highC = jsonday["high"]["celsius"]
//            day.tempHighC = highC.stringValue == "" ? FWeather.tempNull : UtilWeather.temperature(highC.intValue)
//            let lowC = jsonday["low"]["celsius"]
//            day.tempLowC = lowC.stringValue == "" ? FWeather.tempNull : UtilWeather.temperature(lowC.intValue)
//            let lowF = jsonday["low"]["fahrenheit"]
//            day.tempLowF = lowF.stringValue == "" ? FWeather.tempNull : UtilWeather.temperature(lowF.intValue)
//            let highF = jsonday["high"]["fahrenheit"]
//            day.tempHighF = highF.stringValue == "" ? FWeather.tempNull : UtilWeather.temperature(highF.intValue)
//            // other
//            let hum = jsonday["avehumidity"].stringValue
//            day.humidity = hum == "" ? FWeather.tempNull : (hum.contains("%") ? hum : (hum + "%"))
//            day.condition = jsonday["conditions"].string ?? ""
//            day.icon = jsonday["icon"].string ?? ""
//            let pop = jsonday["pop"].stringValue
//            day.pop = pop == "" ? FWeather.tempNull : (pop.contains("%") ? pop : (pop + "%"))
//            day.weekday = jsonday["date"]["weekday"].stringValue
//            // Add
//            forecast.append(day)
//        }
//        return forecast
//    }
    
    // MARK: - For wunderground
//    static func parseCondition(json: JSON) -> WeatherToday? {
//        if json == JSON.null {
//            return nil
//        }
//        let condition = WeatherToday()
//        let current = json["current_observation"]
//        // get
//        let temC = current["temp_c"]
//        condition.tempC = temC.stringValue == "" ? FWeather.tempNull : UtilWeather.temperature(temC.intValue)
//        let temF = current["temp_f"]
//        condition.tempF = temF.stringValue == "" ? FWeather.tempNull : UtilWeather.temperature(temF.intValue)
//        condition.wind_kph = current["wind_kph"].stringValue + "kmh"
//        var hum = current["relative_humidity"].stringValue
//        hum = hum == "" ? FWeather.tempNull : hum
//        condition.humidity = !hum.contains("%") ? (hum + "%") : hum
//        
//        condition.condition = current["weather"].stringValue
//        condition.icon = current["icon"].stringValue
//        let time = current["observation_epoch"].string
//        condition.date = time != nil ? Date(timeIntervalSince1970: (time! as NSString).doubleValue) : Date()
//        return condition
//    }
    
    // MARK: - For OpenWeather
    static func parseCondition(json: JSON) -> WeatherToday? {
        if json == JSON.null {
            return nil
        }
        let condition = WeatherToday()
        let main = json["main"]
        // temp
        let temC = main["temp"]
        condition.tempC = temC.stringValue == "" ? FWeather.tempNull : UtilWeather.temperature(temC.intValue)
        condition.tempF = FWeather.tempNull
        // wind
        condition.windSpeed = json["wind"]["speed"].stringValue + "m/s"
        // humidity
        var hum = main["humidity"].stringValue
        hum = hum == "" ? FWeather.tempNull : hum
        condition.humidity = !hum.contains("%") ? (hum + "%") : hum
        // weather
        let weather = json["weather"]
        if weather.type == .array && weather.count > 0 {
            let con = weather[0]["description"].stringValue
            condition.condition = con.trimmingCharacters(in: .whitespacesAndNewlines).capitalizingFirstLetter()
            condition.icon = weather[0]["icon"].stringValue
        }
        // time
        let time = json["dt"].stringValue
        condition.date = time != "" ? Date(timeIntervalSince1970: (time as NSString).doubleValue) : Date()
        return condition
    }
    
    static func parseForecast(json: JSON) -> [ForecastDay]? {
        if json == JSON.null {
            return nil
        }
        var forecast : [ForecastDay] = []
        // forecast -> simpleforecast -> forecastday array
        let days = json["list"].arrayValue
        for jsonday in days {
            let day = ForecastDay()
            // date
            let a = jsonday["dt"].stringValue
            if a != "" {
                day.date = Date(timeIntervalSince1970: (a as NSString).doubleValue)
            }
            if day.date == nil {
                continue
            }
            // temp high | low
            let temp = jsonday["temp"]
            let highC = temp["max"]
            day.tempHighC = highC.stringValue == "" ? FWeather.tempNull : UtilWeather.temperature(highC.intValue)
            let lowC = temp["min"]
            day.tempLowC = lowC.stringValue == "" ? FWeather.tempNull : UtilWeather.temperature(lowC.intValue)
            day.tempLowF = FWeather.tempNull
            day.tempHighF = FWeather.tempNull
            // Humidity
            let hum = jsonday["humidity"].stringValue
            day.humidity = hum == "" ? FWeather.tempNull : (hum.contains("%") ? hum : (hum + "%"))
            // weather
            let weather = jsonday["weather"]
            if weather.type == .array && weather.count > 0 {
                let con = weather[0]["description"].stringValue
                day.condition = con.trimmingCharacters(in: .whitespacesAndNewlines).capitalizingFirstLetter()
                day.icon = weather[0]["icon"].stringValue
            }
            // Rain (mm)
            let rain = jsonday["rain"].string
            day.pop = rain == nil ? "-" : (rain! + "mm")
            
            // Add
            forecast.append(day)
        }
        return forecast
    }
    
}

