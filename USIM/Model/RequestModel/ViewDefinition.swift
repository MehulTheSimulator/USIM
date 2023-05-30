//
//  ViewDefinition.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class ViewDefinition : Codable {
    
    public var id: Int
    public var modeid: Int
    public var viewname: String
    
    init(id: Int, modeid: Int, viewname: String) {
        self.id = id
        self.modeid = modeid
        self.viewname = viewname
    }
}
