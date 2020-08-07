//
//  Posts.swift
//  ZKORM
//
//  Created by Kevin Zhou on 09/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import GRDB
@testable import ZKORM

class Posts:ZKORMModel{
    
    var title:String = ""
    var user_id:NSNumber = NSNumber(value:0)
    
    static let title = Expression<String>("title")
    static let user_id = Expression<NSNumber>("user_id")
    
//    override class var isSaveDefaulttimestamp:Bool{
//        return true
//    }
    
}
