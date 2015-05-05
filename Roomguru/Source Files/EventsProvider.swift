//
//  EventsProvider.swift
//  Roomguru
//
//  Created by Patryk Kaczmarek on 01/05/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import DateKit
import Async

class EventsProvider {
    
    private var timeRange: TimeRange!

    func provideCalendarEntriesForCalendarIDs(calendarIDs: [String], timeRange: TimeRange, onlyRevocable: Bool, completion: (calendarEntries: [CalendarEntry], error: NSError?) -> Void) {
        
        self.timeRange = timeRange
        let queries: [PageableQuery] = EventsQuery.queriesForCalendarIdentifiers(calendarIDs, withTimeRange: timeRange)
        
        NetworkManager.sharedInstance.chainedRequest(queries, construct: { (query, response: [Event]?) -> [CalendarEntry] in
            
            if let query = query as? EventsQuery, response = response {
                var events:[Event] = []
                if onlyRevocable{
                    events = self.onlyCreatedByUserActiveEvents(response)
                } else {
                    events = self.onlyActiveEvents(response)
                }
                return CalendarEntry.caledarEntries(query.calendarID, events: events)
            }
            return []
            
            }, success: { [weak self] (result: [CalendarEntry]?) in
                
                var calendarEntriesToReturn: [CalendarEntry] = []
                
                Async.background {
                    if onlyRevocable{
                        if let result = result {
                                calendarEntriesToReturn = CalendarEntry.sortedByDate(result)
                            }
                    } else {
                        if let result = result, calendarEntries = self?.fillActiveEventsWithFreeEvents(result) {
                                calendarEntriesToReturn = calendarEntries
                        }
                    }
                }.main {
                    completion(calendarEntries: calendarEntriesToReturn, error: nil)
                }
                
            }, failure: { error in
                completion(calendarEntries: [], error: error)
        })
    }

}

private extension EventsProvider {
    
    func onlyActiveEvents (events: [Event]) -> [Event] {
        return events.filter{ !$0.isCanceled() }
    }
    
    func onlyCreatedByUserActiveEvents (events: [Event]) -> [Event] {
        let userEmail = UserPersistenceStore.sharedStore.user?.email
        return events.filter{ !$0.isCanceled() && $0.creator?.email == userEmail}
    }

    func fillActiveEventsWithFreeEvents(activeEntries: [CalendarEntry]) -> [CalendarEntry] {
        
        let sortedEntries = CalendarEntry.sortedByDate(activeEntries)
        let timeStep = Constants.Timeline.TimeStep
        
        var entries: [CalendarEntry] = []
        var referenceDate = timeRange.min!
        var index = 0
        
        while referenceDate.isEarlierThan(timeRange.max!) {
            
            if index == sortedEntries.count {
                
                addFreeEventCalendarEntryToEntries(&entries, withStartDate: referenceDate, endDate: referenceDate.dateByAddingTimeInterval(timeStep))
                increase(&referenceDate)
                
            } else if let currentEntryStartTime = sortedEntries[index].event.start, currentEntryEndTime = sortedEntries[index].event.end {
            
                let timeBetweenReferenceDateAndTheClosestEntry = ceil(currentEntryStartTime.timeIntervalSinceDate(referenceDate))
                
                if timeBetweenReferenceDateAndTheClosestEntry >= timeStep {
                    
                    addFreeEventCalendarEntryToEntries(&entries, withStartDate: referenceDate, endDate: referenceDate.dateByAddingTimeInterval(timeStep))
                    increase(&referenceDate)

                } else if timeBetweenReferenceDateAndTheClosestEntry > 0 {
                    
                    addFreeEventCalendarEntryToEntries(&entries, withStartDate: referenceDate, endDate: referenceDate.dateByAddingTimeInterval(timeBetweenReferenceDateAndTheClosestEntry))
                    increase(&referenceDate, by: timeBetweenReferenceDateAndTheClosestEntry)
                    
                } else {
                    
                    let entry = sortedEntries[index]
                    entries.append(entry)
                
                    let eventDuration = entry.event.end!.timeIntervalSinceDate(entry.event.start!)
                    increase(&referenceDate, by: eventDuration)
                    
                    index++
                }
                
            } else {
                increase(&referenceDate)
            }
        }
        return entries
    }
    
    func addFreeEventCalendarEntryToEntries(inout entries: [CalendarEntry], var withStartDate startDate: NSDate, endDate: NSDate)  {
        
        // cannot book in not declared days
        let weekday = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitWeekday, fromDate: startDate)
        if !contains(Constants.Timeline.BookingDays, weekday) {
            return
        }
        
        // cannot book earlier than defined
        if startDate.timeIntervalSinceDate(startDate.midnight) < Constants.Timeline.BookingRange.min {
            return
        }
        
        // cannot book later than defined
        if startDate.timeIntervalSinceDate(startDate.midnight) > Constants.Timeline.BookingRange.max {
            return
        }
        
        // If earlier than now, change start date of event.
        // If will pass second condition, it means startDate is around current hour.
        // It it will be past, eventDuration will give minuse value, so next condition will break adding event.
        if startDate.isEarlierThanToday() {
            startDate = NSDate()
        }
        
        let eventDuration = endDate.timeIntervalSinceDate(startDate)
        
        // cannot be shorter than MinimumEventDuration
        if eventDuration < Constants.Timeline.MinimumEventDuration {
            return
        }
        
        let freeEvent = FreeEvent(startDate: startDate, endDate: endDate)
        entries.append(CalendarEntry(calendarID: "", event: freeEvent))
    }
    
    func increase(inout date: NSDate, by timeInterval: NSTimeInterval = Constants.Timeline.TimeStep) {
        date = date.dateByAddingTimeInterval(timeInterval)
    }
}
