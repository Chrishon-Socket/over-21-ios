//
//  Settings.swift
//  Over21
//
//  Created by Chrishon Wyllie on 11/13/18.
//  Copyright © 2018 Socket Mobile. All rights reserved.
//

import UIKit
import SKTCapture

class Settings: NSObject {
    
    private let symbologiesKey: String = "disabledSymbologies"
    
    public static var shared = Settings()
    
    private override init() {
        super.init()
    }
    
    
    
    
    
    public var disabledSymbologies: [Int]? {
        return UserDefaults.standard.array(forKey: symbologiesKey) as? [Int]
    }
    
    public func disableDataSource(withId symbologyId: SKTCaptureDataSourceID, forDevice device: CaptureHelperDevice) {
        
        var listOfDisabledSymbologies: [Int] = []
        
        if let list = disabledSymbologies {
            listOfDisabledSymbologies = list
        }
        
        let dataSource = SKTCaptureDataSource()
        dataSource.id = symbologyId
        dataSource.status = .disabled
        device.setDataSourceInfo(dataSource) { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            if result != SKTResult.E_NOERROR {
                print("Error disabling symbology with id: \(symbologyId)")
                return
            }
            
            guard listOfDisabledSymbologies.contains(symbologyId.rawValue) == false else {
                // Keep from adding the same disabled symbologies more than once
                return
            }
            
            listOfDisabledSymbologies.append(symbologyId.rawValue)
            
            UserDefaults.standard.set(listOfDisabledSymbologies, forKey: strongSelf.symbologiesKey)
            UserDefaults.standard.synchronize()
        }
        
    }
    
    public func restoreDefaultSettings() {
        
        guard let device = CaptureHelper.sharedInstance.getDevices().first else { return }
        
        if let listOfDisabledSymbologies = disabledSymbologies {
            
            for i in 0..<listOfDisabledSymbologies.count {
                
                let rawValue = listOfDisabledSymbologies[i]
                let dataSource = SKTCaptureDataSource()
                guard let sourceId = SKTCaptureDataSourceID(rawValue: rawValue) else { continue }
                dataSource.id = sourceId
                dataSource.status = .enabled
                
                device.setDataSourceInfo(dataSource) { (result) in
                    if result != SKTResult.E_NOERROR {
                        print("Error re enabling dataSource: \(dataSource)")
                    }
                    print("restore result: \(result) --- for dataSource: \(dataSource)")
                }
                
            }
        }
        
        let dictionary = UserDefaults.standard.dictionaryRepresentation()
        dictionary.keys.forEach { (key) in
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
    }
}
