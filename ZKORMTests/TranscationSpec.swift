//
//  TranscationSpec.swift
//  ZKORM
//
//  Created by Kevin Zhou on 04/07/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Quick
import Nimble

@testable import ZKORM

class TranscationSpec: QuickSpec {
    override func spec() {
        describe("Transcation Tests") {
            ZKORMConfigration.setDefaultDB(path: getTestDBPath()!, name: DBDefaultName)
            
            try? ProductM.dropTable()
            try? Users.dropTable()
            
            ZKORM.save({ db in
                
//                let p = ProductM()
//                p.name = "House"
//                p.price = 9999.99
//                try p.save()
                
                var products = [ProductM]()
                for i in 0 ..< 3 {
                    let p = ProductM()
                    p.name = "iPhone-\(i)"
                    p.price = Double(i)
                    products.append(p)
                }
                try ProductM.insert(db, models: products)
                
                
                let u = Users()
                u.name = "Kevin"
                try u.createTable(db) //TODO：自动创建表。
                try u.save(db)
                
            }, completion: { (error) in
                
                if error != nil {
                    debugPrint("transtion fails \(String(describing: error))")
                }else{
                    debugPrint("transtion success")
                }

            })
            
        }
    }
}
