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
import AVFoundation
import SafariServices

class WordsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置默认主题
        let IHTCUD = IHTCUserDefaults.shared
        IHTCUD.setDefaultAppAppearance(style: IHTCUD.getAppAppearance())
        
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
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white ]
        }
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["tableView": tableView]
        let widthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tableView]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        NSLayoutConstraint.activate(widthConstraints)
        NSLayoutConstraint.activate(heightConstraints)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = self.searchVC
        } else {
            // Fallback on earlier versions
            self.tableView.tableHeaderView = self.searchVC.searchBar
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
        self.player?.stop()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.player?.stop()
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
        #if !targetEnvironment(macCatalyst)
        searchVC.dimsBackgroundDuringPresentation = false //开始搜索时背景不显示
        #endif
        searchVC.searchBar.placeholder = "Search word"
        //searchBar样式调整
        if #available(iOS 11.0, *) {
            searchVC.searchBar.tintColor = UIColor.white
            searchVC.searchBar.barTintColor = UIColor.white
            if #available(iOS 13, *) {
                searchVC.searchBar.searchTextField.textColor = .white
                searchVC.searchBar.searchTextField.tintColor = .white
                UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            } else {
                UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: kColorAppMain]
            }
            if let textfield = searchVC.searchBar.value(forKey: "searchField") as? UITextField {
                if #available(iOS 13, *) {
                    textfield.tintColor = .white
                } else {
                    textfield.tintColor = kColorAppMain
                }
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
    var player: AVAudioPlayer?
    var languageLocalCode: String = TCUserDefaults.shared.getIELanguage()
    var isShowPlural: Bool = false
    var isShowChinese: Bool = false
}


extension WordsViewController
{
    func refreshData() {
        languageLocalCode = TCUserDefaults.shared.getIELanguage()
        isShowPlural = TCUserDefaults.shared.getIEShowPlural()
        isShowChinese = TCUserDefaults.shared.getIEShowChinese()
        self.tableView.reloadData()
    }
    
    func playSoundEffect(audioPath: String, ttsWords:String) {
        // only one
        DispatchQueue.once {
            TCVoiceUtils.setupVoiceSystem(allowVoice: TCUserDefaults.shared.getIEAllowVoice())
        }
        
        TCVoiceUtils.playSound(audioPath: audioPath, ttsWords: ttsWords)
    }
    
    func getAttributedText(word: String, plural: String) -> NSAttributedString {
        var secondaryLabel = UIColor.darkGray
        if #available(iOS 13.0, *) {
            secondaryLabel = UIColor.secondaryLabel
        }
        let text = "\(word) [\(plural)]"
        let newStr = NSMutableAttributedString(string: text)
        if let range = text.range(of: "[", options: .backwards ) {
            let nsRange = NSRange(range, in: text)
            newStr.addAttribute(NSAttributedString.Key.foregroundColor, value: secondaryLabel, range: nsRange)
        }
        if let range = text.range(of: "]", options: .backwards ) {
            let nsRange = NSRange(range, in: text)
            newStr.addAttribute(NSAttributedString.Key.foregroundColor, value: secondaryLabel, range: nsRange)
        }
        if let range = text.range(of: plural, options: .backwards ) {
            let nsRange = NSRange(range, in: text)
            newStr.addAttribute(NSAttributedString.Key.foregroundColor, value: kColorAppMain, range: nsRange)
        }
        
        let maxString = get_max_word(word: word, plural: plural)
        if let range = text.range(of: maxString, options: .backwards ) {
            let nsRange = NSRange(range, in: text)
            newStr.addAttribute(NSAttributedString.Key.foregroundColor, value: secondaryLabel, range: nsRange)
        }
        
