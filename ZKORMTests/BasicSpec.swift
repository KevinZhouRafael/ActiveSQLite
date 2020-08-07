//
//  BasicSpec.swift
//  ZKORM
//
//  Created by Kevin Zhou on 05/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Quick
import Nimble

import GRDB 
@testable import ZKORM

class BasicSpec: QuickSpec {
    override func spec() {
        describe("TestsDatabase ") {
            
            ZKORMConfigration.logLevel = .debug
            ZKORMConfigration.setDefaultDB(path: getTestDBPath()!, name: DBDefaultName)
            
            let model: ProductM = ProductM()

            describe("create Database ", {
                
                describe("Delete Table ", {
                    
                    try? ProductM.dropTable()
                })
                
                describe("create Table ", {
                    
                    try! ProductM.createTable()
                    
                    
                    describe(" insert", {
                        
                        model.name = "iPhone 7"
                        model.price = 1.2
                        try! model.insert()
                        debugPrint(model)
                    })
                    
                    describe(" Update ", {
                        
                        model.name = "iMac"
                        model.price = 99.99
                        try! model.update()
                        debugPrint(model)
                    })

                    describe(" Update -save", {
                        
                        model.name = "iPad"
                        model.price = 55.99
                        try! model.save()
                        debugPrint(model)

                    })
                    
                    describe(" insert-save", {
                        // insert
                        let m2 = ProductM()
                        m2.name = "iWatch"
                        m2.price = 10000
                        try! m2.save()
                    })
                    
                    //必须创建唯一索引。
//                    describe("Query- use Map", {
//
////                        let p = try? ProductM.findOne { (db) in
////                            try ProductM.fetchOne(db, key: ["product_name":"iWatch"])
////                        }
//                        let p = try! ProductM.fetchOne(key: ["product_name":"iWatch"])
//                        expect(p!.price).to(equal(10000.0))
//                        expect(p!.name).to(equal("iWatch"))
//
////                        let p2 = try? ProductM.read { (db) in
////                            try ProductM.fetchOne(db, key: ["product_name":"iWatch"])
////                        }
//                        let p2 = try! ProductM.fetchOne(key: ["product_name":"iWatch"])
//                        expect(p2!.price).to(equal(10000.0))
//                        expect(p2!.name).to(equal("iWatch"))
//                    })
                    
                    
                    describe("Query- use Column", {
                        
                        let p = try! ProductM.read { (db) in
                            try ProductM.filter(ProductM.Columns.name == "iWatch").fetchOne(db)!
                        }
//                        let p:ProductM = try! ProductM.filter(ProductM.Columns.name == "iWatch").fetchOne()!
                        expect(p.price).to(equal(10000))
                        expect(p.name).to(equal("iWatch"))
                        
                        //filter等复杂操作不提供类似fetchOne的简便方法
                        let p2 = try! ProductM.read { (db) in
                            try ProductM.filter(ProductM.Columns.name == "iWatch" && ZKORMModel.Columns.id == 2).fetchOne(db)!
                        }
                        
                        expect(p2.price).to(equal(10000))
                        expect(p2.name).to(equal("iWatch"))
                        expect(p2.id).to(equal(2))
                    })
                    
                    describe("Query", {
                        let p = try! ProductM.read { (db) in
                            try ProductM.filter(ProductM.Columns.name == "iWatch" && ZKORMModel.Columns.id > 1).fetchOne(db)!
                        }
                        expect(p.price).to(equal(10000))
                        expect(p.id).to(equal(2))
                        
                        
                        // insert 10 rows
                        for i in 0..<10{
                            let m = ProductM()
                            m.name = "Product\(i)"
                            m.price = 1.1
                            m.code = 10 - i
                            try! m.save()
                        }
                        
                        describe("Expressible Order", {
                            //Query order
                            let products = try! ProductM.read { (db) in
                                try ProductM.filter(ProductM.Columns.code > 3)
                                    .order(ProductM.Columns.code)
                                    .limit(5)
                                    .fetchAll(db)  //TODO: 进行db植入？！？！
                            }
                            
                            //verify Query
                            var i = 4;
                            for product in products{
                                expect(product.code).to(equal(i))
                                i += 1
                            }
                        })
                    })

//                    describe("Delete", {
//                        try! ProductM.write({ db in
//                            try! ProductM.filter(key: ["product_name":"iWatch"]).deleteAll(db)
//                            let count = try! ProductM.filter(key: ["product_name":"iWatch"]).fetchCount(db)
//                            expect(count).to(equal(0))
//                        })
//
//                    })
                    
                    describe("Delete", {
                        try! ProductM.write({ db in
                            try! ProductM.filter(ProductM.Columns.name == "iWatch").deleteAll(db)
                        })
                        
                        let count = try! ProductM.read { (db) in
                            try ProductM.filter(ProductM.Columns.name == "iWatch")
                                .fetchCount(db)
                        }
                        expect(count).to(equal(0))
                      
                    })
                })

            })

        }
    }
}
