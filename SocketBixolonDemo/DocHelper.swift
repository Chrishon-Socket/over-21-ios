//
//  DocHelper.swift
//  Over21
//
//  Created by gold on 2019/3/8.
//  Copyright © 2019 Socket Mobile. All rights reserved.
//

import Foundation
import SKTCapture

func parseDoc(_ decodedData: SKTCaptureDecodedData?, _ type: Int) -> [String: String] {
    if let data = decodedData?.stringFromDecodedData() {
        print("\(decodedData?.dataSourceID.rawValue), \(decodedData?.dataSourceName), \(data)")
        return parseDoc(data, type, decodedData?.dataSourceID) ?? [:]
    }
    
    return [:]
}

func parseDoc(_ data: String, _ type: Int, _ dataSourceID: SKTCaptureDataSourceID?) -> [String: String]? {
    if type == TYPE_DRIVER_LICENSE_INDEX && dataSourceID == SKTCaptureDataSourceID.symbologyPdf417 {
        return parseDriverLicense(data)
    } else if type == TYPE_PASSPORT_INDEX {
        return parsePassport(data)
    } else if type == TYPE_TRAVEL_ID_INDEX {
        return parseTravelID(data)
    }
    
    return nil
}
func parsePassport(_ data: String) -> [String: String]? {
    var map: [String: String] = [:]
    let trimmedData = data.replacingOccurrences(of: "\n", with: "")
    if trimmedData.count == 88 {
        let dateOfBirth = String(trimmedData[trimmedData.index(trimmedData.startIndex, offsetBy: 57)..<trimmedData.index(trimmedData.startIndex, offsetBy: 63)])
        let expiryDate = String(trimmedData[trimmedData.index(trimmedData.startIndex, offsetBy: 65)..<trimmedData.index(trimmedData.startIndex, offsetBy: 71)])
        let name = String(trimmedData[trimmedData.index(trimmedData.startIndex, offsetBy: 5)..<trimmedData.index(trimmedData.startIndex, offsetBy: 44)])
        
        let surnameEndIndex = name.range(of: "<<")
        let surname = String(name.prefix(surnameEndIndex?.lowerBound.encodedOffset ?? 0))
        let givenname = String(name.suffix(39 - (surnameEndIndex?.upperBound.encodedOffset ?? 1) + 1)).replacingOccurrences(of: "<", with: " ").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        map["DBB"] = dateOfBirth
        map["DBA"] = expiryDate
        map["DAB"] = surname
        map["DAC"] = givenname
    } else {
        return nil
    }
    return map
}
func parseDriverLicense(_ data: String) -> [String: String]? {
    var map: [String: String] = [:]
    let words = data.components(separatedBy: "\n")
    
    for word in words {
        //print("word: \(word)")
        let offset: Int = 3
        
        guard word.count > offset else { continue }
        
        let upperIndex = word.index(word.startIndex, offsetBy: offset - 1)
        
        let dataType = String(word[...upperIndex])
        
        let lowerIndex = word.index(word.startIndex, offsetBy: offset)
        let dataFromWord = String(word[lowerIndex...])
        
        map[dataType] = dataFromWord
        
        print("\(dataType) - \(dataFromWord)")
    }
    
    return map
}
func parseTravelID(_ data: String) -> [String: String]? {
    var map: [String: String] = [:]
    
    let trimmedData = data.replacingOccurrences(of: "\n", with: "")
    if trimmedData.count == 90 {
        let dateOfBirth = String(trimmedData[trimmedData.index(trimmedData.startIndex, offsetBy: 30)..<trimmedData.index(trimmedData.startIndex, offsetBy: 36)])
        let expiryDate = String(trimmedData[trimmedData.index(trimmedData.startIndex, offsetBy: 38)..<trimmedData.index(trimmedData.startIndex, offsetBy: 44)])
        let name = String(trimmedData[trimmedData.index(trimmedData.startIndex, offsetBy: 60)..<trimmedData.index(trimmedData.startIndex, offsetBy: 90)])
        
        let surnameEndIndex = name.range(of: "<<")
        let surname = String(name.prefix(surnameEndIndex?.lowerBound.encodedOffset ?? 0))
        let givenname = String(name.suffix(30 - (surnameEndIndex?.upperBound.encodedOffset ?? 1) + 1)).replacingOccurrences(of: "<", with: " ").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        map["DBB"] = dateOfBirth
        map["DBA"] = expiryDate
        map["DAB"] = surname
        map["DAC"] = givenname
    } else {
        return nil
    }
    
    return map
}
