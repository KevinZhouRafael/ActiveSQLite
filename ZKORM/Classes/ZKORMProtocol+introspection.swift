//
//  ASProtocolQuery.swift
//  ZKORM
//
//  Created by Kevin Zhou on 08/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import GRDB


public extension ZKORMProtocol where Self:ZKORMModel{

//    func recursionPropertiesOnlyColumn() -> [(String?,Any)]{
//
//        var properties = [(String?,Any)]()
//        var mirror: Mirror? = Mirror(reflecting: self)
//        repeat {
//            for case let (key?, value) in mirror!.children {
//
//                if isSupportTypes(value){
//                    if let column = differentPropertyColumnMapper()[key] {
//                        properties.append((column, value))
//                    }else{
//                        properties.append((key, value))
//                    }
//                }
//
//            }
//            mirror = mirror?.superclassMirror
//        } while mirror != nil
//
//        return properties.sorted(by: {
//            if $0.0 ==  primaryKeyPropertyName {
//                return true
//            }
//            return $0.0! < $1.0!
//        } )
//    }
    
    func recursionProperties() -> [(String,String,Any)]{
        
        var properties = [(String,String,Any)]()
        var mirror: Mirror? = Mirror(reflecting: self)
        repeat {
            for case let (propertyName?, value) in mirror!.children {
                
                if noSavedProperties().contains(propertyName){
                    continue
                }
                
                if isSupportTypes(value) {
                    if let columnName = differentPropertyColumnMapper()[propertyName] {
                        properties.append((propertyName, columnName, value))
                    }else{
                        properties.append((propertyName, propertyName, value))
                    }
                }
                
            }
            mirror = mirror?.superclassMirror
        } while mirror != nil
        
        return properties.sorted(by: {
            if $0.0 == primaryKeyPropertyName {
                return true
            }
            return $0.0 < $1.0
        } )
    }
    
    //暂未使用
    func propertieColumnMap() -> [String:String]{
        
        var propertyColumnMap = [String:String]()
        var mirror: Mirror? = Mirror(reflecting: self)
        repeat {
            for case let (propertyName?, value) in mirror!.children {
                
                if noSavedProperties().contains(propertyName)  {
                    continue
                }
                
                if isSupportTypes(value){
                    if let columnName = differentPropertyColumnMapper()[propertyName] {
                        propertyColumnMap[propertyName] = columnName
                    }else{
                        propertyColumnMap[propertyName] = propertyName
                    }
                }
                
            }
            mirror = mirror?.superclassMirror
        } while mirror != nil
        
        
        return propertyColumnMap
    }
    
}

