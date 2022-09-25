//
//  RequestAndResponse.swift
//  LinkedCounter
//
//  Created by yoonbumtae on 2022/09/23.
//

import Foundation

func makeRequest(_ value: Any) -> [String: Any] {
    return ["request": value]
}

func makeResponse(_ value: Any) -> [String: Any] {
    return ["response": value]
}

func makeRequestForSendToWatch(totalCount: Double, plusCount: Double, targetCount: Double? = nil) -> [String: Any] {
    var dict = [
        "totalCount": totalCount,
        "plusCount": plusCount,
    ]
    
    if let targetCount = targetCount {
        dict["targetCount"] = targetCount
    }
    
    return dict
}
