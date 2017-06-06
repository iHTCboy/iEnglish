//
//  ITAboutAppVC.swift
//  iTalker
//
//  Created by HTC on 2017/4/23.
//  Copyright © 2017年 ihtc.cc @iHTCboy. All rights reserved.
//

import UIKit

class ITAboutAppVC: UIViewController {

    @IBOutlet weak var logoImgView: UIImageView!
    
    @IBOutlet weak var appNameLbl: UILabel!
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var copylightLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

extension ITAboutAppVC
{
    func setupUI() {
        self.title = "关于\(kAppName)"
        
        guard (self.logoImgView != nil) else {
            return
        }
        
        self.logoImgView.image = #imageLiteral(resourceName: "iEnglish")
        self.logoImgView.layer.cornerRadius = 8
        self.logoImgView.layer.masksToBounds = true
        self.appNameLbl.text = kAppName
        self.versionLbl.text = "v" + KAppVersion
        self.contentLbl.text = "\(kAppName) 为一款IT工程师们提供知识充电的应用，IT知识学习、面试必备的工具，不断努力打造更多更好方式呈现更有趣的知识，让大家在零碎时间也可以快速和简单的学习get! \n \n 1、10000+题目库，满足你的求知欲！\n2、IT企业面试题目，为你完名企的梦！\n3、IT知识内容，为你准备好的面试！"
        self.copylightLbl.text = "Copyright © 2017 " + "iHTCboy"
    }
}


