//
//  CityCipher.swift
//  ActiveSQLiteTests
//
//  Created by kai zhou on 2018/6/19.
//  Copyright © 2018 hereigns. All rights reserved.
//

import Foundation
import SQLite
@testable import ActiveSQLite

class CityCipher: ASModel {
    @objc var code:String!
    @objc var name:String!
    
    
    override class var nameOfTable: String{
        return "City"
    }
    
    override class var dbName:String?{
        return DBNameCipher
    }
    
    override class var isSaveDefaulttimestamp:Bool{
        return true
    }
    
}
