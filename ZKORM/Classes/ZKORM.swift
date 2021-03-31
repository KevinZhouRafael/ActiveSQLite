//
//  ZKORM.swift
//  ZKORM
//
//  Created by Kevin Zhou  on 04/07/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import GRDB

public func dbQueue() throws -> DatabaseQueue{
    try ZKORMConfigration.getDefaultDBQueue()
}

public  func save(dbQueue:DatabaseQueue? = nil, _ block: @escaping (GRDB.Database)throws -> Void,
                        completion: ((_ error:Error?)->Void)? = nil) -> Void  {
    
    do{
        
        
        let excuteQueue = (dbQueue != nil ? dbQueue! : try ZKORMConfigration.getDefaultDBQueue())
        
        try excuteQueue.inDatabase { (db) in
            try db.inTransaction {
                try block(db)
                return .commit
            }
        }
        
        Log.i("Transcation success")
        completion?(nil)
    }catch{
        Log.e("Transcation failure:\(error)")
        completion?(error)
    }
    
}


public  func saveAsync(dbQueue:DatabaseQueue? = nil, _ block: @escaping (GRDB.Database)throws -> Void,
                             completion: ((_ error:Error?)->Void)? = nil) -> Void  {
    
    let excuteQueue = (dbQueue != nil ? dbQueue! : try! ZKORMConfigration.getDefaultDBQueue())
    
    excuteQueue.asyncWriteWithoutTransaction { db in
        do {
            try db.inTransaction {
                try block(db)
                return .commit
            }
            Log.i("Transcation success")
            DispatchQueue.main.async {
                completion?(nil)
            }
        } catch {

            Log.i("Transcation failure:\(error)")
            
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
    
//    DispatchQueue.global().async {
//
//        do{
//            let excuteQueue = (dbQueue != nil ? dbQueue! : try DBConfigration.getDefaultDBQueue())
//
//            //            try excuteDB.transaction(.exclusive, block: {
//            //                try block()
//            //            })
//
//            try excuteQueue.asyncWrite({ db in
//                try block(db)
//            }, completion: { (db: Database, result: Result<Void, Error>) in
//                switch result {
//                case let .success:
//                    Log.i("Transcation success")
//
//                    DispatchQueue.main.async {
//                        completion?(nil)
//                    }
//                case let .failure(error):
//                    Log.i("Transcation failure:\(error)")
//
//                    DispatchQueue.main.async {
//                        completion?(error)
//                    }
//                }
//            })
//
//
//        }catch{
//            Log.e("Transcation failure:\(error)")
//
//            DispatchQueue.main.async {
//                completion?(error)
//            }
//        }
//
//    }
    
}

public func read(dbQueue:DatabaseQueue? = nil, _ block: (Database) throws -> ()) throws{
    let excuteQueue = (dbQueue != nil ? dbQueue! : try ZKORMConfigration.getDefaultDBQueue())
    try excuteQueue.read{ db in
        try block(db)
    }
}

//public extension DatabaseQueue {
//    //userVersion Database
//    var userVersion: Int32 {
//        get { return Int32(try! scalar("PRAGMA user_version") as! Int64)}
//        set { try! run("PRAGMA user_version = \(newValue)") }
//    }
//}

