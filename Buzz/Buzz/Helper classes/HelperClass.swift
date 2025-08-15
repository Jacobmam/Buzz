//
//  HelperClass.swift
//  Buzz
//
//  Created by Jay Borania on 06/08/25.
//

import SwiftUI
import Foundation

enum GameRequestStatus: Int {
    case pending = 0
    case accepted = 1
    case rejected = 2
    case cancelled = 3
    case completed = 4
}

extension Notification.Name {
    static let navigateToNotificationsView = Notification.Name("navigateToNotificationsView")
}

class HelperClass {
    static let shared = HelperClass()
    
    func timeAgoString(from date: String) -> String {
        guard let fromDate = convertUTCStringToDate(date),
              let nowDate = convertUTCStringToDate(currentUTCDateString()) else { return "-" }
        
        let secondsAgo = Int(nowDate.timeIntervalSince(fromDate))
        if secondsAgo < 0 {
            return "In the future"
        }
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        
        switch secondsAgo {
        case 0..<60:
            return "Just now"
        case 60..<(60 * 60):
            let minutes = secondsAgo / minute
            return "\(minutes) min ago"
        case (60 * 60)..<(24 * hour):
            let hours = secondsAgo / hour
            return "\(hours) hour\(hours > 1 ? "s" : "") ago"
        case (24 * hour)..<(48 * hour):
            return "Yesterday"
        case (48 * hour)..<(7 * day):
            let days = secondsAgo / day
            return "\(days) day\(days > 1 ? "s" : "") ago"
        default:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd" // Adjust if your format is different
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter.string(from: fromDate)
        }
    }
    
    func convertUTCStringToDate(_ strDate: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" // Adjust if your format is different
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        // Convert string to Date
        guard let utcDate = formatter.date(from: strDate) else {
            print("Invalid date string: \(strDate)")
            return nil
        }
        return utcDate
    }
    
    func currentUTCDateString() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return dateFormatter.string(from: now)
    }
    
    func utcDateStringWithAddedSeconds(_ seconds: Int) -> String {
        let now = Date()
        let futureDate = now.addingTimeInterval(TimeInterval(seconds))
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        return dateFormatter.string(from: futureDate)
    }
    
    func secondsSince(startDateString: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        guard let startDate = dateFormatter.date(from: startDateString) else {
            print("❌ Error: Invalid date string format")
            return nil
        }
        
        let now = Date()
        let difference = now.timeIntervalSince(startDate)
        return Int(difference)
    }

}

extension View {
    func showClearButton(_ text: Binding<String>) -> some View {
        self.modifier(TextFieldClearButton(fieldText: text))
    }
}

struct TextFieldClearButton: ViewModifier {
    @Binding var fieldText: String

    func body(content: Content) -> some View {
        content
            .overlay {
                if !fieldText.isEmpty {
                    HStack {
                        Spacer()
                        Button {
                            fieldText = ""
                        } label: {
                            Image(systemName: "multiply.circle.fill")
                        }
                        .foregroundColor(.secondary)
                        .padding(.trailing, 4)
                    }
                }
            }
    }
}

