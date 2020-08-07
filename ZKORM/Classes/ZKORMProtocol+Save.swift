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
    func update() throws{
        try getDBQueue().inDatabase {[weak self] db in
            try self?.update(db)
        }
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
}
