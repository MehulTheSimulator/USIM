//
//  Date.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

extension Date {
    
    // set date formatting in dd month and yeas
    func dateFormatting() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let outputString = dateFormatter.string(from: self)
        print(outputString) // Output: "25 August 2023"
        return outputString
    }
    
}
