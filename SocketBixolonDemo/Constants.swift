//
//  Constants.swift
//  Over21
//
//  Created by gold on 2019/2/27.
//  Copyright © 2019 Socket Mobile. All rights reserved.
//

import Foundation

let UPOS_E_CLOSED       = 101
let UPOS_E_CLAIMED      = 102
let UPOS_E_DISABLED     = 105
let UPOS_E_FAILURE      = 111
let UPOS_UNKOWN_ERROR_STRING = "Unknown"

let PTR_BCS_EAN13       = 104
let PTR_BCS_PDF417      = 201

let PTR_BC_TEXT_NONE = -11
let PTR_BC_TEXT_ABOVE = -12
let PTR_BC_TEXT_BELOW = -13

let PTR_BC_LEFT = -1
let PTR_BC_CENTER = -2
let PTR_BC_RIGHT = -3

let UPOS_ERROR_STRINGS = [
    UPOS_E_CLOSED: "Device to access is closed.",
    UPOS_E_CLAIMED: "Claim method should be called first.",
    UPOS_E_DISABLED: "Not enabled",
    UPOS_E_FAILURE: "The requested operation failed."
]

let TYPE_DRIVER_LICENSE_INDEX = 0
let TYPE_PASSPORT_INDEX = 1
let TYPE_TRAVEL_ID_INDEX = 2

let AGE_LIMIT_VALUES = [18, 21, 60]

let SCANNER_CMD_OCR_B_ENABLE            : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xA9, 0x01]

let SCANNER_CMD_OCR_ORIENTATION_0       : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x00]
let SCANNER_CMD_OCR_ORIENTATION_270     : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x01]
let SCANNER_CMD_OCR_ORIENTATION_180     : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x02]
let SCANNER_CMD_OCR_ORIENTATION_90      : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x03]
let SCANNER_CMD_OCR_ORIENTATION_OMNI    : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x04]

let SCANNER_CMD_OCR_B_FULL_ASCII        : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x00]
let SCANNER_CMD_OCR_B_BANKING           : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x01]
let SCANNER_CMD_OCR_B_LIMITED           : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x02]
let SCANNER_CMD_OCR_B_ISBN10            : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x06]
let SCANNER_CMD_OCR_B_ISBN10_13         : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x07]
let SCANNER_CMD_OCR_B_TD1               : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x03]
let SCANNER_CMD_OCR_B_TD2               : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x08]
let SCANNER_CMD_OCR_B_TID               : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x14]
let SCANNER_CMD_OCR_B_PASSPORT          : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x04]
let SCANNER_CMD_OCR_B_VISAA             : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x09]
let SCANNER_CMD_OCR_B_VISAB             : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x0A]
let SCANNER_CMD_OCR_B_ICAO              : [UInt8] = [0x08, 0xC6, 0x04, 0x00, 0xFF, 0xF1, 0xAF, 0x0B]
