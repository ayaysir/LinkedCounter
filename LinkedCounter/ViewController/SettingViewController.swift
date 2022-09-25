//
//  SettingViewController.swift
//  LinkedCounter
//
//  Created by yoonbumtae on 2022/09/25.
//

import UIKit

protocol SettingVCDelegate: AnyObject {
    func didResetAllData(_ controller: SettingViewController)
}

class SettingViewController: UIViewController {
    
    @IBOutlet weak var lblTargetCount: UILabel!
    @IBOutlet weak var stepperTargetCount: UIStepper!
    
    var connectivityHandler = SessionHandler.shared
    weak var delegate: SettingVCDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        let targetCount = localStorage.double(forKey: .cfgTargetCount)
        stepperTargetCount.value = targetCount
        lblTargetCount.text = targetCount.intText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func stepperActTargetCount(_ sender: UIStepper) {
        lblTargetCount.text = sender.value.intText
        saveData()
    }
    
    @IBAction func btnActResetAllData(_ sender: UIButton) {
        simpleDestructiveYesAndNo(self, message: "정말 삭제하시겠습니까?", title: "Reset All Data") { _ in
            self.delegate?.didResetAllData(self)
            self.dismiss(animated: true)
        }
    }
    
    func saveData() {
        localStorage.set(stepperTargetCount.value,forKey: .cfgTargetCount)
        
        connectivityHandler.session.sendMessage(
            ["targetCount": stepperTargetCount.value],
            replyHandler: nil) { error in
            print("Error sending message: \(error)")
        }
    }
    
}
