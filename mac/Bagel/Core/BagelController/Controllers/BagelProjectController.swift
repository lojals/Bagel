//
//  BagelProjectController.swift
//  Bagel
//
//  Created by Yagiz Gurgul on 24/09/2018.
//  Copyright © 2018 Yagiz Lab. All rights reserved.
//

import Cocoa

class BagelProjectController: NSObject {
    
    var projectName: String?
    
    var deviceControllers: [BagelDeviceController] = []
    var selectedDeviceController: BagelDeviceController? {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("DidSelectDevice"), object: nil)
        }
    }
    
    func addPacket(newPacket: BagelPacket) {
        
        for deviceController in self.deviceControllers {
            
            if deviceController.deviceId == newPacket.device?.deviceId {
                
                deviceController.addPacket(newPacket: newPacket)
                return
            }
        }
        
        let deviceController = BagelDeviceController()
        
        deviceController.deviceId = newPacket.device?.deviceId
        deviceController.deviceName = newPacket.device?.deviceName
        deviceController.deviceDescription = newPacket.device?.deviceDescription
        
        deviceController.addPacket(newPacket: newPacket)
        
        self.deviceControllers.append(deviceController)
    }
}
