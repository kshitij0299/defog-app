import Foundation
import UserNotifications
import UIKit

@Observable
final class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func recordActivity() {
        UserPreferences.lastActivityDate = Date()
        scheduleInactivityNudge()
    }
    
    func scheduleInactivityNudge(after days: Int = 3) {
        cancelInactivityNudge()
        
        guard UserPreferences.remindersEnabled else { return }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            let content = UNMutableNotificationContent()
            content.title = "Hey, how's it going?"
            content.body = "You haven't logged anything in a few days. No pressure — just checking in."
            content.sound = .default
            
            // Scheduling 3 days from Date.now
            let targetDate = Calendar.current.date(byAdding: .day, value: days, to: Date.now)!
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "InactivityNudge", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling inactivity nudge: \(error)")
                }
            }
        }
    }
    
    func cancelInactivityNudge() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["InactivityNudge"])
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    static func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
