//
//  ITVoiceViewController.swift
//  iEnglish
//
//  Created by HTC on 2020/12/19.
//  Copyright © 2020 iHTCboy. All rights reserved.
//

import UIKit
import AVFoundation

class ITVoiceViewController: UITableViewController {

    
    @IBOutlet weak var allowVoiceSwitch: UISwitch!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var loopsLabel: UILabel!
    @IBOutlet weak var loopsSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupData()
    }
    
    func setupUI() {
        title = HTCLocalized("Volume Setting")

        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        
        self.tableView.allowsSelection = false
    }
    
    
    func setupData() {
        allowVoiceSwitch.isOn = TCUserDefaults.shared.getIEAllowVoice()
        volumeSlider.value = TCUserDefaults.shared.getIEVolume()
        volumeLabel.text = String(TCUserDefaults.shared.getIEVolume())
        speedSlider.value = TCUserDefaults.shared.getIESpeed()
        speedLabel.text =  String(TCUserDefaults.shared.getIESpeed())
        loopsSlider.value = Float(TCUserDefaults.shared.getIELoops())
        let loops = Int(TCUserDefaults.shared.getIELoops())
        loopsSlider.value = Float(loops)
        loopsLabel.text = (loops == -1) ? "无限" : String(loops)
    }
    
    
    @IBAction func clickedVoiceSwitch(_ sender: UISwitch) {
        
        TCUserDefaults.shared.setIEAllowVoice(value: sender.isOn)
        
        if sender.isOn {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(AVAudioSession.Category.playback)
            try? audioSession.setActive(true, options: AVAudioSession.SetActiveOptions(rawValue: 0))
        } else {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(AVAudioSession.Category.ambient)
            try? audioSession.setActive(true, options: AVAudioSession.SetActiveOptions(rawValue: 0))
        }
        
    }
    
    @IBAction func clickedVolumeSlider(_ sender: UISlider) {
        let str = String(format: "%.1f", sender.value)
        let volume = Float(str)!
        volumeLabel.text = String(volume)
        
        TCUserDefaults.shared.setIEVolume(value: volume)
    }
    
    @IBAction func clickedSpeedSlider(_ sender: UISlider) {
        let str = String(format: "%.1f", sender.value)
        let speed = Float(str)!
        speedLabel.text = String(speed)
        
        TCUserDefaults.shared.setIESpeed(value: speed)
    }
    
    @IBAction func clickedLoopsSlider(_ sender: UISlider) {
        let loops = Int(sender.value)
        loopsLabel.text = (loops == -1) ? "无限" : String(loops)
        
        TCUserDefaults.shared.setIELoops(value: loops)
        
    }
    
    
}
