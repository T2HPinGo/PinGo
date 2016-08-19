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
    
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "\(API_URL)\(PORT_SOCKET)")!)
    
    
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
    
    func getWorkers(success: (worker: Worker) -> Void) {
        socket.on("newWorkerForTicket") { (dataArray, socketAck) -> Void in
            print("dataArray: \(dataArray)")
            if let item = dataArray[0] as? [String: AnyObject] {
                let worker = Worker(data: item)
                print("WorkerSocket: \(worker)")
                success(worker: worker)
            }
        }
    }
    
    func applyTicket(worker: [String: AnyObject], ticketId: String, price: String){
        print("workerBidTicket")
        socket.emit("workerBidTicket", worker, ticketId, price)
    }
    
    func getTicket(success: (ticket: Ticket)-> Void) {
        socket.on("newTicket") { (dataArray, socketAck) -> Void in
            let item = dataArray[0]
            print("Item: \(item)")
            let ticket = Ticket(data: item as! [String : AnyObject])
            success(ticket: ticket)
        }
    }
    
    func updateTicket(idTicket: String, statusTicket: String){
        print("Update Ticket")
        socket.emit("updateTicket", idTicket, statusTicket)
    }
    
    func getTicketHasUpdateStatus(success: (idTicket: String, statusTicket: String)-> Void) {
        socket.on("changeStatusTicket") { (dataArray, socketAck) -> Void in
            print("dataArray: \(dataArray)")
            let id = dataArray[0] as? String
            let status = dataArray[1] as? String
            success(idTicket: id!, statusTicket: status!)
        }
    }
}

