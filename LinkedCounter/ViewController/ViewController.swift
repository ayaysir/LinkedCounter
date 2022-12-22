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
    
    @IBOutlet weak var btnQuickPlus1: UIButton!
    @IBOutlet weak var btnQuickPlus2: UIButton!
    @IBOutlet weak var btnQuickPlus3: UIButton!
    @IBOutlet weak var btnQuickPlus4: UIButton!
    @IBOutlet weak var btnQuickPlus5: UIButton!
    
    private var btnQuickPluses: [UIButton] {
        return [
            btnQuickPlus1,
            btnQuickPlus2,
            btnQuickPlus3,
            btnQuickPlus4,
            btnQuickPlus5,
        ]
    }
    
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
        initBtnQuickPluses()
        
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
            
            refeshValueBtnQuickPluses()
        }
    }
    
    private func initBtnQuickPluses() {
        btnQuickPluses.forEach { button in
            button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 12)
                return outgoing
            }
        }
    }
    
    private func refeshValueBtnQuickPluses() {
        btnQuickPluses.enumerated().forEach { (index, button) in
            let value = Double(index + 1) * stepperPlusCount.value
            button.setTitle("+ \(value.intText)", for: .normal)
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
    
    private func changeTotalCount(_ number: Double) {
        lblTotalCount.text = number.intText
        saveData()
    }
    
    private func changeStepCount(_ number: Double) {
        stepperTotalCount.stepValue = number
        lblPlusCount.text = number.intText
        saveData()
        refeshValueBtnQuickPluses()
    }
    
    private func changeTotalCount(increase: Double) {
        stepperTotalCount.value += increase
        changeTotalCount(stepperTotalCount.value)
    }

    // MARK: - IBActions
    
    @IBAction func stepperActTotalCount(_ sender: UIStepper) {
        changeTotalCount(sender.value)
    }
    
    @IBAction func steppperActPlusCount(_ sender: UIStepper) {
        changeStepCount(sender.value)
    }
    
    @IBAction func btnActQuickPlus(_ sender: UIButton) {
        let multiple = Double(sender.tag)
        changeTotalCount(increase: multiple * stepperPlusCount.value)
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

