//
//  CipherTests.swift
//  ActiveSQLiteTests
//
//  Created by kai zhou on 2018/6/19.
//  Copyright © 2018 hereigns. All rights reserved.
//
import Foundation
import Quick
import Nimble
import SQLite

@testable import ActiveSQLite

class CipherTests: QuickSpec {
    override func spec() {
        
        ASConfigration.setDefaultDB(path: getTestDBPath()!, name: DBDefaultName)
        ASConfigration.setDB(path: getDBCipherPath(), name: DBNameCipher,key: "sqlite123")
        
        
//        describe("Insert cities in db1") {
//
//            try? City.dropTable()
//
//            var cities = [City]()
//            for i in 0 ..< 10 {
//                let c = City()
//                c.name = "City name \(i) in DB1"
//                c.code = String(i)
//                cities.append(c)
//            }
//
//            try! City.insertBatch(models: cities)
//
//
//            for (index,city) in cities.enumerated(){
//                XCTAssertTrue(city.id.intValue > 0)
//                XCTAssertEqual(city.name, "City name \(index) in DB1")
//                XCTAssertEqual(city.code, String(index))
//            }
//
//        }
        
        describe("Find cities ") {
            
            let cities1 = CityCipher.findAll(orderColumn: "id")
            expect(cities1.count).to(equal(5))
            expect(cities1.last?.name).to(equal("City name 4 in DB2"))
            
        }
        
    }
}
