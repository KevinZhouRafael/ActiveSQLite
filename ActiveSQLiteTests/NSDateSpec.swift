//
//  NSDateSpec.swift
//  ActiveSQLite
//
//  Created by yuhan on 21/06/2017.
//  Copyright © 2017 ios. All rights reserved.
//

import Quick
import Nimble
import SQLite

@testable import ActiveSQLite

class NSDateSpec: QuickSpec {
    
    override func spec() {
        
        describe("Test Column of NSDate。 ") {
            describe("Save", {
                
                ProductM.dropTable()
                
                let p = ProductM()
                p.name = "Book"
                p.price = NSNumber(value: 99)
                let currentDate = Date()
                //下一个月
                p.publish_date = NSDate(timeInterval: 3600 * 24 * 31, since: currentDate)
                p.save()
                
                
                context("Query", closure: {
                    let p = ProductM.findFirst("name", value: "Book") as! ProductM
                    
                    let formater = DateFormatter()
                    formater.dateFormat = "yyyy-MM-dd HH-mm-ss"
                    formater.timeZone = TimeZone.current
                    let dateString = formater.string(from: p.publish_date! as Date)
                    debugPrint("Time is：\(dateString)")
                        
                    it("Verify", closure: {
                        
                        let calender  = NSCalendar.current
                        

                        let components1 = calender.dateComponents([.year,.month,.day], from: currentDate)
                        let components2 = calender.dateComponents([.year,.month,.day], from: p.publish_date! as Date)
                        if components2.year! > components1.year! {
                            expect(components2.month).to(equal(1))
                        }else{
                            expect(components2.month).to(equal(components1.month! + 1))
                        }
                        
                    })
                    

                })
            })
            
            
        }
    }
}

