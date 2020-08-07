//
//  ZKORMProtocol.swift
//  ZKORM
//
//  Created by kai zhou on 2018/5/28.
//  Copyright © 2018 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import GRDB

public protocol ZKORMProtocol:class {
    
}

//extension ZKORMProtocol:TableRecord{
//    static var databaseTableName: String {
//        return ""
//    }
//}
public extension ZKORMProtocol where Self:ZKORMModel{
    internal var primaryKeyPropertyName:String{
        return "id"
    }
    
    internal func noSavedProperties() -> [String]{
        if type(of: self).isSaveDefaulttimestamp{
            return transientTypes()
        }else{
            return transientTypes() + [type(of: self).CREATE_AT_KEY,type(of: self).UPDATE_AT_KEY]
        }
    }

    
    //MARK: Utils
    static func read<T>(_ block: (Database) throws-> T) throws  -> T{
        return try getDBQueue().read{ db in
            try block(db)
        }
    }
    static func write<T>(_ updates: (Database) throws -> T) throws -> T {
        return try getDBQueue().write({ db in
            try updates(db)
        })
    }
    
}




