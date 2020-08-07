//
//  ProductM.swift
//  ZKORM
//
//  Created by Kevin Zhou on 05/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import GRDB
@testable import ZKORM

class ProductM:ZKORMModel{
    
    //必须显示指名，否则Columns的'CodingKeys' is inaccessible due to 'private' protection level
//    enum CodingKeys: String, CodingKey {
//        case name = "product_name"
//        case price = "product_price"
//        case desc
//        case code
//        case type
//    }
    enum Columns: String, ColumnExpression,CaseIterable {
        case name = "product_name"
        case price = "product_price"
        case desc
        case code
        case type
        case publish_date
    }
//    enum Columns {
//        static let name = Column(CodingKeys.name)
//        static let price = Column(CodingKeys.price)
//        static let desc = Column(CodingKeys.desc)
//        static let code = Column(CodingKeys.code)
//        static let type = Column(CodingKeys.type)
//    }
    
    public var name:String = ""
    var price:Double = 0.0
    var desc:String?
    var code:Int?
    var type:Int8?
    var publish_date:Date?
    var version:Int8?
    
    
    required init(row: Row) {
        super.init(row: row)
        name = row[Columns.name]
        price = row[Columns.price]
        desc = row[Columns.desc]
        code = row[Columns.code]
        type = row[Columns.type]
        publish_date = row[Columns.publish_date]
    }
    
    required init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container[Columns.name] = name
        container[Columns.price] = price
        container[Columns.desc] = desc
        container[Columns.code] = code
        container[Columns.type] = type
        container[Columns.publish_date] = publish_date
        super.encode(to: &container)
    }

    override class var nameOfTable: String{
        return "Product"
    }
    
//    static var databaseTableName: String{
//        return "Product"
//    }

    override func differentPropertyColumnMapper() -> [String:String]{
//        var enumNameMap = super.differentPropertyColumnMapper()
        var enumNameMap = [String:String]()
        for column in Columns.allCases{
            //column.rawValue也可以
            if String(describing: column) != column.name {
                enumNameMap[String(describing: column)] = column.name
            }
        }
        return enumNameMap
    }
    
    override func transientTypes() -> [String]{
        return ["version"]
    }

    override class var isSaveDefaulttimestamp:Bool{
        return true
    }
    
}
/*
extension ProductM{
    /// The values persisted in the database
    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.price] = price
        container[Columns.desc] = desc
        container[Columns.code] = code
        container[Columns.type] = type
    }
}
extension ProductM:TableRecord{
//    public static var databaseTableName: String{
//        return nameOfTable
//    }

    enum Columns {
        static let id = Column("id")
        static let name = Column(CodingKeys.name)
        static let price = Column(CodingKeys.price)
        static let desc = Column(CodingKeys.desc)
        static let code = Column(CodingKeys.code)
        static let type = Column(CodingKeys.type)
    }
}
*/
//不需要显示制定CodingKeys，
struct Place: Codable {
    var id: Int64?
    var title: String
    var isFavorite: Bool
}

// SQL generation
extension Place: TableRecord {
    /// The table columns
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let title = Column(CodingKeys.title)
        static let isFavorite = Column(CodingKeys.isFavorite)
    }
    
    static var databaseTableName: String{
        return "Product"
    }
    
}

// Fetching methods
extension Place: FetchableRecord { }

// Persistence methods
extension Place: MutablePersistableRecord {
    // Update auto-incremented id upon successful insertion
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
