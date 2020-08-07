//
//  ZKORMError.swift
//  ZKORM
//
//  Created by Kevin Zhou on 2020/7/7.
//  Copyright © 2020 hereigns. All rights reserved.
//

import Foundation

public enum ZKORMError:Error{
    case dbNotFound(dbName:String)
}

extension ZKORMError: LocalizedError{
    public var errorDescription: String?{
        switch self {
        case .dbNotFound(_):
            return description
//        default:
//            return "未知错误。"
        }
    }
    
}

extension ZKORMError:CustomNSError{
    public static var errorDomain: String {
        return "com.hereigns.ios.ZKORM"
    }
    public var errorCode: Int{
        switch self {
        case .dbNotFound(_):
            return 10001
//        default:
//            return 00000
        }
    }
    public var errorUserInfo: [String: Any] {
        switch self {
        case .dbNotFound(let dbName):
            return [NSLocalizedDescriptionKey:"找不到数据库:【\(dbName)】"]
        }
        
    }

}

extension ZKORMError:CustomStringConvertible,CustomDebugStringConvertible{
    public var description: String{
        return "EaseSQLiteError: errodCode:\(errorCode),errorDomain:\(ZKORMError.errorDomain),errorDescription：\(errorUserInfo)"
    }
    
    public var debugDescription: String{
        return description
    }
}
