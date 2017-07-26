//
//  DBModel+Insert&Update.swift
//  ActiveSQLite
//
//  Created by zhou kai on 08/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import SQLite

extension DBModel{
    
    //MARK: - Insert
    //can't insert reduplicate ids
    func insert()throws {
        
        do {
            try createTable()
            
            let timeinterval = NSNumber(value:NSDate().timeIntervalSince1970 * 1000)
            
            var settersInsert = buildSetters(skips: ["id", "created_at", "updated_at"])
            settersInsert.append(Expression<NSNumber>("created_at") <- timeinterval)
            settersInsert.append(Expression<NSNumber>("updated_at") <- timeinterval)
            
            //insert id if id has value; insert auto id if id is nil.
            if id != nil {
                settersInsert.append(Expression<NSNumber>("id") <- id)
            }
            
            let rowid = try DBModel.db.run(Table(tableName()).insert(settersInsert))
            id = NSNumber(value:rowid)
            created_at = timeinterval
            updated_at = timeinterval
            LogInfo("Insert row of \(rowid) into \(tableName()) table success ")
        }catch{
            LogError("Insert row into \(tableName()) table failure: \(error)")
            throw error
        }
        
    }
    
    class func insertBatch(models:[DBModel])throws{
       
        
        //id，created_at,updated_at
        var autoInsertValues = [(NSNumber,NSNumber,NSNumber)]()
        do{
            
             try createTable()
            
//            try db.transaction {
            try db.savepoint("savepointname_\(nameOfTable)_insertbatch_\(NSDate().timeIntervalSince1970 * 1000)", block: {
                for model in models{
                    
                    let timeinterval = NSNumber(value:NSDate().timeIntervalSince1970 * 1000)
                    
                    var settersInsert = model.buildSetters(skips: ["id", "created_at", "updated_at"])
                    settersInsert.append(Expression<NSNumber>("created_at") <- timeinterval)
                    settersInsert.append(Expression<NSNumber>("updated_at") <- timeinterval)
                    
                    if model.id != nil {
                        settersInsert.append(Expression<NSNumber>("id") <- model.id)
                    }
                    
                    let rowid = try self.db.run(Table(nameOfTable).insert(settersInsert))
                    let id = NSNumber(value:rowid)
                    autoInsertValues.append((id,timeinterval,timeinterval))
                    
                }

                for i in 0 ..< models.count {
                    models[i].id = autoInsertValues[i].0
                    models[i].created_at = autoInsertValues[i].1
                    models[i].updated_at = autoInsertValues[i].2
                }
//            }
            })
        
            LogInfo("Batch insert rows(\(models)) into \(nameOfTable) table success")

        }catch{
            LogError("Batch insert rows into \(nameOfTable) table failure:\(error)")
            throw error
            
        }
        
    }
    
    //MARK: - Update
    //MARK: - Update one By id
    func update() throws {
        do {
            
            let timeinterval = NSNumber(value:NSDate().timeIntervalSince1970 * 1000)
            
            var settersUpdate = buildSetters(skips: ["id", "updated_at"])
            settersUpdate.append(Expression<NSNumber>("updated_at") <- timeinterval)

            let table = Table(tableName()).where(Expression<NSNumber>("id") == id)
            let rowid = try DBModel.db.run(table.update(settersUpdate))
            
            if rowid > 0 {
                updated_at = timeinterval
                LogInfo(" Update row in \(rowid) from \(tableName()) Table success ")
            } else {
                LogWarn(" Update \(tableName()) table failure，can't not found id:\(id) 。")
            }
        } catch {
            LogError(" Update \(tableName()) table failure: \(error)")
            throw error
        }
        
        
    }
    
    func update(_ attribute: String, value:Any?)throws{
        try update([attribute:value])
    }
    
    func update(_ attributeAndValueDic:Dictionary<String,Any?>)throws{
        
        let setterss = buildSetters(attributeAndValueDic)
        try update(setterss)
    }
    
