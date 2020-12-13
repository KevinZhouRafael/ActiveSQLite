//
//  ZKORMProtocol+Query.swift
//  ZKORM
//
//  Created by Kevin Zhou on 2020/8/3.
//  Copyright © 2020 hereigns. All rights reserved.
//

import Foundation
import GRDB
//TODO: 通过keyPath参数查询, 支持链式调用chain query

//MARK: Query
public extension ZKORMProtocol where Self:ZKORMModel{
    
    static func findAll2() throws -> [Self]{
        return try getDBQueue().read{ db in
            try self.fetchAll(db)
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
    
    
    static func findAll(_ predicate: GRDB.SQLExpressible? = nil,order orderings: [GRDB.SQLOrderingTerm]? = nil,limit: Int? = nil, offset: Int? = nil) throws -> [Self]{
        return try getDBQueue().read{ db in
            var request = all()
            if let p = predicate{
                request = request.filter(p)
            }
            if let os = orderings{
                request = request.order(os)
            }
            if let l = limit{
                request = request.limit(l, offset: offset)
            }
            
            return try request.fetchAll(db)
        }
    }
    
    static func findOne(_ predicate: GRDB.SQLExpressible,order orderings: [GRDB.SQLOrderingTerm]? = nil) throws -> Self?{
        return try getDBQueue().read{ db in
            var request = filter(predicate)
            if let os = orderings{
                request = request.order(os)
            }
            return try request.fetchOne(db)
        }
    }
    
    static func findCount(_ predicate: GRDB.SQLExpressible) throws -> Int{
        return try getDBQueue().read{ db in
            try filter(predicate)
            .fetchCount(db)
        }
    }
}


//MARK: Query FetchableRecord where Self: TableRecord
// 必须加唯一索引才可查询。否则使用filter column，再fetch，即不使用key value。 TODO:把key value 转化成column。
public extension ZKORMProtocol where Self:ZKORMModel, Self:TableRecord{
    
    static func findCursor() throws -> RecordCursor<Self> {
        try getDBQueue().read({ db in
            return try fetchCursor(db)
        })
    }
    
    static func findAll() throws -> [Self] {
        try getDBQueue().read({ db in
            return try fetchAll(db)
        })
    }
    
    static func findOne() throws -> Self? {
        try getDBQueue().read({ db in
            return try fetchOne(db)
        })
    }
    
    static func findCursor<Sequence>(keys: Sequence)
        throws -> RecordCursor<Self>
        where Sequence: Swift.Sequence, Sequence.Element: DatabaseValueConvertible
    {
        try getDBQueue().read({ db in
            return try fetchCursor(db,keys:keys)
        })
    }
    
    static func findAll<Sequence>( keys: Sequence)
        throws -> [Self]
        where Sequence: Swift.Sequence, Sequence.Element: DatabaseValueConvertible {
        try getDBQueue().read({ db in
            return try fetchAll(db, keys: keys)
        })
    }
    
    static func findOne<PrimaryKeyType>(key: PrimaryKeyType?)
        throws -> Self?
        where PrimaryKeyType: DatabaseValueConvertible
    {
        try getDBQueue().read({ db in
            return try fetchOne(db, key: key)
        })
    }
    
    static func findCursor(keys: [[String: DatabaseValueConvertible?]])
        throws -> RecordCursor<Self>
    {
        try getDBQueue().read({ db in
            return try fetchCursor(db, keys: keys)
        })
    }

    static func findAll(keys: [[String: DatabaseValueConvertible?]]) throws -> [Self] {
        try getDBQueue().read({ db in
            return try fetchAll(db, keys: keys)
        })
    }

    static func findOne(key: [String: DatabaseValueConvertible?]?) throws -> Self? {
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
