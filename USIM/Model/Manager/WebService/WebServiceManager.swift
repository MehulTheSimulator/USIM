//
//  WebServiceManager.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class WebServiceManager {
    
    static func requestCallService<T: Encodable & Decodable> (_ endPoint: EndPoints, type: T.Type) async throws -> T {
        guard let url = endPoint.url else { throw RuntimeError(message: "URL is not available.") }
        let (data, _) = try await URLSession.shared.data(from: url)
        RemoteLog("RETURNED DATA: \(String(describing: String(data: data, encoding: .utf8)))")
        let result = Commons.decode(data: data, type: type)
        switch result {
        case .success(let success):
            return success
        case .failure(let failure):
            throw RuntimeError(message: "Server returned error: \(failure.localizedDescription)")
        }
    }
}