    func update(_ setters: Setter...) throws{
        try update(setters)
    }
    
    func update(_ setters:[Setter])throws{
        do {
            
            let settersUpdate = (type(of: self)).buildUpdateSetters(setters)
            
            let table = Table(tableName()).where(Expression<NSNumber>("id") == id)
            let rowid = try DBModel.db.run(table.update(settersUpdate))
            
            if rowid > 0 {
                try self.refreshSelf()
                
                LogInfo(" Update row in \(rowid) from \(tableName()) Table success ")
            } else {
                LogWarn(" Update \(tableName()) table failure，can't not found id:\(id) 。")
            }
        } catch {
            LogError(" Update \(tableName()) table failure: \(error)")
            throw error
        }
        
    }

    //MARK: - Update all
    //MARK: - Update more than one by ids
    class func updateBatch(models:[DBModel]) throws{
        //updated_at
        var autoUpdateValues = [(NSNumber)]()
        do{
            try db.savepoint("savepointname_\(nameOfTable)_updateBatch\(NSDate().timeIntervalSince1970 * 1000)", block: {
                //            try db.transaction {
                for model in models{
                    
                    let timeinterval = NSNumber(value:NSDate().timeIntervalSince1970 * 1000)
                    
                    var settersUpdate = model.buildSetters(skips: ["id", "updated_at"])
                    settersUpdate.append(Expression<NSNumber>("updated_at") <- timeinterval)
                    
                    let table = Table(model.tableName()).where(Expression<NSNumber>("id") == model.id)
                    try self.db.run(table.update(settersUpdate))
                    
                    autoUpdateValues.append((timeinterval))
                    
                }
                
                for i in 0 ..< models.count {
                    models[i].updated_at = autoUpdateValues[i]
                }
                
            })
            LogInfo("batch Update \(models) on \(nameOfTable) table success")
            
        }catch{
            LogError("batch Update \(nameOfTable) table failure\(error)")
            throw error
        }
        
    }
    
    class func update(_ attribute: String, value:Any?,`where` wAttribute:String, wValue:Any?)throws{
        try update([attribute:value],where:[wAttribute:wValue])
    }
    
    class func update(_ attributeAndValueDic:Dictionary<String,Any?>,`where` wAttributeAndValueDic:Dictionary<String,Any?>)throws{
        let model = self.init()
        let setterss = model.buildSetters(attributeAndValueDic)
        let expressions = model.buildExpression(wAttributeAndValueDic)!
        try update(setterss, where: expressions)
        
    }

    //MARK: - Update more than one by where
    //    class func update(_ setters:Setter...,`where` predicate: SQLite.Expression<Bool>)throws{
    //        try update(setters, where: Expression<Bool?>(predicate))
    //    }
    
    class func update(_ setters:[Setter],`where` predicate: SQLite.Expression<Bool>)throws{
        try update(setters, where: Expression<Bool?>(predicate))
    }
    
    //    class func update(_ setters:Setter...,`where` predicate: SQLite.Expression<Bool?>)throws{
    //        try update(setters, where: predicate)
    //
    //    }
    
    class func update(_ setters:[Setter],`where` predicate: SQLite.Expression<Bool?>)throws{
        do {
            
            
            let table = Table(nameOfTable).where(predicate)
            
            let rowid = try DBModel.db.run(table.update(buildUpdateSetters(setters)))
            
            if rowid > 0 {
                LogInfo(" Update row in \(rowid) from \(nameOfTable) Table success ")
            } else {
                LogWarn(" Update \(nameOfTable) table failure，can't not found id:\(id) 。")
            }
        } catch {
            LogError(" Update \(nameOfTable) table failure: \(error)")
            throw error
        }
        
    }

    

    
    class func update(_ setters:[Setter])throws{
        do {
            
            let table = Table(nameOfTable)
            
            let rowid = try DBModel.db.run(table.update(buildUpdateSetters(setters)))
            
            if rowid > 0 {
                LogInfo(" Update row in \(rowid) from \(nameOfTable) Table success ")
            } else {
                LogWarn(" Update \(nameOfTable) table failure，can't not found id:\(id) 。")
            }
        } catch {
            LogError(" Update \(nameOfTable) table failure: \(error)")
            throw error
        }
        
    }

    
    
