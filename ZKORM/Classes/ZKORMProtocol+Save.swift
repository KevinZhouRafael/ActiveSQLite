//
//  ZKORMProtocol+Save.swift
//  ZKORM
//
//  Created by Kevin Zhou on 2020/8/5.
//  Copyright © 2020 hereigns. All rights reserved.
//

import Foundation
import GRDB

//MARK: Save
public extension ZKORMProtocol where Self:ZKORMModel{
    
    func insert() throws{
        try getDBQueue().inDatabase {[weak self] db in
            try self?.createTable(db)
            try self?.insert(db)
        }
    }
    
    static func insert(models:[Self]) throws{
        try getDBQueue().inDatabase({ db in
            try insert(db, models: models)
        })
    }
    
    static func insert(_ db: Database, models: [Self]) throws {
        try db.inSavepoint {
            for m in models{
                try m.createTable(db)
                try m.insert(db)
            }
            return .commit
        }
    }
    
    
    func update() throws{
        try getDBQueue().inDatabase {[weak self] db in
            try self?.update(db)
        }
    }
    
    static func update(models:[Self]) throws{
        try getDBQueue().inDatabase({ db in
            try update(db, models: models)
        })
    }
    static func update(_ db:Database,models:[Self]) throws{
        try db.inSavepoint {
            for m in models{
                try m.update(db)
            }
            return .commit
        }
    }
    
    static func updateAll(onConflict conflictResolution: Database.ConflictResolution? = nil,
        _ assignment: ColumnAssignment,
        _ otherAssignments: ColumnAssignment...,
        filter predicate: GRDB.SQLExpressible)
        throws
    {
        return try getDBQueue().inDatabase({ db in
            try db.inSavepoint {
                try filter(predicate).updateAll(db, onConflict: conflictResolution,[assignment] + otherAssignments)
                return .commit
            }
        })
    }
    
    @discardableResult
    func updateChanges(with change: (Self) throws -> Void) throws -> Bool {
        try getDBQueue().inDatabase({ (db) in
            try updateChanges(db, with: change)
        })
    }
    
    func save() throws{
        try getDBQueue().inDatabase {[weak self] db in
            try self?.createTable(db)
            try self?.save(db)
        }
    }
    func delete() throws{
        try getDBQueue().inDatabase {[weak self] db in
            _ = try self?.delete(db)
        }
    }
    
    @discardableResult
    static func deleteAll(_ predicate: GRDB.SQLExpressible) throws  -> Int{
        try getDBQueue().write({ (db) in
            try filter(predicate).deleteAll(db)
        })
    }

}
