//
//  PlaylistViewController.swift
//  iEnglish
//
//  Created by HTC on 2023/1/27.
//  Copyright © 2023 iHTCboy. All rights reserved.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Playlist"
        
        self.navigationItem.rightBarButtonItem = addItem

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white ]
        }
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["tableView": tableView]
        let widthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tableView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        NSLayoutConstraint.activate(widthConstraints)
        NSLayoutConstraint.activate(heightConstraints)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var list : [String: [Int]] = TCUserDefaults.shared.getIEPlaylist()
    
    // MARK:- 懒加载
    
    //获取数据库实例
    lazy var db: SQLiteDB = {
        let db = SQLiteDB.shared
        db.DB_NAME = "iEnglish.db3"
        //打开数据库
        _ = db.openDB()
        return db
    }()
    
    lazy var addItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem:  UIBarButtonItem.SystemItem.add, target: self, action: #selector(addNewPlaylist))
        return item
    }()
    
    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH), style: .grouped)
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 80
        tableView.sectionFooterHeight = 5;
        tableView.sectionHeaderHeight = 5;
        tableView.delegate = self;
        tableView.dataSource = self;
        return tableView
    }()
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc
    func addNewPlaylist() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"// HH:mm:ss"
        let dateString = formatter.string(from: now)
        let title = "学习计划 - \(dateString)"
        showInputAlert("添加单词列表", text: title, plText: "单词计划名称", plText2: "单词数（如：30）默认20个") { text1, text2 in
            let name = text1.isEmpty ? title : text1
            let counts = text2.isEmpty ? 20 : (UInt(text2) ?? 20)
            self.addPlaylist(title: name, counts: counts == 0 ? 20 : counts)
        }
    }
    
    func addPlaylist(title: String, counts: UInt) {
        var dict = TCUserDefaults.shared.getIEPlaylist()
        var sets = Set<Int>()
        for (_, item) in dict {
            item.forEach { sets.insert( $0) }
        }
        
        let randomWords = db.query(sql: "select * from Words ORDER BY RANDOM()")
        var words = [Int]()
        for _ in 1...counts {
            let wid = getUnionWord(sets: sets, randomWords: randomWords)
            if wid > 0 {
                sets.insert(wid)
                words.append(wid)
            }
        }
        // 已经没有新单词了
        guard words.count > 0 else {
            let alert = UIAlertController(title: "提示", message: "没有新单词了~ 全部已添加到学习列表~", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // 存在同名列表
        if dict[title] != nil {
            let alert = UIAlertController(title: "提示", message: "是否覆盖列表，已存在同名列表：\(title)", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "取消", style: .destructive, handler: nil))
            alert.addAction(UIAlertAction.init(title: "覆盖", style: .default, handler: { action in
                dict[title] = words
                TCUserDefaults.shared.setIEPlaylist(value: dict)
                self.list = dict
                self.tableView.reloadData()
            }))
            present(alert, animated: true, completion: nil)
            return
        }
        
        dict[title] = words
        TCUserDefaults.shared.setIEPlaylist(value: dict)
        list = dict
        tableView.reloadData()
    }
    
    func getUnionWord(sets: Set<Int>, randomWords: [[String: Any]]) -> Int {
        var wordId = 0
        for word in randomWords {
            let wid = word["word_id"] as? Int ?? 0
            if !sets.contains(wid) {
                wordId = wid
                break
            }
        }
        return wordId
    }
    
    func showInputAlert(_ title: String, text: String = "", plText: String = "", text2: String = "", plText2: String = "", complete: ((String, String)->Void)?) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = plText
            textfield.text = text
        }
        alert.addTextField { textfield in
            textfield.placeholder = plText2
            textfield.text = text2
        }
        alert.addAction(UIAlertAction.init(title: "取消", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { action in
            complete?(alert.textFields![0].text!, alert.textFields![1].text!)
        }))
        present(alert, animated: true, completion: nil)
    }
}


// MARK: Tableview Delegate
extension PlaylistViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistViewCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "PlaylistViewCell")
            cell?.accessoryType = .disclosureIndicator
            cell!.selectedBackgroundView = UIView.init(frame: cell!.frame)
            cell!.selectedBackgroundView?.backgroundColor = kColorAppMain.withAlphaComponent(0.7)
            #if targetEnvironment(macCatalyst)
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 20)
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
            #endif
        }
        
        let keys = list.keys.sorted()
        let keyName = keys[indexPath.section]
        let wordIds = (list[keyName] ?? []) as [Int]
        cell?.textLabel?.text = keyName
        cell?.detailTextLabel?.text = "\(wordIds.count)"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let keys = list.keys.sorted()
        let keyName = keys[indexPath.section]
        let wordIds = (list[keyName] ?? []) as [Int]
        //words = db.query(sql: "select * from Words where word_id IN (0,1,20,3)")
        let sql = "select * from Words  where word_id IN (\(wordIds.map({"\($0)"}).joined(separator: ",")))"
        let words = db.query(sql: sql)

        let wordsVc = WordsViewController()
        wordsVc.title = keyName
        wordsVc.words = words
        wordsVc.hidesBottomBarWhenPushed = true
        if #available(iOS 11.0, *) {
            wordsVc.navigationItem.largeTitleDisplayMode = .never
        }

        self.navigationController?.pushViewController(wordsVc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let keys = list.keys.sorted()
            let keyName = keys[indexPath.section]
            let alert = UIAlertController(title: "提示", message: "确认删除列表：\(keyName)", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "取消", style: .destructive, handler: nil))
            alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { action in
                self.list[keyName] = nil
                TCUserDefaults.shared.setIEPlaylist(value: self.list)
                tableView.reloadData()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        
    }
}
