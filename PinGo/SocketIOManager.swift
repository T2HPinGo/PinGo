//
//  SocketIOManager.swift
//  PinGo
//
//  Created by Cao Thắng on 8/14/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import Foundation
import SocketIOClientSwift
class SocketManager: NSObject {
    // 128.199.92.114
    static let sharedInstance = SocketManager()
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://192.168.10.53:4000")!)
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func pushCategory(ticket: [String: AnyObject]){
        socket.emit("CategoryChanel", ticket)
        
    }
}

