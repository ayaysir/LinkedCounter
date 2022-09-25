//
//  ViewController.swift
//  LinkedCounter
//
//  Created by yoonbumtae on 2022/09/23.
//

import UIKit
import AVFoundation

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
    
    private var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 초기화(임시)
        // stepperTotalCount.value = 0
        // stepperTotalCount.stepValue = stepperPlusCount.value
        
        // 초기화
        refreshView(nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: .refreshView, object: nil)
    }
    
    @objc func refreshView(_ notificaiton: Notification?) {
        
        if notificaiton != nil {
            playSound()
        }
        
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
    
    
    
    @IBAction func btnActSendComplicationData(_ sender: Any) {
        print(#function)
        SessionHandler.shared.sendDataForComplication()
    }
    
    
    func playSound() {
        let soundName = "snd_fragment_retrievewav-14728"
        // forResource: 파일 이름(확장자 제외) , withExtension: 확장자(mp3, wav 등) 입력
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopSound() {
        player?.stop()
    }
    
    // @IBAction func sendMessage(_ sender: Any) {
    //     messagesCounter += 1
    //     // 3: Send message to apple watch, we don't wait to response, only trace errors
    //     connectivityHandler.session.sendMessage(["msg" : "Message \(messagesCounter)"], replyHandler: nil) { error in
    //         print("Error sending message: \(error)")
    //     }
    // }
    
}

