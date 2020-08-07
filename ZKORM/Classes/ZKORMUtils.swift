//
//  Utils.swift
//  ZKORM
//
//  Created by kai zhou on 19/01/2018.
//  Copyright © 2018 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import GRDB

//project name
func bundleName() -> String{
    var bundlePath = Bundle.main.bundlePath
    bundlePath = bundlePath.components(separatedBy: "/").last!
    bundlePath = bundlePath.components(separatedBy: "/").first!
    return bundlePath
}

//class name -> AnyClass
func getClass(name:String) ->AnyClass?{
    let type = bundleName() + "." + name
    return NSClassFromString(type)
}


func recusionProperties(_ obj:Any) -> Dictionary<String,Any> {
    var properties = [String:Any]()
    var mirror: Mirror? = Mirror(reflecting: obj)
    repeat {
        for case let (key?, value) in mirror!.children {
            properties[key] = value
        }
        mirror = mirror?.superclassMirror
    } while mirror != nil
    
    return properties
}
