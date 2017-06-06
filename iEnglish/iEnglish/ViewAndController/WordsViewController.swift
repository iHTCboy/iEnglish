//
//  RootViewController.swift
//  iEnglish
//
//  Created by HTC on 2017/6/4.
//  Copyright © 2017年 iHTCboy. All rights reserved.
//

import UIKit
import AudioToolbox
import SafariServices

class WordsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if title == nil {
            title = kAppName
        }
        
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
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
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
        
        let fileUrl = URL.init(fileURLWithPath: audioPath)
        
        AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundId)
        
        AudioServicesAddSystemSoundCompletion(soundId, nil, nil, {
            (soundID:SystemSoundID, _:UnsafeMutableRawPointer?) in
            print(" play audio completioned")
        }, nil)
        
        AudioServicesPlaySystemSound(soundId)
        //        AudioServicesPlayAlertSound(soundId) //paly and Shake
    }
    
    func clickedBtn(btn: UIButton) {
        let dictionary = words[btn.tag] as [String : Any]
        let word = dictionary["en"] as? String
        let url = "https://m.youdao.com/dict?q=" + word!
        let URLs = URL.init(string: url)!
        if #available(iOS 9.0, *) {
            let sfvc = SFSafariViewController.init(url: URLs)
            sfvc.hidesBottomBarWhenPushed = true
            sfvc.title = word
            self.navigationController?.pushViewController(sfvc, animated: true)
        } else {
            // Fallback on earlier versions
            if UIApplication.shared.canOpenURL(URLs) {
                UIApplication.shared.openURL(URLs)
            }
        }
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
        }
        
        let btn = UIButton.init(type: .detailDisclosure)
        btn.tintColor = kColorAppMain
        btn.tag = indexPath.row
        btn.addTarget(self, action: #selector(clickedBtn(btn:)), for: .touchUpInside)
        cell?.accessoryView = btn
        
        let dictionary = words[indexPath.row] as [String : Any]
        
        cell?.textLabel?.text = dictionary["en"] as? String
        let detial = (dictionary["zh_CN"] as? String)!
        let detialString = NSMutableAttributedString.init(string: detial)
        let part = NSMutableAttributedString(string: " . ", attributes: [NSForegroundColorAttributeName: UIColor.white])
        detialString.append(part)
        cell?.detailTextLabel?.attributedText = detialString
        
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
            //print(path)
            AudioServicesRemoveSystemSoundCompletion(soundId)
            playSoundEffect(audioPath: path)
        } else {
            print("not found")
        }
        
    }
}



