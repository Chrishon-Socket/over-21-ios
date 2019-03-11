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
