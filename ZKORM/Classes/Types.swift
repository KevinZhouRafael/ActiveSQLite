//
//  Types.swift
//  ZKORM
//
//  Created by kai zhou on 2018/8/13.
//  Copyright © 2018 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import GRDB

func isSupportTypes(_ value:Any)->Bool{
    let mir = Mirror(reflecting:value)
    
    switch mir.subjectType {
        
    case _ as String.Type,_ as String?.Type,
         _ as Int.Type,_ as Int?.Type,
         _ as Int8.Type,_ as Int8?.Type,
         _ as Int16.Type,_ as Int16?.Type,
         _ as Int32.Type,_ as Int32?.Type,
         _ as Int64.Type,_ as Int64?.Type,
         _ as UInt.Type,_ as UInt?.Type,
         _ as UInt8.Type,_ as UInt8?.Type,
         _ as UInt16.Type,_ as UInt16?.Type,
         _ as UInt32.Type,_ as UInt32?.Type,
         _ as UInt64.Type,_ as UInt64?.Type,
         _ as Double.Type,_ as Double?.Type,
         _ as Float.Type,_ as Float?.Type,
         _ as Float32.Type,_ as Float32?.Type,
         _ as Float64.Type,_ as Float64?.Type,
         _ as Bool.Type,_ as Bool?.Type,
         _ as Date.Type,_ as Date?.Type:
        return true
        
    default:
        return false
    }
}
