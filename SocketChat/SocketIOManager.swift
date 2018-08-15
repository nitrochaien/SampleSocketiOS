//
//  SocketIOManager.swift
//  SocketChat
//
//  Created by Nam Vu on 8/5/18.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    let manager = SocketManager(socketURL: URL(string: "http://192.168.1.150:3002")!)
    
    override init() {
        super.init()
    }
    
    func connect() {
        manager.connect()
    }
    
    func disconnect() {
        manager.disconnect()
    }
    
    func connectServer(with nickname: String, completionHandler: @escaping (_ userList: [[String : AnyObject]]) -> Void) {
        manager.defaultSocket.emit("connectUser", nickname)
        manager.defaultSocket.on("userList") { (array, ack) in
            completionHandler(array[0] as! [[String : AnyObject]])
        }
    }
    
    func exitChat(with nickname: String, completion: () -> Void) {
        manager.defaultSocket.emit("exitUser", nickname)
        completion()
    }
    
    func send(message: String, to nickname: String) {
        manager.defaultSocket.emit("chatMessage", nickname, message)
    }
    
    func getChatMessage(completion: @escaping (_ messageInfo: [String : String]) -> Void) {
        manager.defaultSocket.on("newChatMessage") { (array, ack) in
            var dict = [String : String]()
            dict["nickname"] = array[0] as? String
            dict["message"] = array[1] as? String
            dict["date"] = array[2] as? String
            
            completion(dict)
        }
    }
}
