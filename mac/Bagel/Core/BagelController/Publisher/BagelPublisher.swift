//
//  BagelPublisher.swift
//  Bagel
//
//  Created by Yagiz Gurgul on 26.09.2018.
//  Copyright © 2018 Yagiz Lab. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

protocol BagelPublisherDelegate {
    
    func didGetPacket(publisher: BagelPublisher, packet: BagelPacket)
}

class BagelPublisher: NSObject, GCDAsyncSocketDelegate, NetServiceDelegate {

    var delegate: BagelPublisherDelegate?
    
    var mainSocket: GCDAsyncSocket!
    var sockets: [GCDAsyncSocket] = []
    var netService: NetService!
    
    func startPublishing() {
        
        self.sockets = []
        
        self.mainSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)

        do {
            
            try self.mainSocket.accept(onPort: UInt16(Configuration.netServicePort))
            
            self.netService = NetService(domain: Configuration.netServiceDomain, type: Configuration.netServiceType, name: Configuration.netServiceName, port: Configuration.netServicePort)
            self.netService.delegate = self
            self.netService.publish()
            
        } catch {
            
            self.startPublishing()
        }
        
    }
    
    func netServiceDidPublish(_ sender: NetService) {
        
        print("publish", sender)
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        
        print("error", errorDict)
    }
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        
        self.sockets.append(newSocket)
        newSocket.readData(toLength: UInt(MemoryLayout<UInt64>.stride), withTimeout: -1.0, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        
        if tag == 0 {
            
            let length = self.lengthOf(data: data)
            sock.readData(toLength: UInt(length), withTimeout: 30.0, tag: 1)
            
        } else if tag == 1 {
            
            self.parseBody(data: data)
            sock.readData(toLength: UInt(MemoryLayout<UInt64>.stride), withTimeout: 30.0, tag: 0)
        }
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
        if self.sockets.contains(sock) {
            
            sock.delegate = nil
            
            self.sockets = Array(self.sockets.filter { $0 !== sock })
            
            if self.sockets.count == 0 {
                
                self.startPublishing()
            }
            
        }

    }
    
    func lengthOf(data: Data) -> Int {
        
        var length = 0
        memcpy(&length, ([UInt8](data)), MemoryLayout<UInt64>.stride)

        return length
    }
    
    func parseBody(data: Data) {
        
        let jsonDecoder = JSONDecoder()
        
        do {
            
            let bagelPacket = try jsonDecoder.decode(BagelPacket.self, from: data)
            delegate?.didGetPacket(publisher: self, packet: bagelPacket)
            
        } catch {
            
            print(error)
        }
    }
}
