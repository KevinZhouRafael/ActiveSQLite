//
//  TranscationSpec.swift
//  ActiveSQLite
//
//  Created by yuhan on 04/07/2017.
//  Copyright © 2017 hereigns. All rights reserved.
//

import Quick
import Nimble

@testable import ActiveSQLite

class TranscationSpec: QuickSpec {
    override func spec() {
        describe("Transcation Tests") {
            
            ProductM.dropTable()
            Users.dropTable()
            
            ActiveSQLite.save({ 
                

//                let p = ProductM()
//                p.name = "House"
//                p.price = NSNumber(value:9999.99)
//                try p.save()
                
                
                var products = [ProductM]()
                for i in 0 ..< 3 {
                    let p = ProductM()
                    p.name = "iPhone-\(i)"
                    p.price = NSNumber(value:i)
                    products.append(p)
                }
                
                try ProductM.insertBatch(models: products)
                

                
                let u = Users()
                u.name = "Kevin"
                try u.save()
                
                
                
            }, completion: { (error) in
                
                if error != nil {
                    debugPrint("transtion fails \(error)")
                }else{
                    debugPrint("transtion success")
                }

            })
            
        }
    }
}