    //MARK: - Save
    //insert if table have't the row，Update if table have the row
    func save() throws{
        do {
            try createTable()
            
            let timeinterval = NSNumber(value:NSDate().timeIntervalSince1970 * 1000)
            var created_at_value = timeinterval
            let updated_at_value = timeinterval
            if created_at != nil {
                created_at_value = created_at
            }
            
            var settersInsert = buildSetters(skips: ["id", "created_at", "updated_at"])
            settersInsert.append(Expression<NSNumber>("created_at") <- created_at_value)
            settersInsert.append(Expression<NSNumber>("updated_at") <- updated_at_value)

            if id != nil {
                settersInsert.append(Expression<NSNumber>("id") <- id)
            }
            
            let rowid = try DBModel.db.run(Table(tableName()).insert(or: .replace, settersInsert))
            id = NSNumber(value:rowid)
            created_at = created_at_value
            updated_at = updated_at_value
            LogInfo("Insert row of \(rowid) into \(tableName()) table success ")
        }catch{
            LogError("Insert into \(tableName()) table failure: \(error)")
            throw error
        }
    }
    

    
    //MARK: - Common
    internal func refreshSelf() throws{
        let query = Table(tableName()).where(Expression<NSNumber>("id") == id).order(Expression<NSNumber>("updated_at").desc).limit(1)
        
        for row in try DBModel.db.prepare(query) {
            self.buildFromRow(row: row)
        }
    }
    
    internal func buildSetters(skips:[String] = ["id"])->[Setter]{
        var setters = [Setter]()
        
        for case let (attribute?,column?, value) in recursionProperties() {
            
            //skip primary key
            if skips.contains(attribute){
                continue
            }
            
            let mir = Mirror(reflecting:value)
            
            switch mir.subjectType {
                
            case _ as String.Type, _ as  ImplicitlyUnwrappedOptional<String>.Type:
                setters.append(Expression<String>(column) <- value as! String)
            case _ as String?.Type:
                
                if let v = value as? String {
                    setters.append(Expression<String?>(column) <- v)
                }else{
                    setters.append(Expression<String?>(column) <- nil)
                }
                
                
                
            case _ as NSNumber.Type, _ as  ImplicitlyUnwrappedOptional<NSNumber>.Type:
                
                if self.doubleTypes().contains(attribute) {
                    setters.append(Expression<Double>(column) <- value as! Double)
                }else{
                    setters.append(Expression<NSNumber>(column) <- value as! NSNumber)
                }
                
            case _ as NSNumber?.Type:
                
                if self.doubleTypes().contains(attribute) {
                    if let v = value as? Double {
                        setters.append(Expression<Double?>(column) <- v)
                    }else{
                        setters.append(Expression<Double?>(column) <- nil)
                    }
                }else{
                    if let v = value as? NSNumber {
                        setters.append(Expression<NSNumber?>(column) <- v)
                    }else{
                        setters.append(Expression<NSNumber?>(column) <- nil)
                    }
                }
                
            case _ as NSDate.Type, _ as  ImplicitlyUnwrappedOptional<NSDate>.Type:
                setters.append(Expression<NSDate>(column) <- value as! NSDate)
            case _ as NSDate?.Type:
                
                if let v = value as? NSDate {
                    setters.append(Expression<NSDate?>(column) <- v)
                }else{
                    setters.append(Expression<NSDate?>(column) <- nil)
                }
                
            default: break
                
            }
            
        }
        
        return setters
    }
    
    internal func buildSetters(_ attribute:String, value:Any?)->[Setter]{
        return buildSetters([attribute:value])
    }
    
