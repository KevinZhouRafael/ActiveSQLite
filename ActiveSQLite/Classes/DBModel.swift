//
//  DBModel.swift
//  ActiveSQLite
//
//  Created by kai zhou on 05/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import SQLite

/*
Model Type    SQLite.swift Type      SQLite Type
NSNumber    Int64(Int,Bool)         INTEGER
NSNumber    Double                  REAL
String      String                  TEXT
nil         nil                     NULL
            SQLite.Blob†	        BLOB //not used
 */

open class DBModel: NSObject{

    var id:NSNumber! //id primary key
    var created_at:NSNumber! //Create Time, ms
    var updated_at:NSNumber! // Update Time，ms

    
    static var id = Expression<NSNumber>("id")
    static let created_at = Expression<NSNumber>("created_at")
    static let updated_at = Expression<NSNumber>("updated_at")
    
    var created_date:NSDate! {
        set{
            created_at = NSNumber(value:newValue.timeIntervalSince1970 * 1000)
        }
        get{
            return NSDate(timeIntervalSince1970: TimeInterval(created_at.int64Value/1000))
        }
    }
    var updated_date:NSDate! {
        set{
            updated_at = NSNumber(value:newValue.timeIntervalSince1970 * 1000)
        }
        get{
            return NSDate(timeIntervalSince1970: TimeInterval(updated_at.int64Value/1000))
        }
    }
    
    
    //T? == Optional<T>
    //T! == ImplicitlyUnwrappedOptional<T>
    static var db:Connection!{
        get{
            return DBConnection.sharedConnection.db
        }
    }
    var _query:QueryType?
    
    required override public init() {
        super.init()
    }
    
    class func doubleTypeProperties() -> [String]{
        return [String]()
    }
    
    class func mapper() -> [String:String]{
        return [String:String]()
    }
    
    func recursionProperties() -> [(String?,Any)]{
        
        var properties = [(String?,Any)]()
        var mirror: Mirror? = Mirror(reflecting: self)
        repeat {
            for case let (key?, value) in mirror!.children {
                
                let mir = Mirror(reflecting:value)
                
                switch mir.subjectType {
                    
                case _ as String.Type, _ as  ImplicitlyUnwrappedOptional<String>.Type,_ as String?.Type,_ as NSNumber.Type, _ as  ImplicitlyUnwrappedOptional<NSNumber>.Type,_ as NSNumber?.Type,
                     _ as NSDate.Type, _ as ImplicitlyUnwrappedOptional<NSDate>.Type,_ as NSDate?.Type:
                    
                    properties.append((key, value))
                    
                    break
              
                default: break
                    
                }
                
            }
            mirror = mirror?.superclassMirror
        } while mirror != nil
        
        
        return properties.sorted(by: {
            if $0.0 == "id" {
                return true
            }
            return $0.0! < $1.0!
        } )
    }
    
    func recursionPropertiesOnlyColumn() -> [(String?,Any)]{
        
        var properties = [(String?,Any)]()
        var mirror: Mirror? = Mirror(reflecting: self)
        repeat {
            for case let (key?, value) in mirror!.children {
                
                let mir = Mirror(reflecting:value)
                
                switch mir.subjectType {
                    
                case _ as String.Type, _ as  ImplicitlyUnwrappedOptional<String>.Type,_ as String?.Type,_ as NSNumber.Type, _ as  ImplicitlyUnwrappedOptional<NSNumber>.Type,_ as NSNumber?.Type,
                     _ as NSDate.Type, _ as ImplicitlyUnwrappedOptional<NSDate>.Type,_ as NSDate?.Type:
                    
                    if let column = (type(of:self)).mapper()[key] {
                        properties.append((column, value))
                    }else{
                        properties.append((key, value))
                    }
                    
                    
                    break
                    
                default: break
                    
                }
                
            }
            mirror = mirror?.superclassMirror
        } while mirror != nil
        
        
        return properties.sorted(by: {
            if $0.0 == "id" {
                return true
            }
            return $0.0! < $1.0!
        } )
    }
    
    func recursionPropertiesWithMapper() -> [(String?,String?,Any)]{
        
        var properties = [(String?,String?,Any)]()
        var mirror: Mirror? = Mirror(reflecting: self)
        repeat {
            for case let (key?, value) in mirror!.children {
                
                let mir = Mirror(reflecting:value)
                
                switch mir.subjectType {
                    
                case _ as String.Type, _ as  ImplicitlyUnwrappedOptional<String>.Type,_ as String?.Type,_ as NSNumber.Type, _ as  ImplicitlyUnwrappedOptional<NSNumber>.Type,_ as NSNumber?.Type,
                     _ as NSDate.Type, _ as ImplicitlyUnwrappedOptional<NSDate>.Type,_ as NSDate?.Type:
                    
                    if let column = (type(of:self)).mapper()[key] {
                        properties.append((key, column, value))
                    }else{
                        properties.append((key, key, value))
                    }
                    
                    
                    break
                    
                default: break
                    
                }
                
            }
            mirror = mirror?.superclassMirror
        } while mirror != nil
        
        
        return properties.sorted(by: {
            if $0.0 == "id" {
                return true
            }
            return $0.0! < $1.0!
        } )
    }

    
    
       
    override open var description: String{
        var des = "**DB Model**：" + super.description + "->"
        //        var des = "**DB Model**" + NSStringFromClass(type(of:self)) + "-> "
        
        for case let (key?, value) in recursionProperties(){
            des += "\(key) = \(value), "
        }
        return des
    }
    
}


