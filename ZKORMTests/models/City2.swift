//
//  City2.swift
//  ZKORMTests
//
//  Created by kai zhou on 19/01/2018.
//  Copyright © 2018 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import GRDB
@testable import ZKORM

class City2: ZKORMModel {
    var code:String = ""
    var name:String = ""
    
    
    override class var nameOfTable: String{
        return "City"
    }
    
    override class var dbName:String?{
        return DBName2
    }
    
    override class var isSaveDefaulttimestamp:Bool{
        return true
    }
    
    required init(row: Row) {
        super.init(row: row)
        name = row[Column("name")]
        code = row[Column("code")]
    }
    
    required init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container[Column("name")] = name
        container[Column("code")] = code
        super.encode(to: &container)
    }
    
}
