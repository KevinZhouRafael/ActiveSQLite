//
//  UpdateSpec.swift
//  ZKORM
//
//  Created by Kevin Zhou on 05/07/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Quick
import Nimble
import GRDB

@testable import ZKORM

class UpdateSpec: QuickSpec {
    override func spec() {
        describe("1--- update one by id") {
            
            ZKORMConfigration.setDefaultDB(path: getTestDBPath()!, name: DBDefaultName)
            
            try? ProductM.dropTable()
            let p = ProductM()
            
            try! ProductM.createTable()
            describe("save one product") {
                //1、ZKORM.save放在Transcation中测试。
                //2、ZKORM.save中不能使用自定义方法。只能使用参数带db的方法。
                
//                ZKORM.save({db in
//                    p.name = "House"
//                    p.price = 9999.99
//                    try p.save()
//                }, completion: { (error) in
//                    expect(error).to(beNil())
//                    //                let p = ProductM.findFirst("id", value: 1)!
//                    expect(p.name).to(equal("House"))
//                })
                    p.name = "House"
                    p.price = 9999.99
                    try! p.save()
                  
            }
            
            describe("update by attribute"){
                p.name = "House2"
                try! p.update()
                expect(p.name).to(equal("House2"))
            }
            
            describe("update by updateChanges") {
                try! ProductM.write { db in
                    try p.updateChanges(db){
                        $0.name = "apartment"
                        $0.price = 77.77
                    }
                }
                
                expect(p.name).to(equal("apartment"))
                expect(p.price.doubleValue).to(equal(77.77))
                
            }
        }
        
        describe("2--- batch  update ") {
            
            //save some products
            try? ProductM.dropTable()
//            try? ProductM.createTable()
            
            var products = [ProductM]()
            for i in 0 ..< 7 {
                let p = ProductM()
                p.name = "iPhone-\(i)"
                p.price = Double(i)
                products.append(p)
            }
            
            try! ProductM.insert(models: products)
            
            
            describe("update by batch") {
                
                for i in 0 ..< 7 {
                    let p = products[i]
                    p.desc = "desc-\(i)"
                    p.price = Double(i*2)
                }
                
                try! ProductM.update(models: products)
                
                for i in 0 ..< 7 {
                    let p = products[i]
                    expect(p.desc).to(equal("desc-\(i)"))
                    expect(p.price.doubleValue).to(equal(Double(i*2)))
                }
            }
            
            describe("update by columns") {
                ZKORM.save( { (db) in
                    for i in 3 ..< 7 {
                        try! ProductM
                                .filter(ZKORMModel.Columns.id == (i + 1))
                                .updateAll(db,ProductM.Columns.desc.set(to: "说明\(i)"), ProductM.Columns.price.set(to: Double(i*3)))
                        
                    }
                }) { (error) in
                    expect(error).to(beNil())
                    
                    let ps = try! ProductM.read { (db)  in
                         try ProductM
                            .order(ZKORMModel.Columns.id.asc)
                            .filter(ZKORMModel.Columns.id > Double(3))
                            .fetchAll(db)
                    }
                    
                    for i in 0 ..< 4 {
                        let p = ps[i]
                        expect(p.desc).to(equal("说明\(i+3)"))
                        expect(p.price.doubleValue).to(equal(Double((i+3)*3)))
                    }
                }
                
            }
            
            describe("update by updateChanges") {
                
                ZKORM.save({ db in
                    
                    for i in 0 ..< 7 {
                        if let p = try ProductM.fetchOne(db, key: i + 1){
                            // does not hit the database if score has not changed
                            try p.updateChanges(db) {
                                $0.desc = "介绍\(i)"
                                $0.price = Double(i)
                            }
                        }
                    }
                    
                }, completion: { (error) in
                    
                    expect(error).to(beNil())

                    let ps = try! ProductM.read { (db)  in
                         try ProductM
                            .order(ZKORMModel.Columns.id.asc)
                            .filter(ZKORMModel.Columns.id > Double(0))
                            .fetchAll(db)
                    }
                    
                    for i in 0 ..< 7 {
                        let p = ps[i]
                        expect(p.desc).to(equal("介绍\(i)"))
                        expect(p.price.doubleValue).to(equal(Double(i)))
                    }
                })

            }


        }
        
        
    }
}
