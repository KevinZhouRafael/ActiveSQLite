//
//  City.swift
//  ZKORMTests
//
//  Created by kai zhou on 19/01/2018.
//  Copyright © 2018 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import GRDB
@testable import ZKORM

class City: ZKORMModel {
    var code:String = ""
    var name:String = ""
    
    enum Columns: String, ColumnExpression,CaseIterable {
        case name
        case code
    }
    
    required init(row: Row)throws {
        try super.init(row: row)
        name = row[Columns.name]
        code = row[Columns.code]
        
    }
    
    required init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container[Columns.name] = name
        container[Columns.code] = code
        
        super.encode(to: &container)
    }
    override class var isSaveDefaulttimestamp:Bool{
        return true
    }
}
