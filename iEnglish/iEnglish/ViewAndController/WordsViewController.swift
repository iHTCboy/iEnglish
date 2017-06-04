//
//  RootViewController.swift
//  iEnglish
//
//  Created by HTC on 2017/6/4.
//  Copyright © 2017年 iHTCboy. All rights reserved.
//

import UIKit
import AudioToolbox

class WordsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = kAppName
        
        if words.isEmpty {
            words = db.query(sql: "select * from Words ORDER BY upper(en)")
        }
        
        print(words)
        
        view.addSubview(tableView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var soundId: SystemSoundID = 0
    // MARK:- 懒加载
    
    //获取数据库实例
    lazy var db: SQLiteDB = {
        let db = SQLiteDB.shared
        db.DB_NAME = "iEnglish.db3"
        //打开数据库
        _ = db.openDB()
        return db
    }()
    
    var words : [[String: Any]] = []
    
    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH), style: .plain)
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 40, right: 0)
//        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.estimatedRowHeight = 80
        tableView.delegate = self;
        tableView.dataSource = self;
//        tableView.register(UINib.init(nibName: "ITQuestionListViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ITQuestionListViewCell")
        return tableView
    }()
    
//    let Words = db.query(sql: "select * from Words")
}


extension WordsViewController
{
    func playSoundEffect(audioPath: String) {
//        let audioFile = Bundle.main.path(forResource: name, ofType: nil)
//        
//        assert(audioFile != nil, "voice path is nil")
        
        let fileUrl = URL.init(fileURLWithPath: audioPath)
        
        AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundId)
        
        AudioServicesAddSystemSoundCompletion(soundId, nil, nil, {
            (soundID:SystemSoundID, _:UnsafeMutableRawPointer?) in
            print(" play audio completioned")
        }, nil)
        
        AudioServicesPlaySystemSound(soundId)
        //        AudioServicesPlayAlertSound(soundId) //paly and Shake
    }
}


// MARK: Tableview Delegate
extension WordsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "WordsViewCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "WordsViewCell")
            cell?.accessoryType = .disclosureIndicator
        }
        
        let dictionary = words[indexPath.row] as [String : Any]
        
        cell?.textLabel?.text = dictionary["en"] as? String
        cell?.detailTextLabel?.text = dictionary["zh_CN"] as? String
        
        /*
 13 elements
 ▿ 0 : 2 elements
 - key : "en_adjective"
 - value : "0"
 ▿ 1 : 2 elements
 - key : "zh_CN"
 - value : "服装"
 ▿ 2 : 2 elements
 - key : "display_priority"
 - value : 100000
 ▿ 3 : 2 elements
 - key : "en_plural"
 - value : "apparel"
 ▿ 4 : 2 elements
 - key : "en_verb"
 - value : "0"
 ▿ 5 : 2 elements
 - key : "en"
 - value : "apparel"
 ▿ 6 : 2 elements
 - key : "en_voice_file"
 - value : "apparel"
 ▿ 7 : 2 elements
 - key : "ko"
 - value : ""
 ▿ 8 : 2 elements
 - key : "en_noun"
 - value : "1"
 ▿ 9 : 2 elements
 - key : "zh_TW"
 - value : "服裝"
 ▿ 10 : 2 elements
 - key : "ja"
 - value : ""
 ▿ 11 : 2 elements
 - key : "word_id"
 - value : 1
 ▿ 12 : 2 elements
 - key : "cat_id"
 - value : 17
 */
        return cell!
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dictionary = words[indexPath.row] as [String : Any]
        let name = dictionary["en"] as? String
        
        if let bundlePath = Bundle.main.path(forResource: "iEnglish", ofType: "bundle"),
            let bundle = Bundle(path: bundlePath),
            let path = bundle.path(forResource: name?.lowercased(), ofType: "aiff") {
            print(path)
            AudioServicesRemoveSystemSoundCompletion(soundId)
            playSoundEffect(audioPath: path)
        } else {
            print("not found")
        }
        
    }
}



