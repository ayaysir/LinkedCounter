//
//  GlobalVariables.swift
//  LinkedCounter
//
//  Created by yoonbumtae on 2022/09/25.
//

import Foundation

let localStorage = UserDefaults.standard

extension String {
    static let cfgTotalCount = "cfgTotalCount"
    static let cfgPlusCount = "cfgPlusCount"
    static let cfgTargetCount = "cfgTargetCount"
}

func initData() {
    localStorage.set(0.0, forKey: .cfgTotalCount)
    localStorage.set(30.0, forKey: .cfgPlusCount)
    localStorage.set(3000.0, forKey: .cfgTargetCount)
}
