//
//  ZKORMConfigration.swift
//  ZKORM
//
//  Created by Kevin Zhou on 14/06/2017.
//  Copyright © 2017 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import GRDB

//MARK: Custom Class
open class ZKORMConfigration {
    public static var logLevel: LogLevel = .info
    
    private static var dbQueueMap:Dictionary<String,DatabaseQueue> = Dictionary<String,DatabaseQueue>()
    
    private static var defaultDBQueue:DatabaseQueue!
    private static var defaultDBName:String?
    
    /// 创建数据库
    ///
    /// - Parameters:
    ///   - path: 文件路径
    ///   - name: 数据库名字
    ///   - isAutoCreate: 文件不存在时候，是否自动创建文件。默认true
        public static func setDB(path:String,name:String,isAutoCreate:Bool = true){
            
    //        guard dbQueueMap[name] == nil else {
    //            return
    //        }

            do{
                let db = try DatabaseQueue(path:path)
                dbQueueMap[name] = db
            }catch{
                Log.e(error)
            }
            
            if logLevel == .debug {
                debugPrint("设置db名字：\(name),路径：\(path)")
            }
        }
    
        public static func setDefaultDB(path:String,name:String){
            
            guard dbQueueMap[name] == nil else {
                return
            }
            
            defaultDBName = name
            
            do{
                let db = try DatabaseQueue(path: path)
                dbQueueMap[name] = db
                
                defaultDBQueue = db
            }catch{
                Log.e(error)
            }
            
            if logLevel == .debug {
                debugPrint("设置默认db名字：\(name),路径：\(path)")
            }
        }
        
        public static func getDefaultDBQueue() throws -> DatabaseQueue{
            if let db = defaultDBQueue{
                return db
            }else{
                throw ZKORMError.dbNotFound(dbName:defaultDBName ?? "默认数据库")
            }
        }
        
        public static func getDBQueue(name:String) throws -> DatabaseQueue{
            if let db = dbQueueMap[name]{
                return db
            }else{
                throw ZKORMError.dbNotFound(dbName:name)
            }
            
        }
        
        private static func fileExists(_ path:String) -> Bool{
            var isDir:ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
            if exists && !isDir.boolValue {
                return true
            }
            return false
        }
    
}
