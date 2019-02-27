//
//  Constants.swift
//  Over21
//
//  Created by gold on 2019/2/27.
//  Copyright © 2019 Socket Mobile. All rights reserved.
//

import Foundation

let UPOS_E_CLOSED = 101
let UPOS_E_CLAIMED = 102
let UPOS_E_DISABLED = 105
let UPOS_E_FAILURE = 111
let UPOS_UNKOWN_ERROR_STRING = "Unknown"

let UPOS_ERROR_STRINGS = [
    UPOS_E_CLOSED: "Device to access is closed.",
    UPOS_E_CLAIMED: "Claim method should be called first.",
    UPOS_E_DISABLED: "Not enabled",
    UPOS_E_FAILURE: "The requested operation failed."
]
