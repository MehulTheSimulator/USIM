//
//  LogUtilityHelper.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public let allowLocalLog = true
public let allowRemoteLog = false

func RemoteLog(_ text: String) {
    
    if(allowLocalLog) {
        print("\(text)")
    }
    
    if(allowRemoteLog) {
        let task = Task.detached(priority: .userInitiated) {
            do {
                let endPoint: EndPoints = .remoteLog(text)
                let result = try await URLSession.shared.data(from: endPoint.url!)
                print(result.0)
            } catch let error {
                print("Unable to log: \(error)")
            }
        }
    }
}
