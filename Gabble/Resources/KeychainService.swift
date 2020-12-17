//
//  KeychainService.swift
//  Gabble
//
//  Created by ZoeZ on 11/24/20.
//

import Foundation
import KeychainSwift

class KeychainService {
    var _localVar = KeychainSwift()
    var keyChain : KeychainSwift {
        get {
            return _localVar
        }
        set {
            _localVar = newValue
        }
    }
}
