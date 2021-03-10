//
//  MeasurementHelper.swift
//  trid
//
//  Created by Black on 11/25/16.
//  Copyright © 2016 Black. All rights reserved.
//

import Firebase

class MeasurementHelper: NSObject {
    
    static func sendLoginEvent() {
        Analytics.logEvent(AnalyticsEventLogin, parameters: nil)
    }
    
    static func sendLogoutEvent() {
        Analytics.logEvent("black_logout", parameters: nil)
    }
    
    static func sendMessageEvent() {
        Analytics.logEvent("black_message", parameters: nil)
    }
    
    static func openMenu() {
        Analytics.logEvent("black_open_menu", parameters: nil)
    }
    
    static func openPaidCity(name: String) {
        Analytics.logEvent("black_open_paid_city_\(name.condenseWhitespace())", parameters: nil)
    }
    
    static func openCity(name: String) {
        Analytics.logEvent("black_open_city_\(name.condenseWhitespace())", parameters: nil)
    }
    
    static func openBookTicket() {
        Analytics.logEvent("black_baolau_com", parameters: nil)
    }
    
    static func openBooking() {
        Analytics.logEvent("black_booking_com", parameters: nil)
    }
    
    static func openFilter(){
        Analytics.logEvent("black_open_filter", parameters: nil)
    }
    
    static func activeFilter(){
        Analytics.logEvent("black_active_filter", parameters: nil)
    }
    
    static func expandMap(){
        Analytics.logEvent("black_expand_map", parameters: nil)
    }
    
    static func collapsedMap(){
        Analytics.logEvent("black_collapsed_map", parameters: nil)
    }
    
    static func openCategory(name: String) {
        Analytics.logEvent("black_open_category_\(name.condenseWhitespace())", parameters: nil)
    }
    
    static func openCityTransport(city: String) {
        Analytics.logEvent("black_open_transport_\(city.condenseWhitespace())", parameters: nil)
    }
    
    static func openCityInfo(city: String) {
        Analytics.logEvent("black_open_info_\(city.condenseWhitespace())", parameters: nil)
    }
    
    static func openCityEmergency(city: String) {
        Analytics.logEvent("black_open_emergency_\(city.condenseWhitespace())", parameters: nil)
    }
    
    static func actionSavedPlace(city: String) {
        Analytics.logEvent("black_action_saved_place_in_\(city.condenseWhitespace())", parameters: nil)
    }
    
    static func openSavedTab() {
        Analytics.logEvent("black_open_saved_tab", parameters: nil)
    }
    
    static func openWeather(city: String) {
        Analytics.logEvent("black_open_weather_\(city.condenseWhitespace())", parameters: nil)
    }
    
    static func openComment(city: String) {
        Analytics.logEvent("black_open_comment_\(city.condenseWhitespace())", parameters: nil)
    }
    
    static func openVideoIntro(city: String) {
        Analytics.logEvent("black_open_video_intro_\(city.condenseWhitespace())", parameters: nil)
    }
    
    static func updatedVersion(_ ver: String) {
        Analytics.logEvent("black_updated_version_\(ver)", parameters: nil)
    }
    
    static func openVisaCategory(_ name: String) {
        debugPrint(name)
        Analytics.logEvent("black_banner_\(name)", parameters: nil)
    }
    
    // Banner
    static func openBannerHome(city: String) {
        Analytics.logEvent("black_banner_home \(city)", parameters: nil)
    }
}
