//
//  DBModel+Schame.swift
//  ActiveSQLite
//
//  Created by kai zhou on 08/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import SQLite

public extension DBModel{
    
//    func initDB(){
//        db = DBConnection.sharedConnection.db
//    }
    
    

    
    class var nameOfTable: String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    // use nameOfTable
    func tableName() -> String{
        return type(of: self).nameOfTable
//        return NSStringFromClass(type(of:self)).components(separatedBy: ".").last!
    }

     func createTable(){
        type(of: self).createTable()
    }
     class func createTable(){
        do{
            try db.run(Table(nameOfTable).create(ifNotExists: true) { t in
                
                for case let (attribute?,column?, value) in self.init().recursionProperties() {
                    
                    let mir = Mirror(reflecting:value)
                    
                    switch mir.subjectType {
                        
                    case _ as String.Type, _ as  ImplicitlyUnwrappedOptional<String>.Type:
                        t.column(Expression<String>(column), defaultValue: "")
                    case _ as String?.Type:
                        t.column(Expression<String?>(column))
                        
                        
                    case _ as NSNumber.Type, _ as  ImplicitlyUnwrappedOptional<NSNumber>.Type:
                        
                        if doubleTypeProperties().contains(attribute) {
                            t.column(Expression<Double>(column), defaultValue: 0.0)
                        }else{
                            
                            if attribute == "id" {
                                t.column(Expression<NSNumber>(column), primaryKey: .autoincrement)
                            }else{
                                t.column(Expression<NSNumber>(column), defaultValue: 0)
                            }
                            
                        }
                        
                    case _ as NSNumber?.Type:
                        
                        if doubleTypeProperties().contains(attribute) {
                            t.column(Expression<Double?>(column))
                        }else{
                            t.column(Expression<NSNumber?>(column))
                        }
                        
                    case _ as NSDate.Type, _ as  ImplicitlyUnwrappedOptional<NSDate>.Type:
                        t.column(Expression<NSDate>(column), defaultValue: NSDate(timeIntervalSince1970: 0))
                    case _ as NSDate?.Type:
                        t.column(Expression<NSDate?>(column))
                        
                    default: break
                        
                    }
                    
                }
                
                
            })
            
            LogInfo("Create  Table \(nameOfTable) success")
        }catch let e{
            LogError("Create  Table \(nameOfTable)failure：\(e.localizedDescription)")
        }
        
    }
    
     class func dropTable()->Bool{
        do{
            try db.run(Table(nameOfTable).drop(ifExists: true))
            LogInfo("Delete  Table \(nameOfTable) success")
            return true
        }catch{
            LogError("Delete  Table \(nameOfTable)failure：\(error.localizedDescription)")
            return false
        }
        
    }

    //MARK: - Alter Table
    //MARK: - Rename Table
     class func renameTable(oldName:String, newName:String)->Bool{
        do{
            try db.run(Table(oldName).rename(Table(newName)))
            LogInfo("alter name of table from \(oldName) to \(newName) success")
            return true
            
        }catch{
            LogError("alter name of table from \(oldName) to \(newName) failure：\(error.localizedDescription)")
            return false
        }
        
    }
    
    //MARK: - Add Column
     class func addColumn(_ columnNames:[String]) -> Bool {
        do{
            try self.db.transaction {
                let t = Table(nameOfTable)
                
                for columnName in columnNames {
                    try self.db.run(addColumnReturnSQL(t: t, columnName: columnName)!)
                }

            }
           
            LogInfo("Add \(columnNames) columns to \(nameOfTable) table success")
            return true
            
        }catch{
            LogError("Add \(columnNames) columns to \(nameOfTable) table failure")
            return false
        }
    }
    
    private class func addColumnReturnSQL(t:Table,columnName newAttributeName:String)->String?{
        for case let (attribute?,column?, value) in self.init().recursionProperties() {
            
            if newAttributeName != attribute {
                continue
            }
            
            
            let mir = Mirror(reflecting:value)
            
            switch mir.subjectType {
                
            case _ as String.Type, _ as  ImplicitlyUnwrappedOptional<String>.Type:
                return t.addColumn(Expression<String>(column), defaultValue: "")
            case _ as String?.Type:
                return t.addColumn(Expression<String?>(column))
                
                
            case _ as NSNumber.Type, _ as  ImplicitlyUnwrappedOptional<NSNumber>.Type:
                
                if doubleTypeProperties().contains(attribute) {
                    return t.addColumn(Expression<Double>(column), defaultValue: 0.0)
                }else{
                    
//                    if key == "id" {
//                        return t.addColumn(Expression<NSNumber>(key), primaryKey: .autoincrement)
//                    }else{
                        return t.addColumn(Expression<NSNumber>(column), defaultValue: 0)
//                    }
                    
                }
                
            case _ as NSNumber?.Type:
                
                if doubleTypeProperties().contains(attribute) {
                    return t.addColumn(Expression<Double?>(column))
                }else{
                    return t.addColumn(Expression<NSNumber?>(column))
                }
                
            case _ as NSDate.Type, _ as  ImplicitlyUnwrappedOptional<NSDate>.Type:
                return t.addColumn(Expression<NSDate>(column), defaultValue: NSDate(timeIntervalSince1970: 0))
            case _ as NSDate?.Type:
                return t.addColumn(Expression<NSDate?>(column))
                
            default:
                return nil
            }
            
        }
        return nil
    }
    
    // MARK: - CREATE INDEX
    
     class func createIndex(_ columns: Expressible...) -> Bool {
        do{
            try db.run(Table(nameOfTable).createIndex(columns))
            LogInfo("Create \(columns) indexs on \(nameOfTable) table success")
            return true
            
        }catch{
            LogError("Create \(columns) indexs on \(nameOfTable) table failure")
            return false
        }
    }
    
     class func createIndex(_ columns: [Expressible], unique: Bool = false, ifNotExists: Bool = false) -> Bool {
        do{

            try db.run(Table(nameOfTable).createIndex(columns, unique: unique, ifNotExists: ifNotExists))
            LogInfo("Create \(columns) indexs on \(nameOfTable) table success")
            return true
            
        }catch{
            LogError("Create \(columns) indexs on \(nameOfTable) table failure")
            return false
        }
    }
    
    // MARK: - DROP INDEX
    
     class func dropIndex(_ columns: Expressible...) -> Bool {
        do{
            try db.run(Table(nameOfTable).dropIndex(columns))
            LogInfo("Drop \(columns) indexs from \(nameOfTable) table success")
            return true
            
        }catch{
            LogError("Drop \(columns) indexs from \(nameOfTable) table failure")
            return false
        }
    }
    
     class func dropIndex(_ columns: [Expressible], ifExists: Bool = false) -> Bool {
        do{
            
            try db.run(Table(nameOfTable).dropIndex(columns, ifExists: ifExists))
            LogInfo("Drop \(columns) indexs from \(nameOfTable) table success")
            return true
            
        }catch{
            LogError("Drop \(columns) indexs from \(nameOfTable) table failure")
            return false
        }
    }
}
