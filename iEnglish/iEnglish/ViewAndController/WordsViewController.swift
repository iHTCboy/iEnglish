//
//  RootViewController.swift
//  iEnglish
//
//  Created by HTC on 2017/6/4.
//  Copyright © 2017年 iHTCboy. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox
import SafariServices

class WordsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if title == nil {
            title = kAppName
        }
        
        if words.isEmpty {
            words = db.query(sql: "select * from Words ORDER BY upper(en)")// limit 30
        }
        
        // filert sort
        sortWords()
        
        //print(words)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [ NSForegroundColorAttributeName : UIColor.white ]
        }
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["tableView": tableView]
        let widthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tableView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        NSLayoutConstraint.activate(widthConstraints)
        NSLayoutConstraint.activate(heightConstraints)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = self.searchVC
        } else {
            // Fallback on earlier versions
            self.tableView.tableHeaderView = self.searchVC.searchBar
        }
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
    
    lazy var sortWordDic : [String: Int] = ["A":0 , "B":0, "C":0 , "D":0 , "E":0 , "F":0 , "G":0 , "H":0 , "I":0 , "J":0 , "K":0 , "L":0 , "M":0 , "N":0 , "O":0 , "P":0 , "Q":0 , "R":0 , "S":0 , "T":0 , "U":0 , "V":0 , "W":0 , "X":0 , "Y":0 , "Z":0]
    
    lazy var tableView: UITableView = {
        var tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH), style: .plain)
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
//        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.estimatedRowHeight = 80
        tableView.delegate = self;
        tableView.dataSource = self;
        //设置索引列文本的颜色
        tableView.sectionIndexColor = kColorAppMain
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.sectionIndexTrackingBackgroundColor = KColorAPPRed.withAlphaComponent(0.3)
//        tableView.register(UINib.init(nibName: "ITQuestionListViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ITQuestionListViewCell")
        return tableView
    }()
    
    lazy var resultsVC: TCSearchResultsVC = {
        let resultsVC = TCSearchResultsVC()
        resultsVC.tableView.delegate = self
        resultsVC.tableView.dataSource = self
        return resultsVC
    }()
    
    lazy var searchVC: UISearchController = {
        let searchVC = UISearchController(searchResultsController: self.resultsVC)
        searchVC.searchResultsUpdater = self as UISearchResultsUpdating
        searchVC.searchBar.delegate = self as UISearchBarDelegate
        searchVC.delegate = self as UISearchControllerDelegate
        searchVC.dimsBackgroundDuringPresentation = false //开始搜索时背景不显示
        searchVC.searchBar.placeholder = "Search word"
        //searchBar样式调整
        if #available(iOS 11.0, *) {
            searchVC.searchBar.tintColor = UIColor.white
            searchVC.searchBar.barTintColor = UIColor.white
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSForegroundColorAttributeName: kColorAppMain]
            if let textfield = searchVC.searchBar.value(forKey: "searchField") as? UITextField {
                textfield.tintColor = kColorAppMain
                if let backgroundview = textfield.subviews.first {
                    // Background color
                    backgroundview.backgroundColor = UIColor.white
                    // Rounded corner
                    backgroundview.layer.cornerRadius = 10;
                    backgroundview.clipsToBounds = true;
                }
            }
            
        } else {
            searchVC.searchBar.tintColor = kColorAppMain//设置searchBar按钮字体颜色
        }

        self.definesPresentationContext = true//fix 显示问题
        return searchVC
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
            //print(" play audio completioned")
        }, nil)
        
        AudioServicesPlaySystemSound(soundId)
        //        AudioServicesPlayAlertSound(soundId) //paly and Shake
    }
    
    func sortWords() {
        
        var keyWord = "A"
        var number  = 0
        var indexNumber = 0
        for index in 0...words.count-1 {
            let dictionary = words[index] as [String : Any]
            if let wordString = dictionary["en"] as? String {
                let upperWord = wordString.uppercased()
                let indexString = upperWord.index(upperWord.startIndex, offsetBy: 1)
                let firstWord = upperWord.substring(to: indexString)
                if firstWord != keyWord || index == words.count-1 {
                    print(keyWord)
                    sortWordDic.updateValue(indexNumber, forKey: keyWord)
                    keyWord = firstWord
                    indexNumber += number
                    number = 1
                }else{
                    number += 1
                }
            }
        }
        //print(sortWordDic)
    }
    
    func clickedBtn(btn: UIButton) {
        let dictionary = self.resultsVC.isShowing ? self.resultsVC.results[btn.tag] as [String : Any] : words[btn.tag] as [String : Any]
        let word = dictionary["en"] as? String
        var url = "https://m.youdao.com/dict?q=" + word!
        if UIDevice.current.userInterfaceIdiom == .pad {
           url = "https://dict.youdao.com/w/eng/" + word!
        }
        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        let URLs = URL.init(string: urlEncoding!)!
        if #available(iOS 9.0, *) {
            let sfvc = SFSafariViewController.init(url: URLs)
            sfvc.hidesBottomBarWhenPushed = true
            sfvc.title = word
            if #available(iOS 10.0, *) {
                sfvc.preferredBarTintColor = kColorAppMain
                sfvc.preferredControlTintColor = UIColor.white
            }
            if #available(iOS 11.0, *) {
                sfvc.dismissButtonStyle = .close
                sfvc.navigationItem.largeTitleDisplayMode = .never
            }
            self.navigationController?.pushViewController(sfvc, animated: true)
            
        } else {
            // Fallback on earlier versions
            if UIApplication.shared.canOpenURL(URLs) {
                UIApplication.shared.openURL(URLs)
            }
        }
    }
}


