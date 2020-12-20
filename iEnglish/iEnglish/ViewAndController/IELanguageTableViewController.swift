//
//  IELanguageTableViewController.swift
//  iEnglish
//
//  Created by HTC on 2017/6/11.
//  Copyright © 2017年 iHTCboy. All rights reserved.
//

import UIKit

class IELanguageTableViewController: UITableViewController {

    let language = ["简体中文", "繁体中文"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = HTCLocalized("Language");
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        
        self.tableView.rowHeight = 55
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return language.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "IELanguageTableViewCell")
        if (cell  == nil) {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "IELanguageTableViewCell")
            if #available(iOS 13, *) {
                cell?.backgroundColor = .secondarySystemGroupedBackground
            }
        }
        
        cell?.accessoryType = .none
        switch TCUserDefaults.shared.getIELanguage() {
        case "zh_CN":
            if indexPath.row == 0 {
                cell?.accessoryType = .checkmark
            }
            break
        case "zh_TW":
            if indexPath.row == 1 {
                cell?.accessoryType = .checkmark
            }
            break
        default: break
            
        }
        
        cell?.textLabel?.text = language[indexPath.row]
        // Configure the cell...

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            TCUserDefaults.shared.setIElanguage(value: "zh_CN")
            break
        case 1:
            TCUserDefaults.shared.setIElanguage(value: "zh_TW")
            break
        default:break
            
        }
        
        tableView.reloadData()
    }

}
