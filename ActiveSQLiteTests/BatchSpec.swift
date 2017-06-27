//
//  BatchSpec.swift
//  ActiveSQLite
//
//  Created by kai zhou on 13/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Quick
import Nimble
import SQLite

@testable import ActiveSQLite

class BatchSpec: QuickSpec {
    override func spec() {
        describe("batch insert") {
            
            ProductM.dropTable()
            
            var products = [ProductM]()
            for i in 0 ..< 10 {
                let p = ProductM()
                p.name = "Product name \(i)"
                p.price = NSNumber(value:i)
                products.append(p)
            }
            
            let b = ProductM.insertBatch(models: products)
            XCTAssertTrue(b, "batch insert success")
            expect(b).to(equal(true))
            
            for (index,product) in products.enumerated(){
                XCTAssertTrue(product.id.intValue > 0)
                XCTAssertEqual(product.name, "Product name \(index)")
                XCTAssertEqual(product.price.doubleValue, Double(index))
            }
            
            describe("batch Update ", { 
                
                let products = ProductM.findAll() as! Array<ProductM>
                
                for (index,product) in products.enumerated(){
                    XCTAssertEqual(product.id.intValue, index + 1)
                    XCTAssertEqual(product.name, "Product name \(index)")
                    XCTAssertEqual(product.price.doubleValue, Double(index))
                    
                    product.name = "new name \(index)"
                }
                
                XCTAssertTrue(ProductM.updateBatch(models: products),"batch Update  success")
                
                for (index,product) in products.enumerated(){
                    XCTAssertEqual(product.name, "new name \(index)")
                }
                
            })
        }
    }
}
