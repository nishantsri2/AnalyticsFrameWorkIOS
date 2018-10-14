//
//  AnalyticsDB.swift
//  AnalyticsTool
//
//  Created by Kustard Developer on 14/10/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import Foundation
import SQLite

class AnalyticsDB
{
    static let instance = AnalyticsDB()
    private let db: Connection?
    //governorate table
    private let analyticsEvent = Table("analytics_event")
    private let eventId = Expression<Int64>("event_id")
    private let eventTime = Expression<String>("event_time")
    private let eventOs = Expression<String>("event_os")
    private let eventAppVersion = Expression<String>("event_app_version")
    private let eventMake = Expression<String>("event_make")
    private let eventModel = Expression<String>("event_model")
    private let eventOsVersion = Expression<String>("event_os_version")
    
    private init() {
        
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        do {
            db = try Connection("\(path)/analytics_database.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        
        createEventTable()
    }
    
    func createEventTable() {
        do {
            let createQuery = analyticsEvent.create(ifNotExists: true) { table in
                table.column(eventId, primaryKey: true)
                table.column(eventTime)
                table.column(eventOs)
                table.column(eventAppVersion)
                table.column(eventMake)
                table.column(eventModel)
                table.column(eventOsVersion)
            }
            try db?.run(createQuery)
            
        } catch {
            print("Unable to create table")
        }
    }
    func addEvent(event:Event){
        do {
            
            let addEvent = analyticsEvent.insert(
                eventId                             <- Int64(event.eventId ?? 0)
                , eventTime                         <- event.eventTime!
                , eventOs                            <- event.eventOs!
                , eventAppVersion                   <- event.eventAppVersion!
                , eventMake                         <- event.eventMake!
                , eventModel                         <- event.eventModel!
                , eventOsVersion                     <- event.eventOsVersion!
            )
            try db!.run(addEvent)
        }
        catch {
            print(error)
        }
    }
    func getAllEvents() -> [Event] {
        var eventList: [Event] = []
        do {
            for eventData in try (db?.prepare(analyticsEvent))! {
                let event = Event()
                event.eventId = Int(eventData[eventId])
                event.eventTime = eventData[eventTime]
                event.eventOs = eventData[eventOs]
                event.eventAppVersion = eventData[eventAppVersion]
                event.eventMake = eventData[eventMake]
                event.eventModel = eventData[eventModel]
                event.eventOsVersion = eventData[eventOsVersion]
                eventList.append(event)

            }
        }
        catch {
            print(error)
        }
        return eventList
    }
    func deleteEvent() {
        do {
            try db?.run(analyticsEvent.delete())
        }
        catch {
            print(error)
        }
    }
}

