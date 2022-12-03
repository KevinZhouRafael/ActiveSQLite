//
//  Users.swift
//  ZKORM
//
//  Created by Kevin Zhou on 09/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import GRDB
@testable import ZKORM

class Users:ZKORMModel,CreateColumnsProtocol{
    
    var name:String = "String"
    
    func createColumns(t: TableDefinition) {
        t.autoIncrementedPrimaryKey("id")
        t.column("name", .text).notNull().defaults(to: "")
        t.column("created_at", .datetime).notNull().defaults(to: Date(timeIntervalSince1970: 0))
        t.column("updated_at", .datetime).notNull().defaults(to: Date(timeIntervalSince1970: 0))
    }
    
    override class var isSaveDefaulttimestamp:Bool{
        return true
    }
    
    required init(row: Row) throws{
        try super.init(row: row)
        name = row["name"]
    }
    
    required init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container["name"] = name
        super.encode(to: &container)
    }
}
