//
//  Posts.swift
//  ActiveSQLite
//
//  Created by zhou kai on 09/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import SQLite
@testable import ActiveSQLite

class Posts:DBModel{
    
    var title:String!
    var user_id:NSNumber!
    
    static let title = Expression<String>("title")
    static let user_id = Expression<NSNumber>("user_id")
    
    
}
