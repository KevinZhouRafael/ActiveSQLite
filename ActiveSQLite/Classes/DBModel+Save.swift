//
//  DBModel+Insert&Update.swift
//  ActiveSQLite
//
//  Created by kai zhou on 08/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import SQLite

extension DBModel{
    
    //MARK: - Insert
    //can't insert reduplicate ids
    func insert() {
        createTable()
        do {

            let timeinterval = NSNumber(value:NSDate().timeIntervalSince1970 * 1000)
            
            var settersInsert = setters(skips: ["id","created_at","updated_at"])
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
            
        }
        
    }
    
    class func insertBatch(models:[DBModel])->Bool{
        createTable()
        
        //id，created_at,updated_at
        var autoInsertValues = [(NSNumber,NSNumber,NSNumber)]()
        do{
            try db.transaction {
                for model in models{
                    
                    let timeinterval = NSNumber(value:NSDate().timeIntervalSince1970 * 1000)
                    
                    var settersInsert = model.setters(skips: ["id","created_at","updated_at"])
                    settersInsert.append(Expression<NSNumber>("created_at") <- timeinterval)
                    settersInsert.append(Expression<NSNumber>("updated_at") <- timeinterval)

                    if model.id != nil {
                        settersInsert.append(Expression<NSNumber>("id") <- model.id)
                    }
                    
                    let rowid = try self.db.run(Table(nameOfTable).insert(settersInsert))
                    let id = NSNumber(value:rowid)
                    autoInsertValues.append((id,timeinterval,timeinterval))
                    
                }
            }
            
            for i in 0 ..< models.count {
                models[i].id = autoInsertValues[i].0
                models[i].created_at = autoInsertValues[i].1
                models[i].updated_at = autoInsertValues[i].2
            }
            
            LogInfo("Batch insert rows(\(models)) into \(nameOfTable) table success")
            return true
        }catch{
            LogError("Batch insert rows into \(nameOfTable) table failure:\(error)")
            return false
        }
        
    }
    
    //MARK: - Update
    //Update By id
    func update() {
        do {
            
            let timeinterval = NSNumber(value:NSDate().timeIntervalSince1970 * 1000)
            
            var settersUpdate = setters(skips: ["id","updated_at"])
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
        }
        
        
    }
    
    class func updateBatch(models:[DBModel])->Bool{
        //updated_at
        var autoUpdateValues = [(NSNumber)]()
        do{
            try db.transaction {
                for model in models{
                    
                    let timeinterval = NSNumber(value:NSDate().timeIntervalSince1970 * 1000)
                    
                    var settersUpdate = model.setters(skips: ["id","updated_at"])
                    settersUpdate.append(Expression<NSNumber>("updated_at") <- timeinterval)
                    
                    let table = Table(model.tableName()).where(Expression<NSNumber>("id") == model.id)
                    try self.db.run(table.update(settersUpdate))

                    autoUpdateValues.append((timeinterval))
                    
                }
            }
            
            for i in 0 ..< models.count {
                models[i].updated_at = autoUpdateValues[i]
            }
            
            LogInfo("batch Update \(models) on \(nameOfTable) table success")
            return true
        }catch{
            LogError("batch Update \(nameOfTable) table failure\(error)")
            return false
        }

    }
    
    
    
    //MARK: - Save
    //insert if table have't the row，Update if table have the row
    func save(){
        createTable()
        do {
            let timeinterval = NSNumber(value:NSDate().timeIntervalSince1970 * 1000)
            var created_at_value = timeinterval
            let updated_at_value = timeinterval
            if created_at != nil {
                created_at_value = created_at
            }
            
            var settersInsert = setters(skips: ["id","created_at","updated_at"])
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
            
        }
    }

    //MARK: - Common
    func setters( skips:[String] = ["id"])->[Setter]{
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
                
                if self.doubleTypeProperties().contains(attribute) {
                    setters.append(Expression<Double>(column) <- value as! Double)
                }else{
                    setters.append(Expression<NSNumber>(column) <- value as! NSNumber)
                }
                
            case _ as NSNumber?.Type:
                
                if self.doubleTypeProperties().contains(attribute) {
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

}
