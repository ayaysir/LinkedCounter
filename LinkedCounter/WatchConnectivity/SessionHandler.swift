//
//  SessionHandler.swift
//  LinkedCounter
//
//  Created by yoonbumtae on 2022/09/23.
//

import Foundation
import WatchConnectivity

class SessionHandler : NSObject, WCSessionDelegate {
    
    // 1: Singleton
    static let shared = SessionHandler()
    
    // 2: Property to manage session
    var session = WCSession.default
    
    override init() {
        super.init()
        
        // 3: Start and activate session if it's supported
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
        
        print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
    }
    
    func isSupported() -> Bool {
        WCSession.isSupported()
    }
    
    // MARK: - WCSessionDelegate
    
    // 4: Required protocols
    
    // a
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    // b
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive: \(session)")
    }
    
    // c
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate: \(session)")
        // Reactivate session
        /**
         * This is to re-activate the session on the phone when the user has switched from one
         * paired watch to second paired one. Calling it like this assumes that you have no other
         * threads/part of your code that needs to be given time before the switch occurs.
         */
        self.session.activate()
    }
    
    /// Observer to receive messages from watch and we be able to response it
    ///
    /// - Parameters:
    ///   - session: session
    ///   - message: message received
    ///   - replyHandler: response handler
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        guard let request = message["request"] as? String else {
            return
        }
        
        switch request {
        case "plusCount_get":
            replyHandler(makeResponse(localStorage.double(forKey: .cfgPlusCount)))
        case "totalCount_get":
            replyHandler(makeResponse(localStorage.double(forKey: .cfgTotalCount)))
        case "totalCount_plus":
            let oldValue = localStorage.double(forKey: .cfgTotalCount)
            let plusCount = localStorage.double(forKey: .cfgPlusCount)
            let newValue = oldValue + (plusCount > 0 ? plusCount : 5.0)
            localStorage.set(newValue, forKey: .cfgTotalCount)
            replyHandler(makeResponse(newValue))
            NotificationCenter.default.post(name: .refreshView, object: nil)
        case "totalCount_minus":
            let oldValue = localStorage.double(forKey: .cfgTotalCount)
            let plusCount = localStorage.double(forKey: .cfgPlusCount)
            let newValue = oldValue - (plusCount > 0 ? plusCount : 5.0)
            localStorage.set(newValue, forKey: .cfgTotalCount)
            replyHandler(makeResponse(newValue))
            NotificationCenter.default.post(name: .refreshView, object: nil)
        case "targetCount_get":
            replyHandler(makeResponse(localStorage.double(forKey: .cfgTargetCount)))
        default:
            break
        }
    }
    
    func sendDataForComplication() {
        print(#function, session.isReachable)
        if session.isReachable {
            session.transferCurrentComplicationUserInfo(["request": "forComplication"])
        }
    }
    
}
