//
//  ASProtocolSchame.swift
//  ZKORM
//
//  Created by Kevin Zhou on 08/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import GRDB


public protocol CreateColumnsProtocol {
    func createColumns(t:TableDefinition)
}

public extension ZKORMProtocol where Self:ZKORMModel{
    
    func createTable()throws{
        do{
            try getDBQueue().inDatabase{ db in
                try createTable(db)
            }
            
            Log.i("Create  Table \(nameOfTable) success")
        }catch let e{
            Log.e("Create  Table \(nameOfTable)failure：\(e.localizedDescription)")
            throw e
        }
        
    }
    static func createTable()throws{
        try self.init().createTable()
    }
    
    static func createTable(_ db:GRDB.Database) throws{
        try self.init().createTable(db)
    }
    
    func createTable(_ db:GRDB.Database) throws{
        if try !db.tableExists(nameOfTable){
            try db.create(table: nameOfTable,ifNotExists:true){ t in
                if self is CreateColumnsProtocol {
                    (self as! CreateColumnsProtocol).createColumns(t: t)
                }else{
                    autoCreateColumns(t)
                }
                
                //                let s = recusionProperties(t)
                //                (s["definitions"] as! [Expressible]).count
                //
                //                let create1: Method = class_getClassMethod(self, #selector(ZKORMModel.createTable))
                //                let create2: Method = class_getClassMethod(self, #selector(self.createTable))
                //
            }
            
//                    Self.db = db
            
            if self is CreateColumnsProtocol {
                
            }else{
                try! autoCreateIndexs(db)
            }
        }
    }
    static func afterCreateTable(db:GRDB.Database){
        
    }
    
    static func dropTable() throws{
        try getDBQueue().inDatabase { db in
            try db.drop(table: nameOfTable)
        }
    }
    
    internal func autoCreateIndexs(_ db:GRDB.Database) throws{
        for case let (propertyName,columnName, value) in self.recursionProperties() {
            if propertyName == primaryKeyPropertyName {
                continue
            }
            try db.create(index: "indexBy\(propertyName)On\(nameOfTable)", on: nameOfTable, columns: [columnName])
//            try db.create(index: "indexBy\(propertyName)", on: nameOfTable, columns: [columnName],unique: true)
        }
    }
    
    internal  func autoCreateColumns(_ t:TableDefinition){
        //        let uniques = uniqueProperties()
                
        for case let (propertyName,column, value) in self.recursionProperties() {
                    
        //            let isUnique:Bool = uniqueProperties().contains(propertyName)
        //            var columnDefinition:ColumnDefinition!
                    
            //check primaryKey
            if propertyName == primaryKeyPropertyName {
                t.autoIncrementedPrimaryKey(column)
                continue
            }
            
            let mir = Mirror(reflecting:value)
            switch mir.subjectType {
                
            case _ as String.Type:
                t.column(column, .text).notNull().defaults(to: "")
            case _ as String?.Type:
                t.column(column, .text)
                
            case _ as Int.Type,
                 _ as Int8.Type,
                 _ as Int16.Type,
                 _ as Int32.Type,
                 _ as Int64.Type,
                 _ as UInt.Type,
                 _ as UInt8.Type,
                 _ as UInt16.Type,
                 _ as UInt32.Type,
                 _ as UInt64.Type:
                if propertyName == primaryKeyPropertyName {
                     t.autoIncrementedPrimaryKey(column)
                }else{
//                    if uniqueProperties().contains(propertyName) {
//                        t.column(column, .integer).notNull().defaults(to: 0).unique()
//                    }else{
                        t.column(column, .integer).notNull().defaults(to: 0)
//                    }
                }
            case _ as Int?.Type,
                _ as Int8?.Type,
                _ as Int16?.Type,
                _ as Int32?.Type,
                _ as Int64?.Type,
                _ as UInt?.Type,
                _ as UInt8?.Type,
                _ as UInt16?.Type,
                _ as UInt32?.Type,
                _ as UInt64?.Type:
                if propertyName == primaryKeyPropertyName {
                     t.autoIncrementedPrimaryKey(column)
                }else{
                    t.column(column, .integer)
                }
            
            case _ as Double.Type,
                 _ as Float.Type:
                t.column(column, .double).notNull().defaults(to: 0.0)
            case _ as Double?.Type,
                 _ as Float?.Type:
                t.column(column, .double)
                
            case _ as Bool.Type:
                t.column(column, .boolean).notNull().defaults(to: false)
            case _ as Bool?.Type:
                t.column(column, .boolean)
                
            case _ as Date.Type:
                t.column(column, .datetime).notNull().defaults(to: Date(timeIntervalSince1970: 0))
            case _ as Date?.Type:
                t.column(column, .datetime)
                
            default: break
                
            }
            
        }
    }
    
}


