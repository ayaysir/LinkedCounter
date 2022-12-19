//
//  ViewController.swift
//  LinkedCounter
//
//  Created by yoonbumtae on 2022/09/23.
//

import UIKit
import AVFoundation

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

    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 배지 표시 권한 요청
        requestBadgeAuth()
        
        // 초기화
        refreshView(nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshView), name: .refreshView, object: nil)
    }
    
    // MARK: - Init VC
    
    private func requestBadgeAuth() {
        let userNotiCenter = UNUserNotificationCenter.current()
        let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.badge,])
        
        userNotiCenter.requestAuthorization(options: notiAuthOptions) { (success, error) in
            if let error = error {
                print(#function, error)
            }
        }
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
            
            changeBadge(stepperTotalCount.value.int)
        }
    }
    
    // MARK: - Internal methods
    
    func saveData() {
        localStorage.set(stepperTotalCount.value,forKey: .cfgTotalCount)
        localStorage.set(stepperPlusCount.value,forKey: .cfgPlusCount)
        
        changeBadge(stepperTotalCount.value.int)
        
        connectivityHandler.session.sendMessage(makeRequestForSendToWatch(totalCount: stepperTotalCount.value, plusCount: stepperPlusCount.value), replyHandler: nil) { error in
            print("Error sending message: \(error)")
        }
    }
    
    func changeBadge(_ number: Int) {
        UIApplication.shared.applicationIconBadgeNumber = number
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

    // MARK: - IBActions
    
    @IBAction func stepperActTotalCount(_ sender: UIStepper) {
        lblTotalCount.text = sender.value.intText
        saveData()
    }
    
    @IBAction func steppperActPlusCount(_ sender: UIStepper) {
        stepperTotalCount.stepValue = sender.value
        lblPlusCount.text = sender.value.intText
        saveData()
    }
    
    // MARK: - Navigations
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingVCSegue" {
            let settingVC = segue.destination as? SettingViewController
            settingVC?.delegate = self
        }
    }
    
    // MARK: - Unused
    
    // @IBAction func btnActSendComplicationData(_ sender: Any) {
    //     print(#function)
    //     SessionHandler.shared.sendDataForComplication()
    // }
    
    
    // @IBAction func sendMessage(_ sender: Any) {
    //     messagesCounter += 1
    //     // 3: Send message to apple watch, we don't wait to response, only trace errors
    //     connectivityHandler.session.sendMessage(["msg" : "Message \(messagesCounter)"], replyHandler: nil) { error in
    //         print("Error sending message: \(error)")
    //     }
    // }
    
}

extension ViewController: SettingVCDelegate {
    
    // MARK: - SettingVCDelegate
    
    func didResetAllData(_ controller: SettingViewController) {
        initData()
        
        let totalCount = localStorage.double(forKey: .cfgTotalCount)
        let plusCount = localStorage.double(forKey: .cfgPlusCount)
        let targetCount = localStorage.double(forKey: .cfgTargetCount)
        
        refreshView(nil)
        connectivityHandler.session.sendMessage(makeRequestForSendToWatch(totalCount: totalCount, plusCount: plusCount, targetCount: targetCount), replyHandler: nil) { error in
            print("Error sending message: \(error)")
        }
    }
}

