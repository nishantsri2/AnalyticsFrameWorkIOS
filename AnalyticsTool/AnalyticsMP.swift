//
//  AnalyticsMP.swift
//  AnalyticsTool
//
//  Created by Kustard Developer on 14/10/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import Foundation
import Alamofire
class AnalyticsMP{
    static let instance = AnalyticsMP()
    func initialize(apiKey:String){
        UserDefaults.standard.setValue(apiKey, forKey: "API_KEY")
        NetworkManager.sharedInstance.reachability.whenReachable = { reachability in
            let events = AnalyticsDB.instance.getAllEvents()
            let uploadSuccess = self.uploadData(eventList: events)
            if(uploadSuccess){
                AnalyticsDB.instance.deleteEvent()
            }
        }
        
        NetworkManager.isReachable { _ in
            var eventList = Array<Event>()
            let event = self.getEvent()
            eventList.append(event)
            _ = self.uploadData(eventList: eventList)
        }
        NetworkManager.isUnreachable(completed: {_ in
            self.addUserEvent()
        })
        
    }
    func setUserId(userId:String){
        UserDefaults.standard.setValue(userId, forKey: "USER_ID")
    }
    func setIdentity(identity:Identity){
        UserDefaults.standard.setValue(identity.name, forKey: "USER_NAME")
        UserDefaults.standard.setValue(identity.age, forKey: "USER_AGE")
        UserDefaults.standard.setValue(identity.gender, forKey: "USER_GENDER")
    }
    
    func getEvent() -> Event {
        let event = Event()
        event.eventModel = UIDevice.modelName
        event.eventOsVersion = UIDevice.current.systemVersion
        event.eventAppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        event.eventMake = UIDevice.current.identifierForVendor!.uuidString
        event.eventOs = UIDevice.current.systemVersion
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: date)
        
        event.eventTime = dateString
        
        return event
    }
    
    func addUserEvent(){
        
        let event = getEvent()
        
        AnalyticsDB.instance.addEvent(event: event)
        
    }
    
    func uploadData(eventList:[Event]) -> Bool {
        let userId = UserDefaults.standard.object(forKey: "USER_ID") as! String
        let userName = UserDefaults.standard.object(forKey: "USER_NAME") as! String
        let userAge = UserDefaults.standard.integer(forKey: "USER_AGE")
        let userGender = UserDefaults.standard.object(forKey: "USER_GENDER") as! String
        let apiKey = UserDefaults.standard.object(forKey: "API_KEY") as! String
        var apiSuccess = false
        
        let parameters:Parameters = ["api_key": apiKey, "user_id": userId, "user_name": userName, "user_age": userAge, "user_gender": userGender, "eventList": eventList]

        Alamofire.request("http://www.mockapi.in", method: .post, parameters: parameters)
            .responseJSON{ response in
                
                switch(response.result){
                case .success( _ as Dictionary<String, Any>):
                    let statusCode = response.response?.statusCode
                    if statusCode == 200
                    {
                        apiSuccess = true
                        
                    }else{
                        apiSuccess = false
                    }
                    break
                case .failure( _):
                    apiSuccess = false
                    break
                default:
                    break
                }
        }
        return apiSuccess
    }
}
