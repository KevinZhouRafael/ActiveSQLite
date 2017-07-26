//
//  DBConfigration.swift
//  ActiveSQLite
//
//  Created by zhou kai on 14/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import SQLite

//MARK: Custom Class
open class DBConfigration {
    static var logLevel: LogLevel = .info
    
    private static var dbPath:String?
    static func setDBPath(path:String){
        dbPath = path

    }
    
    static func getDBPath() -> String?{
        
        if dbPath == nil || dbPath!.isEmpty {
            NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/ActiveSQLite.db"
//            dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + bundleName() + "-ActiveSQLite.db"
        }
        
        if !FileManager.default.fileExists(atPath: dbPath!) {
            FileManager.default.createFile(atPath: dbPath!, contents: nil, attributes: nil)
            LogInfo("Create db file success-\(dbPath!)")
            
        }
        
        return dbPath
    }
}




//var ExpressionKey: UInt8 = 0
//extension Expression {
//
//    var isDouble: Bool?  {
//        get {
//            return objc_getAssociatedObject(self, &ExpressionKey) as? Bool
//        }
//        set (v) {
//            objc_setAssociatedObject(self, &ExpressionKey, v, .OBJC_ASSOCIATION_ASSIGN)
//        }
//    }
//
//    public init(_ template: String, isDouble:Bool? = false) {
//        self.init(template,[nil])
//        self.isDouble = isDouble
//    }
//
//    public init(_ template: String, _ bindings: [Binding?],_ isDouble:Bool? = false) {
//        self.template = template
//        self.bindings = bindings
//        self.isDouble = isDouble
//    }
//
//}

//public protocol ExpressionType : Expressible { // extensions cannot have inheritance clauses
//
//    associatedtype UnderlyingType = Void
//
//    var template: String { get }
//    var bindings: [Binding?] { get }
//
//    init(_ template: String, _ bindings: [Binding?])
//
//}

/*

//MARK: -- custom types
// date -- string
extension Date: Value {
    class var declaredDatatype: String {
        return String.declaredDatatype
    }
    class func fromDatatypeValue(stringValue: String) -> Date {
        return SQLDateFormatter.dateFromString(stringValue)!
    }
    var datatypeValue: String {
        return SQLDateFormatter.stringFromDate(self)
    }
}

let SQLDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    formatter.locale = Locale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(forSecondsFromGMT: 0)
    return formatter
}()




/*
//MARK: -- image
extension UIImage: Value {
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    public class func fromDatatypeValue(blobValue: Blob) -> UIImage {
        return UIImage(data: Data.fromDatatypeValue(blobValue))!
    }
    public var datatypeValue: Blob {
        return UIImagePNGRepresentation(self)!.datatypeValue
    }
    
}

extension Query {
    subscript(column: Expression<UIImage>) -> Expression<UIImage> {
        return namespace(column)
    }
    subscript(column: Expression<UIImage?>) -> Expression<UIImage?> {
        return namespace(column)
    }
}

extension Row {
    subscript(column: Expression<UIImage>) -> UIImage {
        return get(column)
    }
    subscript(column: Expression<UIImage?>) -> UIImage? {
        return get(column)
    }
}

let avatar = Expression<UIImage?>("avatar")
users[avatar]           // fails to compile
users.namespace(avatar) // "users"."avatar"

let user = users.first!
user[avatar]            // fails to compile
user.get(avatar)        // UIImage?
*/
*/
