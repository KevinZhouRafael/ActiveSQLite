//
//  ActiveSQLite.swift
//  ActiveSQLite
//
//  Created by kai zhou  on 04/07/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import SQLite

func save(_ block: @escaping ()throws -> Void,
          completion: @escaping (_ error:Error?)->Void) -> Void  {
    
    do{
        try DBConnection.sharedConnection.db.transaction {
             try block()
        }
        
        LogInfo("Transcation success")
        completion(nil)
    }catch{
        LogError("Transcation failure:\(error)")
        completion(error)
    }

    
    
}


func saveAsync(_ block: @escaping ()throws -> Void,
               completion: @escaping (_ error:Error?)->Void) -> Void  {
    
    DispatchQueue.global().async {
        
        do{
            try DBConnection.sharedConnection.db.transaction {
                try block()
            }
            
            LogInfo("Transcation success")
            
            DispatchQueue.main.async {
                completion(nil)
            }
            
        }catch{
            LogError("Transcation failure:\(error)")
            
            DispatchQueue.main.async {
                completion(error)
            }
        }

    }
    
}
