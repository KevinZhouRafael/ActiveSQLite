//
//  Utils.swift
//  ActiveSQLiteTests
//
//  Created by kai zhou on 18/01/2018.
//  Copyright © 2018 hereigns. All rights reserved.
//

import Foundation

let DBDefaultName = "TestDefaultDB"
let DBName2 = "OtherDB"
let DBNameCipher = "CipherDB"

//default db path
public func getTestDBPath() -> String?{
    
    NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/ActiveSQLite.db"
        //            dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + bundleName() + "-ActiveSQLite.db"
    if !FileManager.default.fileExists(atPath: dbPath) {
        FileManager.default.createFile(atPath: dbPath, contents: nil, attributes: nil)
//        LogInfo("Create db file success-\(dbPath)")
        
    }
    
    print(dbPath)
    return dbPath
}

public func getDB2Path() -> String{
    NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/ActiveSQLite2.db"

    if !FileManager.default.fileExists(atPath: dbPath) {
        FileManager.default.createFile(atPath: dbPath, contents: nil, attributes: nil)
        
    }
    
    print(dbPath)
    return dbPath
}

public func getDBCipherPath() -> String{
    NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/ActiveSQLiteCipher.db"
    
    if !FileManager.default.fileExists(atPath: dbPath) {
        FileManager.default.createFile(atPath: dbPath, contents: nil, attributes: nil)
        
    }
    
    print(dbPath)
    return dbPath
}
