//
//  City.swift
//  ActiveSQLiteTests
//
//  Created by kai zhou on 19/01/2018.
//  Copyright © 2018 hereigns. All rights reserved.
//

import Foundation
import SQLite
@testable import ActiveSQLite

class City: ASModel {
    @objc var code:String = ""
    @objc var name:String = ""
    
    override class var isSaveDefaulttimestamp:Bool{
        return true
    }
    
}
