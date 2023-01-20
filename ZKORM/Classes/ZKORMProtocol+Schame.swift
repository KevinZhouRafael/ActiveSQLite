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
                try! autoCreateUniqueIndices(db)
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
    
    internal  func autoCreateColumns(_ t:TableDefinition){
        //        let uniques = uniqueProperties()
                
        for case let (propertyName,column, value) in self.recursionProperties() {
                    
            var columnDefinition:ColumnDefinition!
                    
            //check primaryKey
            if propertyName == primaryKeyPropertyName {
                t.autoIncrementedPrimaryKey(column)
                continue
            }
            
            let mir = Mirror(reflecting:value)
            switch mir.subjectType {
                
            case _ as String.Type:
                columnDefinition = t.column(column, .text).notNull().defaults(to: "")
            case _ as String?.Type:
                columnDefinition = t.column(column, .text)
                
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
                    columnDefinition = t.autoIncrementedPrimaryKey(column)
                }else{
//                    if uniqueProperties().contains(propertyName) {
//                        t.column(column, .integer).notNull().defaults(to: 0).unique()
//                    }else{
                    columnDefinition = t.column(column, .integer).notNull().defaults(to: 0)
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
                    columnDefinition = t.autoIncrementedPrimaryKey(column)
                }else{
                    columnDefinition = t.column(column, .integer)
                }
            
            case _ as Double.Type,
                 _ as Float.Type:
                columnDefinition = t.column(column, .double).notNull().defaults(to: 0.0)
            case _ as Double?.Type,
                 _ as Float?.Type:
                columnDefinition = t.column(column, .double)
                
            case _ as Bool.Type:
                columnDefinition = t.column(column, .boolean).notNull().defaults(to: false)
            case _ as Bool?.Type:
                columnDefinition = t.column(column, .boolean)
                
            case _ as Date.Type:
                columnDefinition = t.column(column, .datetime).notNull().defaults(to: Date(timeIntervalSince1970: 0))
            case _ as Date?.Type:
                columnDefinition = t.column(column, .datetime)
                
            default: break
                
            }
            
            let isUnique:Bool = uniqueProperties().contains(propertyName)
            if isUnique{
                columnDefinition.unique()
            }
        }
    }
    
    internal func autoCreateIndexs(_ db:GRDB.Database) throws{
        let indexProperties = needAddIndexProperties()
        guard indexProperties.count > 0 else {
            return
        }

        for case let (propertyName,columnName, value) in self.recursionProperties() {
            if propertyName == primaryKeyPropertyName {
                continue
            }
            if [ZKORMModel.CREATE_AT_KEY,ZKORMModel.UPDATE_AT_KEY].contains(propertyName){
                try db.create(index: "indexBy\(propertyName)On\(nameOfTable)", on: nameOfTable, columns: [columnName])
                continue
            }
            
            for indexProperty in indexProperties {
                if indexProperty == propertyName {
                    try db.create(index: "indexBy\(propertyName)On\(nameOfTable)", on: nameOfTable, columns: [columnName])
        //            try db.create(index: "indexBy\(propertyName)", on: nameOfTable, columns: [columnName],unique: true)
                }
            }
        }
    }
    
    internal func autoCreateUniqueIndices(_ db:GRDB.Database) throws{
        let indicesProperties = uniqueIndices()
        guard indicesProperties.count > 0 else {
            return
        }

        let propertyColumnDic = propertyColumnDic()
        for oneIndex in indicesProperties{
            let indexName = oneIndex.joined(separator: "_")
            let colunmNames = oneIndex.compactMap{propertyColumnDic[$0]}
            try db.create(index: "uniqueIndicesBy\(indexName)On\(nameOfTable)", on: nameOfTable, columns: colunmNames,unique: true)
        }
    }
    
    internal func propertyColumnDic() -> [String:String]{
        var dic = [String:String]()
        for case let (propertyName,columnName, value) in self.recursionProperties() {
            dic[propertyName] = columnName
        }
        return dic
    }
}


