//
//  Users.swift
//  ActiveSQLite
//
//  Created by kai zhou on 09/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import SQLite
@testable import ActiveSQLite

class Users:DBModel{
    
    var name:String!
        
    static let name = Expression<String>("name")

    
}
