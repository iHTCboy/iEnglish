//
//  CategoryViewController.swift
//  iEnglish
//
//  Created by HTC on 2017/6/4.
//  Copyright © 2017年 iHTCboy. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Category"
        
        category = db.query(sql: "select * from Category")
        
//        print(category)
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
    
    // MARK:- 懒加载
    
    //获取数据库实例
    lazy var db: SQLiteDB = {
        let db = SQLiteDB.shared
        db.DB_NAME = "iEnglish.db3"
        //打开数据库
        _ = db.openDB()
        return db
    }()
    
    var category : [[String: Any]] = [["":""]]
    
    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH), style: .grouped)
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 80
        tableView.sectionFooterHeight = 5;
        tableView.sectionHeaderHeight = 5;
        tableView.delegate = self;
        tableView.dataSource = self;
        //        tableView.register(UINib.init(nibName: "ITQuestionListViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ITQuestionListViewCell")
        return tableView
    }()
    
    //    let Words = db.query(sql: "select * from Words")
}


// MARK: Tableview Delegate
extension CategoryViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.category.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "CategoryViewCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "CategoryViewCell")
            cell?.accessoryType = .disclosureIndicator
            cell!.selectedBackgroundView = UIView.init(frame: cell!.frame)
            cell!.selectedBackgroundView?.backgroundColor = kColorAppMain.withAlphaComponent(0.7)
        }
        
        let dictionary = category[indexPath.section] as [String : Any]
        
        cell?.textLabel?.text = dictionary["en"] as? String
        cell?.detailTextLabel?.text = dictionary[TCUserDefaults.shared.getIELanguage()] as? String
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dictionary = category[indexPath.section] as [String : Any]
        let sql = "select * from Words where cat_id =" + "'\(String(dictionary["cat_id"] as! Int))'"
        let words = db.query(sql: sql)
        
        let wordsVc = WordsViewController()
        wordsVc.title = dictionary["en"] as? String
        wordsVc.words = words
        wordsVc.hidesBottomBarWhenPushed = true
        if #available(iOS 11.0, *) {
            wordsVc.navigationItem.largeTitleDisplayMode = .never
        }
        
        self.navigationController?.pushViewController(wordsVc, animated: true)
        
    }
}
