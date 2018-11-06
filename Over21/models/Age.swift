//
//  Age.swift
//  Over21
//
//  Created by Chrishon Wyllie on 10/11/18.
//  Copyright © 2018 Socket Mobile. All rights reserved.
//

import Foundation

// Represents how old someone is
// Example: 30 years, 9 months, 6 days old
class Age: NSObject {
    
    var birthday: Date
    var years: Int
    var months: Int
    var days: Int
    
    init(birthday: Date, years: Int, months: Int, days: Int) {
        self.birthday = birthday
        self.years = years
        self.months = months
        self.days = days
        super.init()
    }
    
    public func isOldEnoughToEnter() -> Bool {
        return years >= AgeLimitSelectionView.ageLimitThreshhold
    }
    
    public func timeUntil21YearsOld() -> DateComponents {
        
        let components = Calendar.current.dateComponents([.month, .year, .day], from: birthday)
        let birthdayYear = components.year
        let birthdayMonth = components.month
        let birthdayDay = components.day
        
        let twentyFirstBirthdayYear: Int = birthdayYear! + 21
        
        let dateOfTwentyFirstBirthday = DateComponents(calendar: .current, timeZone: nil, era: nil, year: twentyFirstBirthdayYear, month: birthdayMonth, day: birthdayDay, hour: nil, minute: nil, second: nil, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil).date!
        
        let timeComponentsUntilTwentyOne = Calendar.current.dateComponents([.month, .year, .day], from: Date(), to: dateOfTwentyFirstBirthday)
        
        return timeComponentsUntilTwentyOne

    }
}
