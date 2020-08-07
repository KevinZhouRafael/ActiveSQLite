//
//  ZKORMProtocol+Query.swift
//  ZKORM
//
//  Created by Kevin Zhou on 2020/8/3.
//  Copyright © 2020 hereigns. All rights reserved.
//

import Foundation
import GRDB

//MARK: Query
public extension ZKORMProtocol where Self:ZKORMModel{
    
    static func findAll() throws -> [Self]{
        return try getDBQueue().read{ db in
            try self.fetchAll(db)
        }
    }
    
    static func findAll2() throws -> [Self]{
        try getDBQueue().read{ db in
            return try self.fetchAll(db)
        }
    }
    
    static func findAll(_ block: (Database) throws-> [Self]) throws  -> [Self]{
        return try getDBQueue().read{ db in
            try block(db)
        }
    }
    static func findOne(_ block: (Database) throws-> Self?) throws  -> Self?{
        return try getDBQueue().read{ db in
            try block(db)
        }
    }
    
}


//MARK: Query FetchableRecord where Self: TableRecord
// 必须加唯一索引才可查询。否则使用filter column，再fetch，即不使用key value。 TODO:把key value 转化成column。
public extension ZKORMProtocol where Self:ZKORMModel, Self:TableRecord{
    
    static func fetchCursor() throws -> RecordCursor<Self> {
        try getDBQueue().read({ db in
            return try fetchCursor(db)
        })
    }
    
    static func fetchAll() throws -> [Self] {
        try getDBQueue().read({ db in
            return try fetchAll(db)
        })
    }
    
    static func fetchOne() throws -> Self? {
        try getDBQueue().read({ db in
            return try fetchOne(db)
        })
    }
    
    static func fetchCursor<Sequence>(keys: Sequence)
        throws -> RecordCursor<Self>
        where Sequence: Swift.Sequence, Sequence.Element: DatabaseValueConvertible
    {
        try getDBQueue().read({ db in
            return try fetchCursor(db,keys:keys)
        })
    }
    
    static func fetchAll<Sequence>( keys: Sequence)
        throws -> [Self]
        where Sequence: Swift.Sequence, Sequence.Element: DatabaseValueConvertible {
        try getDBQueue().read({ db in
            return try fetchAll(db, keys: keys)
        })
    }
    
    static func fetchOne<PrimaryKeyType>(key: PrimaryKeyType?)
        throws -> Self?
        where PrimaryKeyType: DatabaseValueConvertible
    {
        try getDBQueue().read({ db in
            return try fetchOne(db, key: key)
        })
    }
    
    static func fetchCursor(keys: [[String: DatabaseValueConvertible?]])
        throws -> RecordCursor<Self>
    {
        try getDBQueue().read({ db in
            return try fetchCursor(db, keys: keys)
        })
    }

    static func fetchAll(keys: [[String: DatabaseValueConvertible?]]) throws -> [Self] {
        try getDBQueue().read({ db in
            return try fetchAll(db, keys: keys)
        })
    }

    static func fetchOne(key: [String: DatabaseValueConvertible?]?) throws -> Self? {
        try getDBQueue().read({ db in
            return try fetchOne(db, key: key)
        })
    }
    
}

//extension FetchRequest where RowDecoder: FetchableRecord, Self:ZKORMModel{
//    public func fetchCursor() throws -> GRDB.RecordCursor<Self.RowDecoder>{
//        return try getDBQueue().read({ db in
//            try fetchCursor(db)
//        })
//    }
//
//    public func fetchAll() throws -> [Self.RowDecoder]{
//        return try getDBQueue().read({ db in
//            try fetchAll(db)
//        })
//    }
//
//    public func fetchOne()throws -> RowDecoder?{
//        return try getDBQueue().read({ db in
//            return try RowDecoder.fetchOne(db, self)
//        })
//    }
//}
