//
//  ViewController.swift
//  LinkedCounter
//
//  Created by yoonbumtae on 2022/09/23.
//

import UIKit

let localStorage = UserDefaults.standard

extension String {
    static let cfgTotalCount = "cfgTotalCount"
    static let cfgPlusCount = "cfgPlusCount"
}

class ViewController: UIViewController {
    
    @IBOutlet weak var lblTotalCount: UILabel!
    @IBOutlet weak var stepperTotalCount: UIStepper!
    @IBOutlet weak var lblPlusCount: UILabel!
    @IBOutlet weak var stepperPlusCount: UIStepper!
    
    // 1: Get singleton class whitch manage WCSession
    var connectivityHandler = SessionHandler.shared
    
    // 2: Counter for manage number of messages sended
    var messagesCounter = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 초기화(임시)
        // stepperTotalCount.value = 0
        // stepperTotalCount.stepValue = stepperPlusCount.value
        
        // 초기화
        refreshView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: .refreshView, object: nil)
    }
    
    @objc func refreshView() {
        DispatchQueue.main.async { [unowned self] in
            let plusCount = localStorage.double(forKey: .cfgPlusCount)
            stepperTotalCount.value = localStorage.double(forKey: .cfgTotalCount)
            stepperTotalCount.stepValue = plusCount > 0.0 ? plusCount : 30.0
            stepperPlusCount.value = stepperTotalCount.stepValue
            
            lblTotalCount.text = stepperTotalCount.value.intText
            lblPlusCount.text = stepperTotalCount.stepValue.intText
        }
    }
    
    func saveData() {
        localStorage.set(stepperTotalCount.value,forKey: .cfgTotalCount)
        localStorage.set(stepperPlusCount.value,forKey: .cfgPlusCount)
        
        connectivityHandler.session.sendMessage(makeRequestForSendToWatch(totalCount: stepperTotalCount.value, plusCount: stepperPlusCount.value), replyHandler: nil) { error in
            print("Error sending message: \(error)")
        }
    }

    @IBAction func stepperActTotalCount(_ sender: UIStepper) {
        lblTotalCount.text = sender.value.intText
        saveData()
    }
    
    @IBAction func steppperActPlusCount(_ sender: UIStepper) {
        stepperTotalCount.stepValue = sender.value
        lblPlusCount.text = sender.value.intText
        saveData()
    }
    
    // @IBAction func sendMessage(_ sender: Any) {
    //     messagesCounter += 1
    //     // 3: Send message to apple watch, we don't wait to response, only trace errors
    //     connectivityHandler.session.sendMessage(["msg" : "Message \(messagesCounter)"], replyHandler: nil) { error in
    //         print("Error sending message: \(error)")
    //     }
    // }
    
}

