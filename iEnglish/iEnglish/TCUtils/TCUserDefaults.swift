//
//  TCUserDefaults.swift
//  iEnglish
//
//  Created by HTC on 2017/6/11.
//  Copyright © 2017年 iHTCboy. All rights reserved.
//

import UIKit

class TCUserDefaults: NSObject {

    static let shared = TCUserDefaults()
    let df = UserDefaults.standard
    
}


extension TCUserDefaults
{
    func setTCValue(value: Any?, forKey key: String){
        df.set(value, forKey: key)
        df.synchronize()
    }
    
    func getTCValue(key: String) -> Any? {
        return df.value(forKey: key)
    }
}

// MARK: 语言设置
extension TCUserDefaults
{
    func getIELanguage() -> String {
        if let language = getTCValue(key: "IELanguageKey") as? String {
            return language
        }
        return  "zh_CN"
    }
    
    func setIElanguage(value: String) {
        setTCValue(value: value, forKey: "IELanguageKey")
    }
}

// MARK: 声音设置
extension TCUserDefaults
{
    func getIEAllowVoice() -> Bool {
        if let bool = getTCValue(key: "IEAllowVoice") as? Bool {
            return bool
        }
        return true
    }
    
    func setIEAllowVoice(value: Bool) {
        setTCValue(value: value, forKey: "IEAllowVoice")
    }
    
    func getIEVolume() -> Float {
        if let float = getTCValue(key: "IEVolume") as? Float {
            return float
        }
        return 1.0
    }
    func setIEVolume(value: Float) {
        setTCValue(value: value, forKey: "IEVolume")
    }
    
    func getIESpeed() -> Float {
        if let float = getTCValue(key: "IESpeed") as? Float {
            return float
        }
        return 1.0
    }
    func setIESpeed(value: Float) {
        setTCValue(value: value, forKey: "IESpeed")
    }
    

    func getIELoops() -> Int {
        if let int = getTCValue(key: "IELoops") as? Int {
            if int == 0 {
                return -1 //无限次
            }
            return int
        }
        return 1
    }
    func setIELoops(value: Int) {
        setTCValue(value: value, forKey: "IELoops")
    }
}
