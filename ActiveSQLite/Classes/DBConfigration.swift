//
//  DBConfigration.swift
//  ActiveSQLite
//
//  Created by kai zhou on 14/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import SQLite

//MARK: Custom Class
open class DBConfigration{
    static var logLevel:LogLevel = .info
    static var isDefaultTime:Bool = true
    
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

open class DBConnection{
    
    static let sharedConnection:DBConnection = DBConnection()
    
    var db:Connection!
    
    private  init() {

        let dbPath = DBConfigration.getDBPath()!
        
        LogInfo(dbPath)
        db = try! Connection(dbPath)
        
//        #if DEBUG
//            DBModel.db.trace{ debugPrint($0)}
//        #endif
        
        if DBConfigration.logLevel == .debug {
            db.trace{ print($0)}
        }
        
    }
    
//    class func getDB() -> Connection{
//        let db =  try! Connection(DBConfigration.getDBPath()!)
//        return db
//    }
    
    //    func dataBaseFilePath()->String{
    //
    //        let fileManager = FileManager.default
    //
    //        let dbFilePath = "\(NSHomeDirectory())/Documents/ActiveSQLite.db"
    //
    //        if !fileManager.fileExists(atPath: dbFilePath) {
    //            let resourcePath = Bundle.main.path(forResource: "ActiveSQLite", ofType: "db")
    //            do{
    //                try fileManager.copyItem(atPath: resourcePath!, toPath: dbFilePath)
    //
    //            }catch{
    //
    //            }
    //
    //        }
    //
    //        return dbFilePath
    //    }
    
}

public extension Connection {
    //userVersion Database
    public var userVersion: Int32 {
        get { return Int32(try! scalar("PRAGMA user_version") as! Int64)}
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}

//MARK: - Help Methods
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

//MARK: - Extension
extension NSNumber : SQLite.Value {
    public static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    
    public static func fromDatatypeValue(_ datatypeValue: Int64) -> NSNumber {
        return NSNumber(value:datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
    
}

//Date -- Tnteger
extension NSDate: SQLite.Value {
    public static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    public static func fromDatatypeValue(_ intValue: Int64) -> NSDate {
        return NSDate(timeIntervalSince1970: TimeInterval(intValue))
    }
    public var datatypeValue: Int64 {
        return  Int64(timeIntervalSince1970)
    }
}



//MARK: - Logger

enum LogLevel:Int {
    case debug = 1,info,warn,error
}

func LogDebug(_ message: Any = "",
         file: String = #file,
         line: Int = #line,
         function: String = #function) {
//    debugPrint( "***[debug]***-\(Thread.current)-\(name(of: file))[\(line)]:\(function) --> \(message)")
    if DBConfigration.logLevel == .debug {
        print( "***[debug]***-\(name(of: file))[\(line)]:\(function) --> \(message)")
    }
}

func LogInfo(_ message: Any = "",
              file: String = #file,
              line: Int = #line,
              function: String = #function) {
    if DBConfigration.logLevel.rawValue >= LogLevel.info.rawValue {
        print( "***[info]***-\(name(of: file))[\(line)]:\(function) --> \(message)")
    }
    
}

func LogWarn(_ message: Any = "",
             file: String = #file,
             line: Int = #line,
             function: String = #function) {
    if DBConfigration.logLevel.rawValue >= LogLevel.warn.rawValue {
        print( "***[warn]***-\(name(of: file))[\(line)]:\(function) --> \(message)")
    }
    
    
}

func LogError(_ message: Any = "",
              file: String = #file,
              line: Int = #line,
              function: String = #function) {
    print( "***[error]***-\(name(of: file))[\(line)]:\(function) --> \(message)")
    
}


private func name(of file:String) -> String {
    return URL(fileURLWithPath: file).lastPathComponent
}

//
//func LogDebug(_ message:  Any?) {
//    Log("***[debug]***\(String(describing: message))")
//}
//
//func LogDebug(_ format:  @autoclosure () -> String, _ arguments: CVarArg...) {
//    LogDebug(String(format: format(), arguments: arguments))
//}
//
//func LogInfo(_ message:  Any?) {
//    Log("***[info]***\(String(describing: message))")
//}
//
//func LogInfo(_ format:  @autoclosure () -> String, _ arguments: CVarArg...) {
//    LogInfo(String(format: format(), arguments: arguments))
//}
//
//func LogWarn(_ message:  Any?) {
//    Log("***[warn]***\(String(describing: message))")
//}
//
//func LogWarn(_ format:  @autoclosure () -> String, _ arguments: CVarArg...) {
//    LogWarn(String(format: format(), arguments: arguments))
//}
//
//func LogError(_ message:  Any?) {
//    Log("***[error]***\(String(describing: message))")
//}
//
//func LogError(_ format:  @autoclosure () -> String, _ arguments: CVarArg...) {
//    LogError(String(format: format(), arguments: arguments))
//}
//



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
