//
//  Commons.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

class Commons {
        
    static func decode<T: Codable>(data: Data, type: T.Type) -> Result<T, Error> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let result = try decoder.decode(T.self, from: data)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    // example : -
    /// let jsonData = // some JSON data as a Data instance
    /// let result = decode(data: jsonData, type: LicenseFormat.self)
    ///
    /// switch result {
    /// case .success(let model):
    ///     // do something with the decoded model
    /// case .failure(let error):
    ///     // handle the decoding error
    /// }
    
    static func encode<T: Codable>(_ value: T) -> Result<Data, Error> {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let result = try encoder.encode(value)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    // example : -
    /// let license = // some instance of LicenseFormat
    /// let result = encode(license)
    ///
    /// switch result {
    /// case .success(let data):
    ///     // do something with the encoded data
    /// case .failure(let error):
    ///     // handle the encoding error
    /// }
}