    internal func buildSetters(_ attributeAndValueDic:Dictionary<String,Any?>)->[Setter]{
        
        var setters = Array<Setter>()
        
        for case let (attribute?,column?, v0) in recursionProperties() {
            
            if attributeAndValueDic.keys.contains(attribute) {
                
                let value = attributeAndValueDic[attribute]
                let mir = Mirror(reflecting:v0)
                
                switch mir.subjectType {
                    
                case _ as String.Type, _ as  ImplicitlyUnwrappedOptional<String>.Type:
                    setters.append(Expression<String>(column) <- value as! String)
                case _ as String?.Type:
                    
                    if let v = value as? String {
                        setters.append(Expression<String?>(column) <- v)
                    }else{
                        setters.append(Expression<String?>(column) <- nil)
                    }
                    
                    
                    
                case _ as NSNumber.Type, _ as  ImplicitlyUnwrappedOptional<NSNumber>.Type:
                    
                    if self.doubleTypes().contains(attribute) {
                        setters.append(Expression<Double>(column) <- value as! Double)
                    }else{
                        setters.append(Expression<NSNumber>(column) <- value as! NSNumber)
                    }
                    
                case _ as NSNumber?.Type:
                    
                    if self.doubleTypes().contains(attribute) {
                        if let v = value as? Double {
                            setters.append(Expression<Double?>(column) <- v)
                        }else{
                            setters.append(Expression<Double?>(column) <- nil)
                        }
                    }else{
                        if let v = value as? NSNumber {
                            setters.append(Expression<NSNumber?>(column) <- v)
                        }else{
                            setters.append(Expression<NSNumber?>(column) <- nil)
                        }
                    }
                    
                case _ as NSDate.Type, _ as  ImplicitlyUnwrappedOptional<NSDate>.Type:
                    setters.append(Expression<NSDate>(column) <- value as! NSDate)
                case _ as NSDate?.Type:
                    
                    if let v = value as? NSDate {
                        setters.append(Expression<NSDate?>(column) <- v)
                    }else{
                        setters.append(Expression<NSDate?>(column) <- nil)
                    }
                    
                default: break
                    
                }
                
            }
            
        }
        
        return setters
    }

    //if originSetters contains "updated_at", return same setters
    //if originSetters not contains "update_at", return new Setters contains "update_at"
    internal class func buildUpdateSetters(_ originSetters:[Setter])->[Setter]{
        
        //1.Replace double type setter if originSetters contains double type
        var settersUpdate = originSetters.map { (setter) -> Setter in
            
            
            let column = setter.getColumnName()
            var attribute = column
            for (pro, col) in self.init().propertieColumnMap(){
                if col == column {
                    attribute = pro
                }
            }
            
            //
            if self.init().doubleTypes().contains(attribute) {
                let setterValue = setter.getValue()
                let mir = Mirror(reflecting:setterValue ?? 0.0)
                switch mir.subjectType {
                    case _ as NSNumber.Type, _ as  ImplicitlyUnwrappedOptional<NSNumber>.Type:
                        return Expression<Double>(column) <- setterValue as! Double
                    case _ as NSNumber?.Type:
                        if let v = setterValue as? Double {
                            return Expression<Double?>(column) <- v
                        }else{
                            return Expression<Double?>(column) <- nil
                        }
                    default:break
                }
                return setter //the double type that originSetters contains is NSNumber. return origin setter
//                return Expression<Double?>(column) <- nil
            }else{
                return setter
            }
        }

    
        // 2.Add "update_at" setter if originSetters not contains "update_at"
        let columnNames = originSetters.flatMap({ (setter) -> String in
            return setter.getColumnName()
        })
        
        var containsUpdate_at = false
        for columnName in columnNames {
            if columnName.contains("updated_at") {
                containsUpdate_at = true
            }
        }
        if !containsUpdate_at {
            settersUpdate.append(Expression<NSNumber>("updated_at") <- NSNumber(value:NSDate().timeIntervalSince1970 * 1000))
        }

        return settersUpdate
    }

}
