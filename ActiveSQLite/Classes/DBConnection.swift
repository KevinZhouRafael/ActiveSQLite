//
//  DBConnection.swift
//  ActiveSQLite
//
//  Created by zhou kai on 04/07/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import SQLite

open class DBConnection {
    
    static let sharedConnection: DBConnection = DBConnection()
    
    var db:Connection!
    
    private  init() {
        
        let dbPath = DBConfigration.getDBPath()!
        
        LogInfo(dbPath)
        db = try! Connection(dbPath)
        
        //        #if DEBUG
        //            DBModel.db.trace{ debugPrint($0)}
        //        #endif
        
        if DBConfigration.logLevel == .debug {
            db.trace{ print($0)}
        }
        
    }
    
    //    class func getDB() -> Connection{
    //        let db =  try! Connection(ASConfigration.getDBPath()!)
    //        return db
    //    }
    
    //    func dataBaseFilePath()->String{
    //
    //        let fileManager = FileManager.default
    //
    //        let dbFilePath = "\(NSHomeDirectory())/Documents/ActiveSQLite.db"
    //
    //        if !fileManager.fileExists(atPath: dbFilePath) {
    //            let resourcePath = Bundle.main.path(forResource: "ActiveSQLite", ofType: "db")
    //            do{
    //                try fileManager.copyItem(atPath: resourcePath!, toPath: dbFilePath)
    //
    //            }catch{
    //
    //            }
    //
    //        }
    //
    //        return dbFilePath
    //    }
    
}

public extension Connection {
    //userVersion Database
    public var userVersion: Int32 {
        get { return Int32(try! scalar("PRAGMA user_version") as! Int64)}
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}
