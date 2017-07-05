//
//  ActiveSQLite.swift
//  ActiveSQLite
//
//  Created by zhou kai  on 04/07/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import SQLite

func save(_ block: @escaping ()throws -> Void,
          completion: @escaping (_ error:Error?)->Void) -> Void  {
    
    do{
        try ASConnection.sharedConnection.db.transaction {
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
            try ASConnection.sharedConnection.db.transaction {
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


//project name
func bundleName() -> String{
    var bundlePath = Bundle.main.bundlePath
    bundlePath = bundlePath.components(separatedBy: "/").last!
    bundlePath = bundlePath.components(separatedBy: "/").first!
    return bundlePath
}

//class name -> AnyClass
func getClass(name:String) ->AnyClass?{
    let type = bundleName() + "." + name
    return NSClassFromString(type)
}

//MARK: - Extension
extension NSNumber : SQLite.Value {
    public static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    
    public static func fromDatatypeValue(_ datatypeValue: Int64) -> NSNumber {
        return NSNumber(value:datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
    
}

//Date -- Tnteger
extension NSDate: SQLite.Value {
    public static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    public static func fromDatatypeValue(_ intValue: Int64) -> NSDate {
        return NSDate(timeIntervalSince1970: TimeInterval(intValue))
    }
    public var datatypeValue: Int64 {
        return  Int64(timeIntervalSince1970)
    }
}
