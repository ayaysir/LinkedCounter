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
    
    @IBOutlet weak var table: WKInterfaceTable!
    @IBOutlet weak var button: WKInterfaceButton!
    
    // 1: Session property
    private var session = WCSession.default
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        items.append("We are ready!!")
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        // 2: Initialization of session and set as delegate this InterfaceController if it's supported
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
        
        print(session.isReachable)
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] timer in
            print("timer", self.session.isReachable)
            if session.isReachable {
                session.sendMessage(["request": "totalCount"]) { response in
                    print(#function, response)
                } errorHandler: { error in
                    print("Error sending message: %@", error)
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
    
    // 3. With our session property which allows implement a method for start communication
    // and manage the counterpart response
    @IBAction func sendMessage() {
        if session.isReachable {
            button.setEnabled(false)
            button.setTitle("receiving...")
            session.sendMessage(["request": "writeData"]) { response in
                self.items.append("Reply: \(response)")
                self.button.setEnabled(true)
                self.button.setTitle("button")
            } errorHandler: { error in
                print("Error sending message: %@", error)
            }
        } else {
            print("iPhone is not reachable!!")
        }
    }
    
    // MARK: - Items Table
    
    private var items = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.updateTable()
            }
        }
    }
    
    
    /// Updating all contents of WKInterfaceTable
    func updateTable() {
        table.setNumberOfRows(items.count, withRowType: "Row")
        for (i, item) in items.enumerated() {
            if let row = table.rowController(at: i) as? Row {
                row.label.setText(item)
            }
        }
    }
    
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
        // 2: Get message and append to list
        let msg = message["msg"]!
        self.items.append("\(msg)")
    }
}

class Row: NSObject {
    @IBOutlet weak var label: WKInterfaceLabel!
}
