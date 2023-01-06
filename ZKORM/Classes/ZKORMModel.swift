//
//  ZKORMModel.swift
//  ZKORM
//
//  Created by Kevin Zhou on 05/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import GRDB

open class ZKORMModel:Record,ZKORMProtocol{

//    public internal(set) var id:Int64? //id primary key
    public var id:Int64? //id primary key
    public var created_at:Date? //Create Time, ms
    public var updated_at:Date? // Update Time，ms
    
    public static var CREATE_AT_KEY:String = "created_at"
    public static var UPDATE_AT_KEY:String = "updated_at"
    
//    public static var db:Database! //createtable之后，赋值。如果保存，使用时候会错误： database was not used on current thread.

    required public init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    required public override init() {
        super.init()
    }
    
    public init(id:Int64) {
        self.id = id
        super.init()
    }
    
    //MARK: sub class of Record
    public init(id: Int64?, created_at: Date?, updated_at: Date?) {
        self.id = id
        self.created_at = created_at
        self.updated_at = updated_at
        super.init()
    }
    
    /// The table name
    open override class var databaseTableName: String { nameOfTable }
    
    /// The table columns
    public enum Columns: String, ColumnExpression,CaseIterable {
        case id, created_at, updated_at
    }
    
//    open class var isAutoCreateRecordFromDB: Bool { true }
    
    /// Creates a record from a database row
    required public init(row: Row) throws{
        id = row[Columns.id]
        if Self.isSaveDefaulttimestamp{
            created_at = row[Columns.created_at]
            updated_at = row[Columns.updated_at]
        }
        
        //无法自动设置属性；除非用oc技术。
//        if Self.isAutoCreateRecordFromDB{
//            for case let (propertyName,column, value) in self.recursionProperties() {
//
//            }
//        }
        try super.init(row: row)
    }
    
    
    /// Auto Map func encode(to container: inout PersistenceContainer).
    /// if value is true, ignoe 'enum Columns: String, ColumnExpression,CaseIterable {' in sub class of ZKORMModel.
    open class var isAutoMapColumnPersistedInDB: Bool { true }
    /// The values persisted in the database
    open override func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        if Self.isSaveDefaulttimestamp{
            container[Columns.created_at] = created_at
            container[Columns.updated_at] = updated_at
        }
        
