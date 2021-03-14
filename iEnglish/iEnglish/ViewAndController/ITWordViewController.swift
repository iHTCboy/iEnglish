//
//  ITWordViewController.swift
//  iEnglish
//
//  Created by HTC on 2021/03/13.
//  Copyright © 2020 iHTCboy. All rights reserved.
//

import UIKit
import AVFoundation

class ITWordViewController: UITableViewController {


    @IBOutlet weak var allowChineseSwitch: UISwitch!
    @IBOutlet weak var allowPluralSwitch: UISwitch!
    
    
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
        allowPluralSwitch.isOn = TCUserDefaults.shared.getIEShowPlural()
        allowChineseSwitch.isOn = TCUserDefaults.shared.getIEShowChinese()
    }
    
    
    @IBAction func clickedChineseSwitch(_ sender: UISwitch) {
        
        TCUserDefaults.shared.setIEShowChinese(value: sender.isOn)
    }
    
    @IBAction func clickedPluralSwitch(_ sender: UISwitch) {
        
        TCUserDefaults.shared.setIEShowPlural(value: sender.isOn)
    }
}
