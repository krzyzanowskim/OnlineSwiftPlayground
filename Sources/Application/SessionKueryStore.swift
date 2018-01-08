// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

//import SwiftKuery
//import KituraSession
//import Foundation
//
//public class SessionKueryStore: Store {
//
//    class Sessions: Table {
//        let tableName = "Sessions"
//        let id = Column("id", Char.self, primaryKey: true)
//        let data = Column("data", String.self)
//    }
//
//    private let db: SwiftKuery.Connection
//    private var sessions: Sessions
//
//    init(connection: SwiftKuery.Connection) {
//        db = connection
//        sessions = Sessions()
//        setupDB()
//    }
//
//    private func setupDB() {
//        sessions.create(connection: db) { (result) in
//            guard result.success else {
//                print("Failed to create table: \(result)")
//                return
//            }
//        }
//    }
//
//    public func load(sessionId: String, callback: @escaping (Data?, NSError?) -> Void) {
//        let query = Select(sessions.data, from: sessions).where(sessions.id == sessionId)
//        db.execute(query: query) { (result) in
//            guard result.success else {
//                callback(nil, result.asError as NSError?)
//                return
//            }
//
//            if let row = result.asRows?.first {
//                if let base64String = row[self.sessions.data.name] as? String, let decodedData = Data(base64Encoded: base64String) {
//                    callback(decodedData, nil)
//                    return
//                }
//            }
//            
//            callback(nil, nil)
//        }
//    }
//
//    public func save(sessionId: String, data: Data, callback: @escaping (NSError?) -> Void) {
//        let query = Insert(into: sessions, rows: [[sessionId, data.base64EncodedString()]])
//        db.execute(query: query) { (result) in
//            guard result.success else {
//                callback(result.asError as NSError?)
//                return
//            }
//
//            callback(nil)
//        }
//    }
//
//    public func touch(sessionId: String, callback: @escaping (NSError?) -> Void) {
//        // wat?
//        callback(nil)
//    }
//
//    public func delete(sessionId: String, callback: @escaping (NSError?) -> Void) {
//        let query = Delete(from: sessions, where: sessions.id == sessionId)
//        db.execute(query: query) { (result) in
//            guard result.success else {
//                callback(result.asError as NSError?)
//                return
//            }
//            callback(nil)
//        }
//    }
//
//}

