//
//  HomeViewController+Delegate.swift
//  USIM
//
//  Created by Asher Azeem on 09/03/2023.
//

import UIKit
import UserNotifications

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.collectionView) {
            return USIM.application.config.getTotalModeCount()
        }
        guard let mode = USIM.application.currentMode else {
            return 0
        }
        return USIM.application.config.getViewCount(modeKey: mode)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.collectionView) {
            let modeIndex = indexPath.row
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TagModeCollectionCell.self), for: indexPath) as! TagModeCollectionCell
            let mode = USIM.application.getMode(modeIndex)!
            cell.target = self
            cell.isCustom = modeIndex >= USIM.application.config.getDefaultModeCount()
            cell.modeKey = mode.key
            cell.update()
            return cell
        }
        
        let viewIndex = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TagViewsCollectionCell.self), for: indexPath) as! TagViewsCollectionCell
        let modeKey = USIM.application.currentMode!
        let view = USIM.application.config.getViewDefinition(modeKey: modeKey, index: viewIndex)!
        cell.target = self
        cell.isCustom = viewIndex >= USIM.application.config.getDefaultViewCount(modeKey: modeKey)
        cell.modeKey = view.modeKey
        cell.viewKey = view.key
        cell.update()
        return cell
    }
}

// MARK: - RFIDInputHandlerCallback

extension HomeViewController: RFIDInputHandlerCallback {
    func handleValidInput(input: String) {
        USIM.RemoteLog("Handle valid input \(input)")
        var isSame = false
        if let cc = currentCode {
            isSame = cc == input
        }
        USIM.RemoteLog("Is Same \(isSame)")
        lastInputTimer()
        if(!isSame) {
            currentCode = input
            let urls = application.getCachedVideoURLsForCode(code: input)
            var targetURL: URL?
            USIM.RemoteLog("URL count: \(urls.count)")
            if(urls.count > 0) {
                var index = -1
                if let lik = lastInstanceKey {
                    for i in 0...(urls.count - 1) {
                        USIM.RemoteLog("URL \(i): \(urls[i].0) - \(urls[i].1)")
                        if(urls[i].0.compare(lik) == .orderedSame) {
                            index = i
                            break
                        }
                    }
                }
                if(index == -1) {
                    index = 0
                } else {
                    index = (index + 1) % urls.count
                }
                USIM.RemoteLog("Target Index: \(index)")
                lastInstanceKey = urls[index].0
                targetURL = urls[index].1
            }
            if let url = targetURL {
                playVideo(url: url)
            }
        }
    }
}

extension HomeViewController : UNUserNotificationCenterDelegate {
    func scheduleNotifications() {
        
        scheduleNotification(adding: .month, value: -2, identifier: "twoMonthsExpiry")
        scheduleNotification(adding: .month, value: -1, identifier: "oneMonthExpiry")
        scheduleNotification(adding: .day, value: -15, identifier: "fifteenDaysExpiry")
        scheduleNotification(adding: .day, value: 1, identifier: "sameDayExpiry")

//        let content = UNMutableNotificationContent()
//               content.title = "New Message"
//               content.body = "You have a new message from John"
//               content.sound = UNNotificationSound.default
//
//               // Set the trigger for the notification (in 5 seconds)
//               let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//               // Create the notification request
//               let request = UNNotificationRequest(identifier: "newMessage", content: content, trigger: trigger)
//
//               // Add the notification request to the notification center
//               UNUserNotificationCenter.current().add(request) { error in
//                   if let error = error {
//                       print("Error: \(error.localizedDescription)")
//                   } else {
//                       print("Notification scheduled")
//                   }
//               }
        
        // check if the notification with this identifier has already been scheduled
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                let identifiers = requests.map { $0.identifier }
                debugPrint("notification = \(identifiers)")
//                if !identifiers.contains(identifier) {
//                    UNUserNotificationCenter.current().add(Request)
//                }
            }
    }

    func scheduleNotification(adding: Calendar.Component, value: Int, identifier: String) {
        // Schedule notification before expiry
        let content = UNMutableNotificationContent()
        content.title = "Your license will expire soon!"
        content.body = "Renew your license before it expires to avoid any inconvenience."

        let expiryDate = USIM.application.config.getLicenseInfo()?.endDate ?? Date()
        let TriggerDate = Calendar.current.date(byAdding: adding, value: value, to: expiryDate)!
        let Trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: TriggerDate), repeats: false)
        let Request = UNNotificationRequest(identifier: identifier, content: content, trigger: Trigger)
        UNUserNotificationCenter.current().add(Request)
    }
    
    // Handle the notification when it is displayed
        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            print("Notification received")
            completionHandler()
        }
    
}

