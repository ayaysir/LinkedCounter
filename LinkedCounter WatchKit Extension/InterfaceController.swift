//
//  InterfaceController.swift
//  LinkedCounter WatchKit Extension
//
//  Created by yoonbumtae on 2022/09/23.
//

import WatchKit
import Foundation

// WCSession 등
import WatchConnectivity

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
                
                turnAllButton(false)
                
                lblTotalCount.setText("...")
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
                        self.lblTotalCount.setText(totalCount.intText)
                        self.initTotalCountLoaded = true
                        if self.initPlusCountLoaded {
                            self.turnAllButton(true)
                        }
                    } else {
                        self.lblTotalCount.setText("ERROR")
                        self.lblTotalCount.setTextColor(.red)
                    }
                } errorHandler: { error in
                    print("Error sending message: %@", error)
                    self.lblTotalCount.setText("ERROR")
                    self.lblTotalCount.setTextColor(.red)
                }

                timer.invalidate()
            } else {
                print(#function, "iPhone is not reachable!!")
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    private func turnAllButton(_ isEnable: Bool) {
        btnPlus.setEnabled(isEnable)
        btnMinus.setEnabled(isEnable)
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
    
    private func requestChangeTotalCount(_ request: String, failedHandler: @escaping () -> ()) {
        if session.isReachable {
            session.sendMessage(makeRequest("totalCount_\(request)")) { response in
                
                if let totalCount = response["response"] as? Double {
                    self.totalCount = totalCount
                    self.lblTotalCount.setText(totalCount.intText)
                    print("Request success:", totalCount)
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
    
    @IBAction func btnActMinus() {
        print(#function)
        // 시계 디스플레이는 plusCount 만큼 일단 올리고
        // 맞으면 확정 표시
        // 틀리면 롤백
        guard let plusCount = plusCount else { return }
        totalCount = totalCount - plusCount
        lblTotalCount.setText(totalCount.intText)
        
        requestChangeTotalCount("minus") { [self] in
            totalCount = totalCount + plusCount
            lblTotalCount.setText(totalCount.intText)
        }
    }
    
    @IBAction func btnActPlus() {
        print(#function)
        // 시계 디스플레이는 plusCount 만큼 일단 올리고
        // 맞으면 확정 표시
        // 틀리면 롤백
        guard let plusCount = plusCount else { return }
        totalCount = totalCount + plusCount
        lblTotalCount.setText(totalCount.intText)
        
        requestChangeTotalCount("plus") { [self] in
            totalCount = totalCount - plusCount
            lblTotalCount.setText(totalCount.intText)
        }
    }
    
    // // 3. With our session property which allows implement a method for start communication
    // // and manage the counterpart response
    // @IBAction func sendMessage() {
    //     if session.isReachable {
    //         button.setEnabled(false)
    //         button.setTitle("receiving...")
    //         session.sendMessage(["request": "writeData"]) { response in
    //             self.items.append("Reply: \(response)")
    //             self.button.setEnabled(true)
    //             self.button.setTitle("button")
    //         } errorHandler: { error in
    //             print("Error sending message: %@", error)
    //         }
    //     } else {
    //         print("iPhone is not reachable!!")
    //     }
    // }
    //
    // // MARK: - Items Table
    //
    // private var items = [String]() {
    //     didSet {
    //         DispatchQueue.main.async {
    //             self.updateTable()
    //         }
    //     }
    // }
    //
    //
    // /// Updating all contents of WKInterfaceTable
    // func updateTable() {
    //     table.setNumberOfRows(items.count, withRowType: "Row")
    //     for (i, item) in items.enumerated() {
    //         if let row = table.rowController(at: i) as? Row {
    //             row.label.setText(item)
    //         }
    //     }
    // }
    
}

extension InterfaceController: WCSessionDelegate {
    
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
            lblTotalCount.setText(totalCount.intText)
        }
        
        if let plusCount = message["plusCount"] as? Double, self.plusCount != plusCount {
            self.plusCount = plusCount
            setStatus(.stepValue, plusCount.intText)
        }
    }
}
