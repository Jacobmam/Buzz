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
    // MARK: - DISMISS KEYBOARD
    func endEditing() {
        UIApplication.shared.endEditing()
    }
    
    // MARK: - EMAIL VALIDATION
    func isValidEmail(_ string: String) -> Bool {
        if string.count > 100 {
            return false
        }
        let emailFormat = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" + "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" + "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        //let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: string)
    }
    
    func validatePassword(password: String, confirmPassword: String? = nil)  -> (Bool, String) {
        // 1) Length checks
        if password.count < 8 {
            return (false, "Password must be at least 8 characters.")
        }
        if password.count >= 15 {
            return (false, "Password must be under 15 characters.")
        }
        
        // 2) Must include at least one number
        if password.range(of: "\\d", options: .regularExpression) == nil {
            return (false, "Password must contain at least 1 number.")
        }
        // 3) Must include at least one uppercase letter
        if password.range(of: "[A-Z]", options: .regularExpression) == nil {
            return (false, "Password must contain at least 1 capital letter.")
        }
        
        // 4) Must include at least one lowercase letter
        if password.range(of: "[a-z]", options: .regularExpression) == nil {
            return (false, "Password must contain at least 1 lowercase letter." )
        }
        
        // 5) Must include at least one special character
        let specialSet = CharacterSet(charactersIn: "!@#$%^&*(),.?\":{}|<>")
        if password.rangeOfCharacter(from: specialSet) == nil {
            return (false, "Password must contain at least 1 special character.")
        }
        if let confirmPassword {
            if password != confirmPassword {
                return (false, "Password and confirm password should be same.")
            }
        }
        
      return (true, "")
        
    }
}


extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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

