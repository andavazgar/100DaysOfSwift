//
//  ViewController.swift
//  Project 21
//
//  Created by Andres Vazquez on 2020-03-03.
//  Copyright © 2020 Andavazgar. All rights reserved.
//

import UserNotifications
import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(register))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(schedule))
    }
    
    @objc func register() {
        let unCenter = UNUserNotificationCenter.current()
        unCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Permission granted")
            } else {
                print("Permission denied")
            }
        }
    }
    @objc func schedule() {
        scheduleNotification(for: nil)
    }
    
    func scheduleNotification(for futureDate: Date? = nil) {
        registerNotificationCategories()
        
        let unCenter = UNUserNotificationCenter.current()
        unCenter.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Always remember"
        content.body = "Life is too short to worry!"
        content.categoryIdentifier = "showMore_CATEGORY"
        content.userInfo = ["customMessage": "This is some userInfo data"]
        
        let trigger: UNNotificationTrigger
        
        if let futureDate = futureDate {
            let nextTriggerDateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: futureDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: nextTriggerDateComponent, repeats: false)
        } else {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        unCenter.add(request)
    }
    
    private func registerNotificationCategories() {
        let unCenter = UNUserNotificationCenter.current()
        unCenter.delegate = self
        
        let showMoreAction = UNNotificationAction(identifier: "showMore_ACTION", title: "Show more information", options: .foreground)
        let snoozeAction = UNNotificationAction(identifier: "snooze_ACTION", title: "Remind me tomorrow", options: .foreground)
        let showMoreCategory = UNNotificationCategory(identifier: "showMore_CATEGORY", actions: [showMoreAction, snoozeAction], intentIdentifiers: [], options: [])
        unCenter.setNotificationCategories([showMoreCategory])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        
        if categoryIdentifier == "showMore_CATEGORY" {
            print(userInfo["customMessage"] as! String)
            
            switch response.actionIdentifier {
            case "snooze_ACTION":
                // Schedules notification for next day (24 hours)
                scheduleNotification(for: Calendar.current.date(byAdding: .day, value: 1, to: Date()))
                
                let ac = UIAlertController(title: "Notification snoozed", message: "The notification will be shown again tomorrow", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                
            case "showMore_ACTION":
                let ac = UIAlertController(title: "Show more information", message: "Here it is: beep bopp beep", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                
            case UNNotificationDefaultActionIdentifier:
                // The notification was tapped
                let ac = UIAlertController(title: "Tapped / Swipped received", message: "The notification was tapped or swipped.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                
            case UNNotificationDismissActionIdentifier:
                // The notification was dismissed
                // This action is delivered only if the notification’s category object was configured with the customDismissAction option.
                break
            default:
                break
            }
        } else {
            // Handle another categoryIdentifier
        }
        
        completionHandler()
    }
}

