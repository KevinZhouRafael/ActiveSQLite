//
//  DBModel.swift
//  ActiveSQLite
//
//  Created by zhou kai on 05/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import SQLite

protocol ASModel:class {
    
}
/*
 Model Type    SQLite.swift Type      SQLite Type
 NSNumber    Int64(Int,Bool)         INTEGER
 NSNumber    Double                  REAL
 String      String                  TEXT
 nil         nil                     NULL
 --------    SQLite.Blob†             BLOB
 NSDate      Int64                   INTEGER
 */


@objc open class DBModel: NSObject,ASModel{
    
    @objc public var id:NSNumber! //id primary key
    @objc public var created_at:NSNumber! //Create Time, ms
    @objc public var updated_at:NSNumber! // Update Time，ms
    
    public static var id = Expression<NSNumber>(PRIMARY_KEY)
    public static var created_at = Expression<NSNumber>(CREATE_AT_KEY)
    public static var updated_at = Expression<NSNumber>(UPDATE_AT_KEY)
    
    public static var CREATE_AT_KEY:String = "created_at"
    public static var UPDATE_AT_KEY:String = "updated_at"
    
    internal var _query:QueryType?
    
    required override public init() {
        super.init()
    }
    
    //MARK: override
    open class var dbName:String?{
        return nil
    }
    
    open class var PRIMARY_KEY:String{
        return "id"
    }
    
    open class var isSaveDefaulttimestamp:Bool {
        return false
    }
    
    open func doubleTypes() -> [String]{
        return [String]()
    }
    
    open func mapper() -> [String:String]{
        return [String:String]()
    }
    
    open func transientTypes() -> [String]{
        return [String]()
    }
    
    
    //MARK: - getter setter
    //T? == Optional<T>
    //T! == ImplicitlyUnwrappedOptional<T>
    public var created_date:NSDate! {
        set{
            created_at = NSNumber(value:newValue.timeIntervalSince1970 * 1000)
        }
        get{
            return NSDate(timeIntervalSince1970: TimeInterval(created_at.int64Value/1000))
        }
    }
    public var updated_date:NSDate! {
        set{
            updated_at = NSNumber(value:newValue.timeIntervalSince1970 * 1000)
        }
        get{
            return NSDate(timeIntervalSince1970: TimeInterval(updated_at.int64Value/1000))
        }
    }
    
    public class var nameOfTable: String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public var nameOfTable:String{
        get{
            return type(of: self).nameOfTable
        }
    }
    
    class var db:Connection!{
        get{
            if let name = dbName {
                return DBConfigration.getDB(name: name)
            }else{
                return DBConfigration.getDefaultDB()
            }
            
        }
    }
    
    public var db:Connection!{
        get{
            return type(of: self).db
        }
    }
    public class func getTable() -> Table{
        return Table(nameOfTable)
    }
    
    public func getTable() -> Table{
        return type(of: self).getTable()
    }
    
    @objc open override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
    
    @objc open override func value(forKey key: String) -> Any? {
        return super.value(forKey: key)
    }
    
    //MARK: - utils
    internal var primaryKeyAttributeName:String{
        return "id"
    }
    
    internal func noSavedProperties() -> [String]{
        if type(of: self).isSaveDefaulttimestamp{
            return transientTypes()
        }else{
            return transientTypes() + [type(of: self).CREATE_AT_KEY,type(of: self).UPDATE_AT_KEY]
        }
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
                    
                    if let column = mapper()[key] {
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
            if $0.0 ==  primaryKeyAttributeName {
                return true
            }
            return $0.0! < $1.0!
        } )
    }
    
    func recursionProperties() -> [(String?,String?,Any)]{
        
        var properties = [(String?,String?,Any)]()
        var mirror: Mirror? = Mirror(reflecting: self)
        repeat {
            for case let (attribute?, value) in mirror!.children {
                
                if noSavedProperties().contains(attribute){
                    continue
                }
                
                let mir = Mirror(reflecting:value)
                
                switch mir.subjectType {
                    
                case _ as String.Type, _ as  ImplicitlyUnwrappedOptional<String>.Type,_ as String?.Type,_ as NSNumber.Type, _ as  ImplicitlyUnwrappedOptional<NSNumber>.Type,_ as NSNumber?.Type,
                     _ as NSDate.Type, _ as ImplicitlyUnwrappedOptional<NSDate>.Type,_ as NSDate?.Type:
                    
                    
                    if let column = mapper()[attribute] {
                        properties.append((attribute, column, value))
                    }else{
                        properties.append((attribute, attribute, value))
                    }
                    
                    
                    break
                    
                default: break
                    
                }
                
            }
            mirror = mirror?.superclassMirror
        } while mirror != nil
        
        return properties.sorted(by: {
            if $0.0 == primaryKeyAttributeName {
                return true
            }
            return $0.0! < $1.0!
        } )
    }
    
    func propertieColumnMap() -> [String:String]{
        
        var pcMap = [String:String]()
        var mirror: Mirror? = Mirror(reflecting: self)
        repeat {
            for case let (key?, value) in mirror!.children {
                
                if noSavedProperties().contains(key)  {
                    continue
                }
                
                let mir = Mirror(reflecting:value)
                
                switch mir.subjectType {
                    
                case _ as String.Type, _ as  ImplicitlyUnwrappedOptional<String>.Type,_ as String?.Type,_ as NSNumber.Type, _ as  ImplicitlyUnwrappedOptional<NSNumber>.Type,_ as NSNumber?.Type,
                     _ as NSDate.Type, _ as ImplicitlyUnwrappedOptional<NSDate>.Type,_ as NSDate?.Type:
                    
                    if let column = mapper()[key] {
                        pcMap[key] = column
                    }else{
                        pcMap[key] = key
                    }
                    
                    
                    break
                    
                default: break
                    
                }
                
            }
            mirror = mirror?.superclassMirror
        } while mirror != nil
        
        
        return pcMap
    }
    
    
    override open var description: String{
        var des = "**DB Model**：" + super.description + "->"
        //        var des = "**DB Model**" + NSStringFromClass(type(of: self)) + "-> "
        
        for case let (attribute?, column?, value) in recursionProperties(){
            //            if attribute == "created_at" || attribute == "updated_at" {
            //                des += "\(attribute) = \((value as! NSNumber).int64Value), "
            //            }else{
            des += "\(attribute) = \(value), "
            //            }
            
        }
        return des
    }
    
}
