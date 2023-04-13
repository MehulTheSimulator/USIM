//
//  ErrorHandeling.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import Foundation

//enum RuntimeError: Error {
//    case runtimeError(String)
//}

struct RuntimeError: LocalizedError {
    
    let message: String
    
    var errorDescription: String? {
        return message
    }
}
