//
//  MultiDBSpec.swift
//  ZKORMTests
//
//  Created by kai zhou on 19/01/2018.
//  Copyright © 2018 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import Quick
import Nimble
import GRDB

@testable import ZKORM

class MultiDBSpec: QuickSpec {
    override func spec() {
        
        ZKORMConfigration.setDefaultDB(path: getTestDBPath()!, name: DBDefaultName)
        ZKORMConfigration.setDB(path: getDB2Path(), name: DBName2)

        
        describe("Insert cities in db1") {
            
            try? City.dropTable()
            
            var cities = [City]()
            for i in 0 ..< 10 {
                let c = City()
                c.name = "City name \(i) in DB1"
                c.code = String(i)
                cities.append(c)
            }
            
            try! City.insert(models:cities)
            

            for (index,city) in cities.enumerated(){
                XCTAssertTrue(city.id! > 0)
                XCTAssertEqual(city.name, "City name \(index) in DB1")
                XCTAssertEqual(city.code, String(index))
            }
            
        }
        
        describe("Insert cities in db2") {
            
            try? City2.dropTable()
            
            var cities = [City2]()
            for i in 0 ..< 5 {
                let c = City2()
                c.name = "City name \(i) in DB2"
                c.code = String(i)
                cities.append(c)
            }
            
            try! City2.insert(models:cities)
            
            
            for (index,city) in cities.enumerated(){
                XCTAssertTrue(city.id! > 0)
                XCTAssertEqual(city.name, "City name \(index) in DB2")
                XCTAssertEqual(city.code, String(index))
            }
            
        }

        describe("Find cities ") {
            let cities1 = try! City.read { (db) in
                try City.order(ZKORMModel.Columns.id.asc).fetchAll(db)
            }
            expect(cities1.count).to(equal(10))
            expect(cities1.last?.name).to(equal("City name 9 in DB1"))

            let cities2 = try! City2.read { (db) in
                try City2.order(Column("id").desc).fetchAll(db)
            }
            
            expect(cities2.count).to(equal(5))
            expect(cities2.last?.name).to(equal("City name 0 in DB2"))

        }
    }
}
