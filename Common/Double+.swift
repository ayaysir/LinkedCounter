//
//  Double+.swift
//  LinkedCounter
//
//  Created by yoonbumtae on 2022/09/23.
//

import Foundation

extension Double {
    var int: Int {
        return Int(self)
    }
    
    var intText: String {
        return "\(self.int)"
    }
    
    var rationalizedText: String {
        if self >= 1000 && self <= 99999 {
            return (self / 1000).intText + "K"
        } else {
            return self.intText
        }
    }
}