        return newStr
    }
    
    func get_max_word(word: String, plural: String) -> String {
        let minCount = min(word.count, plural.count)
        var list: [String] = []
        for i in 0..<minCount {
            let a = word[i]
            let b = plural[i]
            if a == b {
                list.append(String(a))
            } else {
                break
            }
        }
        return list.joined(separator:"")
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
                let firstWord = upperWord.prefix(upTo: indexString)
                if firstWord != keyWord || index == words.count-1 {
                    //print(keyWord)
                    sortWordDic.updateValue(indexNumber, forKey: keyWord)
                    keyWord = String(firstWord)
                    indexNumber += number
                    number = 1
                }else{
                    number += 1
                }
            }
        }
        //print(sortWordDic)
    }
    
    @objc func clickedBtn(btn: UIButton) {
        let dictionary = self.resultsVC.isShowing ? self.resultsVC.results[btn.tag] as [String : Any] : words[btn.tag] as [String : Any]
        let word = dictionary["en"] as? String
        var url = "https://dict.youdao.com/w/eng/" + word!
        if UIDevice.current.userInterfaceIdiom == .phone {
           url = "https://m.youdao.com/dict?q=" + word!
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
            view.window!.rootViewController!.present(sfvc, animated: true)
            
        } else {
            // Fallback on earlier versions
            if UIApplication.shared.canOpenURL(URLs) {
                UIApplication.shared.openURL(URLs)
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension DispatchQueue {
    private static var _onceTracker = [String]()
    public class func once(file: String = #file, function: String = #function, line: Int = #line, block:()->Void) {
        let token = file + ":" + function + ":" + String(line)
        once(token: token, block: block)
    }
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
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
    
    func sectionIndexTitles(for tbView: UITableView) -> [String]? {
        if tbView != tableView {
            return []
        }
        return sortWordDic.keys.sorted(by: <)
    }
    
    func tableView(_ tbView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        if tbView != tableView {
            return 0
        }
        
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
            if #available(iOS 13, *) {
                cell?.backgroundColor = .secondarySystemGroupedBackground
            }
            #if targetEnvironment(macCatalyst)
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 20)
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
            #endif
        }
        
        let btn = UIButton.init(type: .detailDisclosure)
        btn.tintColor = kColorAppMain
        btn.tag = indexPath.row
        btn.addTarget(self, action: #selector(clickedBtn(btn:)), for: .touchUpInside)
        cell?.accessoryView = btn
        
        let dictionary = tableView == self.tableView ? words[indexPath.row] as [String : Any] : self.resultsVC.results[indexPath.row] as [String : Any]

        let word  = dictionary["en"] as! String
        let plural = dictionary["en_plural"] as! String
        if word == plural || plural.isEmpty || !isShowPlural {
            cell?.textLabel?.text = word
        } else {
            cell?.textLabel?.attributedText = getAttributedText(word: word, plural: plural)
        }
        
        if isShowChinese {
            let detial = (dictionary[languageLocalCode] as? String)!
            let detialString = NSMutableAttributedString.init(string: detial)
            let part = NSMutableAttributedString(string: " . ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.clear])
            detialString.append(part)
            cell?.detailTextLabel?.attributedText = detialString
        } else {
            cell?.detailTextLabel?.text = ""
        }
        
        return cell!
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dictionary = tableView == self.tableView ? words[indexPath.row] as [String : Any] : self.resultsVC.results[indexPath.row] as [String : Any]
        
        var name = dictionary["en"] as? String
        
        if let name_str = name, name_str.contains("("){
            name = name_str.replacingOccurrences(of: "\\s\\(\\w+\\)", with: "", options: .regularExpression)
        }
        
        if let bundlePath = Bundle.main.path(forResource: "iEnglish", ofType: "bundle"),
            let bundle = Bundle(path: bundlePath),
            let path = bundle.path(forResource: name?.lowercased(), ofType: "aiff") {
            //print(path)
//            AudioServicesRemoveSystemSoundCompletion(soundId)
            let word = (dictionary[languageLocalCode] as? String) ?? ""
            playSoundEffect(audioPath: path, ttsWords: word)
        } else {
            print("not found")
        }
    }
}