extension WordsViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate
{
    func updateSearchResults(for searchController: UISearchController) {
        // Update the filtered array based on the search text.
        let searchResults = words
        
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString.components(separatedBy: " ") as [String]
        
        // Build all the "AND" expressions for each value in the searchString.
        let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            // Each searchString creates an OR predicate for: name, yearIntroduced, introPrice.
            var searchItemsPredicate = [NSPredicate]()
            
            // Below we use NSExpression represent expressions in our predicates.
            // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value).
            
            // Name field matching.
            let titleExpression = NSExpression(forKeyPath: "en")
            let searchStringExpression = NSExpression(forConstantValue: searchString)
            
            let titleSearchComparisonPredicate = NSComparisonPredicate(leftExpression: titleExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
            
            searchItemsPredicate.append(titleSearchComparisonPredicate)
            
            let zh_CNExpression = NSExpression(forKeyPath: "zh_CN")
            let zh_CNSearchComparisonPredicate = NSComparisonPredicate(leftExpression: zh_CNExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
            searchItemsPredicate.append(zh_CNSearchComparisonPredicate)
            
            let zh_TWExpression = NSExpression(forKeyPath: "zh_TW")
            let zh_TWSearchComparisonPredicate = NSComparisonPredicate(leftExpression: zh_TWExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
            searchItemsPredicate.append(zh_TWSearchComparisonPredicate)
            
//            let numberFormatter = NumberFormatter()
//            numberFormatter.numberStyle = .none
//            numberFormatter.formatterBehavior = .default
//            
//            let targetNumber = numberFormatter.number(from: searchString)
//            
//            // `searchString` may fail to convert to a number.
//            if targetNumber != nil {
//                // Use `targetNumberExpression` in both the following predicates.
//                let targetNumberExpression = NSExpression(forConstantValue: targetNumber!)
//                
//                // `yearIntroduced` field matching.
//                let yearIntroducedExpression = NSExpression(forKeyPath: "yearIntroduced")
//                let yearIntroducedPredicate = NSComparisonPredicate(leftExpression: yearIntroducedExpression, rightExpression: targetNumberExpression, modifier: .direct, type: .equalTo, options: .caseInsensitive)
//            }
            
            // Add this OR predicate to our master AND predicate.
            let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:searchItemsPredicate)
            
            return orMatchPredicate
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
        
        let filteredResults = searchResults.filter { finalCompoundPredicate.evaluate(with: $0) }
        
        // Hand over the filtered results to our search results table.
        let resultsController = searchController.searchResultsController as! TCSearchResultsVC
        resultsController.results = filteredResults
        resultsController.tableView.reloadData()
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        self.resultsVC.isShowing = true
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        self.resultsVC.isShowing = false
    }
}


// MARK: Tableview Delegate
extension WordsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == self.tableView ? self.words.count : self.resultsVC.results.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sortWordDic.keys.sorted(by: <)
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        //点击索引，列表跳转到对应索引的行
        let indexNumber = sortWordDic[title];
        tableView.scrollToRow(at: IndexPath.init(row: indexNumber!, section: 0), at: .top, animated: true)
        return index
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "WordsViewCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "WordsViewCell")
            cell!.selectedBackgroundView = UIView.init(frame: cell!.frame)
            cell!.selectedBackgroundView?.backgroundColor = kColorAppMain.withAlphaComponent(0.7)
        }
        
        let btn = UIButton.init(type: .detailDisclosure)
        btn.tintColor = kColorAppMain
        btn.tag = indexPath.row
        btn.addTarget(self, action: #selector(clickedBtn(btn:)), for: .touchUpInside)
        cell?.accessoryView = btn
        
        let dictionary = tableView == self.tableView ? words[indexPath.row] as [String : Any] : self.resultsVC.results[indexPath.row] as [String : Any]

        cell?.textLabel?.text = dictionary["en"] as? String
        let detial = (dictionary[TCUserDefaults.shared.getIELanguage()] as? String)!
        let detialString = NSMutableAttributedString.init(string: detial)
        let part = NSMutableAttributedString(string: " . ", attributes: [NSForegroundColorAttributeName: UIColor.clear])
        detialString.append(part)
        cell?.detailTextLabel?.attributedText = detialString
        
        return cell!
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dictionary = tableView == self.tableView ? words[indexPath.row] as [String : Any] : self.resultsVC.results[indexPath.row] as [String : Any]
        
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



