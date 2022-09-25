//
//  InterfaceController.swift
//  LinkedCounter WatchKit Extension
//
//  Created by yoonbumtae on 2022/09/23.
//

import WatchKit
import Foundation
import WatchConnectivity
import ClockKit

struct CurrentData {
    
    static var shared = CurrentData(currentTotalCount: nil, targetCount: nil)
    
    var currentTotalCount: Double?
    var targetCount: Double?
}

class InterfaceController: WKInterfaceController {
    
    enum LabelStatus {
        case stepValue, normal, error
    }
    
    @IBOutlet weak var lblTotalCount: WKInterfaceLabel!
    @IBOutlet weak var lblStatus: WKInterfaceLabel!
    @IBOutlet weak var btnMinus: WKInterfaceButton!
    @IBOutlet weak var btnPlus: WKInterfaceButton!
    
    // 1: Session property
    private var session = WCSession.default
    
    private var totalCount: Double!
    private var plusCount: Double!
    
    private var initTotalCountLoaded = false
    private var initPlusCountLoaded = false
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        // 2: Initialization of session and set as delegate this InterfaceController if it's supported
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] timer in
            print("timer", self.session.isReachable)
            if session.isReachable {
                fetchDataFromRootDevice()
                timer.invalidate()
            } else {
                print(#function, "iPhone is not reachable!!")
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        reloadComplicationTimeline()
        
    }
    
    // MARK: - UI Helper
    
    private func turnAllButton(_ isEnable: Bool) {
        btnPlus.setEnabled(isEnable)
        btnMinus.setEnabled(isEnable)
    }
    
    private func setCountLabel(_ text: String, color: UIColor = .white) {
        lblTotalCount.setTextColor(color)
        lblTotalCount.setText(text)
    }
    
    private func setStatus(_ status: LabelStatus, _ text: String) {
        switch status {
        case .stepValue:
            lblStatus.setTextColor(.white)
            lblStatus.setText("Step Value: \(text)")
        case .normal:
            lblStatus.setTextColor(.white)
            lblStatus.setText(text)
        case .error:
            lblStatus.setTextColor(.red)
            lblStatus.setText("Error: \(text)")
        }
    }
    
    // MARK: - Handle Watch's system
    
    private func requestChangeTotalCount(_ request: String, completionHandler: @escaping () -> (), failedHandler: @escaping () -> ()) {
        if session.isReachable {
            session.sendMessage(makeRequest("totalCount_\(request)")) { response in
                
                if let totalCount = response["response"] as? Double {
                    self.totalCount = totalCount
                    self.setCountLabel(totalCount.intText)
                    // Set CurrentData
                    CurrentData.shared.currentTotalCount = totalCount
                    print("Request success:", totalCount)
                    completionHandler()
                } else {
                    print("Request failed:", #line)
                    failedHandler()
                }
            } errorHandler: { error in
                print("Error sending message: %@", error)
                failedHandler()
            }
        } else {
            print("Request failed:", #line)
            failedHandler()
        }
    }
    
    private func fetchDataFromRootDevice() {
        if session.isReachable {
            turnAllButton(false)
            
            setCountLabel("...")
            setStatus(.normal, "Loading status...")
            
            session.sendMessage(makeRequest("plusCount_get")) { response in
                
                if let plusCount = response["response"] as? Double {
                    self.plusCount = plusCount
                    self.setStatus(.stepValue, plusCount.intText)
                    self.initPlusCountLoaded = true
                    if self.initTotalCountLoaded {
                        self.turnAllButton(true)
                    }
                } else {
                    self.setStatus(.error, "Unknown")
                }
            } errorHandler: { error in
                print("Error sending message: %@", error)
                self.setStatus(.error, error.localizedDescription)
            }
            
            session.sendMessage(makeRequest("totalCount_get")) { response in
                
                if let totalCount = response["response"] as? Double {
                    self.totalCount = totalCount
                    self.setCountLabel(totalCount.intText)
                    self.initTotalCountLoaded = true
                    // Set CurrentData
                    CurrentData.shared.currentTotalCount = totalCount
                    if self.initPlusCountLoaded {
                        self.turnAllButton(true)
                    }
                } else {
                    self.setCountLabel("ERROR", color: .red)
                }
            } errorHandler: { error in
                print("Error sending message: %@", error)
                self.setCountLabel("ERROR", color: .red)
            }
        }
    }
    
    private func reloadComplicationTimeline() {
        if let complication = CLKComplicationServer.sharedInstance().activeComplications?.first {
            CLKComplicationServer.sharedInstance().reloadTimeline(for: complication)
        }
    }
    
    // MARK: - @IBActions
    
    @IBAction func btnActRefresh() {
       fetchDataFromRootDevice()
    }
    
    @IBAction func btnActMinus() {
        print(#function)
        // 시계 디스플레이는 plusCount 만큼 일단 올리고
        // 맞으면 확정 표시
        // 틀리면 롤백
        guard let plusCount = plusCount else { return }
        totalCount = totalCount - plusCount
        setCountLabel(totalCount.intText)
        setStatus(.normal, "Syncing...")
        
        requestChangeTotalCount("minus") { [self] in
            setStatus(.stepValue, plusCount.intText)
            // Set CurrentData
            CurrentData.shared.currentTotalCount = totalCount
        } failedHandler: { [self] in
            totalCount = totalCount + plusCount
            setCountLabel(totalCount.intText)
        }
    }
    
    @IBAction func btnActPlus() {
        print(#function)
        // 시계 디스플레이는 plusCount 만큼 일단 올리고
        // 맞으면 확정 표시
        // 틀리면 롤백
        guard let plusCount = plusCount else { return }
        totalCount = totalCount + plusCount
        setCountLabel(totalCount.intText)
        setStatus(.normal, "Syncing...")
        
        requestChangeTotalCount("plus") { [self] in
            setStatus(.stepValue, plusCount.intText)
            // Set CurrentData
            CurrentData.shared.currentTotalCount = totalCount
        } failedHandler: { [self] in
            totalCount = totalCount - plusCount
            setCountLabel(totalCount.intText)
        }
    }
}


extension InterfaceController: WCSessionDelegate {
    
    // MARK: - WCSessionDelegate
    
    // 4: Required stub for delegating session
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    // Receive messages from iPhone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // 1: We launch a sound and a vibration
        WKInterfaceDevice.current().play(.notification)
    
        if let totalCount = message["totalCount"] as? Double {
            self.totalCount = totalCount
            setCountLabel(totalCount.intText)
        }
        
        if let plusCount = message["plusCount"] as? Double, self.plusCount != plusCount {
            self.plusCount = plusCount
            setStatus(.stepValue, plusCount.intText)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("received UserInfo:", userInfo)
    }
}
