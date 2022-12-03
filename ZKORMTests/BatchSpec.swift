//
//  BatchSpec.swift
//  ZKORM
//
//  Created by Kevin Zhou on 13/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Quick
import Nimble
import GRDB

@testable import ZKORM

class BatchSpec: QuickSpec {
    override func spec() {
        describe("batch insert") {
            
            ZKORMConfigration.setDefaultDB(path: getTestDBPath()!, name: DBDefaultName)
            
            try? ProductM.dropTable()
            
            var products = [ProductM]()
            for i in 0 ..< 10 {
                let p = ProductM()
                p.name = "Product name \(i)"
                p.price = Double(i)
                products.append(p)
            }
            try! ProductM.insert(models: products)

            for (index,product) in products.enumerated(){
                XCTAssertTrue(product.id! > 0)
                XCTAssertEqual(product.name, "Product name \(index)")
                XCTAssertEqual(product.price, Double(index))
            }
            
            describe("batch Update ") {
                
                let products = try! ProductM.findAll()
                
                for (index,product) in products.enumerated(){
                    XCTAssertEqual(product.id!, Int64(index + 1))
                    XCTAssertEqual(product.name, "Product name \(index)")
                    XCTAssertEqual(product.price, Double(index))
                    
                    product.name = "new name \(index)"
                }
                
                try! ProductM.update(models:products)
                
                for (index,product) in products.enumerated(){
                    XCTAssertEqual(product.name, "new name \(index)")
                }
                
            }
        }
    }
}