        if Self.isAutoMapColumnPersistedInDB{
            for case let (propertyName,column, value) in self.recursionProperties() {
                let mir = Mirror(reflecting:value)
                switch mir.subjectType {
                    
                case _ as String.Type:
                    container[column] = value as! String
                case _ as String?.Type:
                    container[column] = value as? String
                    
                case _ as Int.Type:
                    container[column] = value as! Int
                case _ as Int?.Type:
                    container[column] = value as? Int
                case _ as Int8.Type:
                    container[column] = value as! Int8
                case _ as Int8?.Type:
                    container[column] = value as? Int8
                case _ as Int16.Type:
                    container[column] = value as! Int16
                case _ as Int16?.Type:
                    container[column] = value as? Int16
                case _ as Int32.Type:
                    container[column] = value as! Int32
                case _ as Int32?.Type:
                    container[column] = value as? Int32
                case _ as Int64.Type:
                    container[column] = value as! Int64
                case _ as Int64?.Type:
                    container[column] = value as? Int64
                    
                case _ as UInt.Type:
                    container[column] = value as! UInt
                case _ as UInt?.Type:
                    container[column] = value as? UInt
                case _ as UInt8.Type:
                    container[column] = value as! UInt8
                case _ as UInt8?.Type:
                    container[column] = value as? UInt8
                case _ as UInt16.Type:
                    container[column] = value as! UInt16
                case _ as UInt16?.Type:
                    container[column] = value as? UInt16
                case _ as UInt32.Type:
                    container[column] = value as! UInt32
                case _ as UInt32?.Type:
                    container[column] = value as? UInt32
                case _ as UInt64.Type:
                    container[column] = value as! UInt64
                case _ as UInt64?.Type:
                    container[column] = value as? UInt64

                case _ as Double.Type:
                    container[column] = value as! Double
                case _ as Double?.Type:
                    container[column] = value as? Double
                case _ as Float.Type:
                    container[column] = value as! Float
                case _ as Float?.Type:
                    container[column] = value as? Float
                    
                case _ as Bool.Type:
                    container[column] = value as! Bool
                case _ as Bool?.Type:
                    container[column] = value as? Bool
                case _ as Date.Type:
                    container[column] = value as! Date
                case _ as Date?.Type:
                    container[column] = value as? Date
                    
                default: break
                    
                }
            }
        }
    }
    
    // Update auto-incremented id upon successful insertion
    open override func didInsert(_ inserted: InsertionSuccess) {
//        super.didInsert(inserted)
        id = inserted.rowID
    }
    
    open override func willInsert(_ db: Database) throws {
//        try validate()
        
        let currentDateInterval = Date()
        if created_at == nil{
            created_at = currentDateInterval
        }
        if updated_at == nil{
            updated_at = currentDateInterval
        }
        
//        try performInsert(db)
    }
    
    open override func willUpdate(_ db: Database, columns: Set<String>) throws {
//        try validate()
        
        updated_at = Date()
        
        var toUpdateColumns = columns
        if !toUpdateColumns.contains(Self.UPDATE_AT_KEY){
            toUpdateColumns.insert(Self.UPDATE_AT_KEY)
        }
            
//        try performUpdate(db, columns: toUpdateColumns)
    }
    
    //MARK: override
    open class var dbName:String?{
        return nil
    }
    
    open class var nameOfTable: String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    open class var PRIMARY_KEY:String{
        return "id"
    }
    
    open class var isSaveDefaulttimestamp:Bool {
        return false
    }
    
    open func differentPropertyColumnMapper() -> [String:String]{
//        var enumNameMap = [String:String]()
//        for column in Columns.allCases{
//            enumNameMap[String(describing: column)] = column.name //column.rawValue
//        }
//        return enumNameMap
        return [String:String]()
    }
    
    open func transientProperties() -> [String]{
        return [String]()
    }
    
    open func needAddIndexProperties() -> [String]{
        return []
    }
    
    open func uniqueProperties() -> [String]{
        return []
    }
    
    open var nameOfTable:String{
        get{
            return type(of: self).nameOfTable
        }
    }
    
    public class func getDBQueue() throws -> DatabaseQueue{
//        get{
            if let name = dbName {
                return try ZKORMConfigration.getDBQueue(name: name)
            }else{
                return try ZKORMConfigration.getDefaultDBQueue()
            }
            
//        }
    }
    
    public func getDBQueue() throws -> DatabaseQueue{
    //        get{
        return try type(of: self).getDBQueue()
    //        }
    }
    
//    public var db:Database{
//        return Self.db
//    }

}

extension ZKORMModel:CustomStringConvertible,CustomDebugStringConvertible{
    public var description: String{
        var des = "**ZKORMModel**：\(type(of: self)) -> "
        //        var des = "**DB Model**" + NSStringFromClass(type(of: self)) + "-> "
        for case let (attribute, column, value) in recursionProperties(){
            //            if attribute == "created_at" || attribute == "updated_at" {
            //                des += "\(attribute) = \((value as! NSNumber).int64Value), "
            //            }else{
            des += "\(attribute) = \(value), "
            //            }
        }
        return des
    }
    
    public var debugDescription: String{
        return description
    }
}

/*
// SQL generation
//extension ZKORMModel:TableRecord{
//    public static var databaseTableName: String{
//        return nameOfTable
//    }
//}
extension ZKORMModel: TableRecord {
    /// The table columns
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let created_at = Column(CodingKeys.created_at)
        static let updated_at = Column(CodingKeys.updated_at)
    }
}

// Fetching methods
extension ZKORMModel: FetchableRecord { }

// Persistence methods
extension ZKORMModel: PersistableRecord {
    public static var databaseTableName: String{
        return nameOfTable
    }
    
    // Update auto-incremented id upon successful insertion
    public func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    public func insert(_ db: Database) throws {
//        try validate()
        
        let currentDateInterval = Date()
        if created_at == nil{
            created_at = currentDateInterval
        }
        if updated_at == nil{
            updated_at = currentDateInterval
        }
        
        try performInsert(db)
    }
    
    public func update(_ db: Database, columns: Set<String>) throws {
//        try validate()
        
        let currentDateInterval = Date()
        if updated_at == nil{
            updated_at = currentDateInterval
        }
        try performUpdate(db, columns: columns)
    }
    
//    func validate() throws {
//        if url.host == nil {
//            throw ValidationError("url must be absolute.")
//        }
//    }
}

extension ZKORMModel:MutablePersistableRecord{
    public func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.created_at] = created_at
        container[Columns.updated_at] = updated_at
    }
}
*/
