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
    
    func getIEShowPlural() -> Bool {
        if let bool = getTCValue(key: "IEShowPlural") as? Bool {
            return bool
        }
        return false
    }
    
    func setIEShowPlural(value: Bool) {
        setTCValue(value: value, forKey: "IEShowPlural")
    }
    
    
    func getIEShowChinese() -> Bool {
        if let bool = getTCValue(key: "IEShowChinese") as? Bool {
            return bool
        }
        return true
    }
    
    func setIEShowChinese(value: Bool) {
        setTCValue(value: value, forKey: "IEShowChinese")
    }
    
}

// MARK: 声音设置
extension TCUserDefaults
{
    
    /// 是否允许静音模式播放音频
    func getIEAllowVoice() -> Bool {
        if let bool = getTCValue(key: "IEAllowVoice") as? Bool {
            return bool
        }
        return true
    }
    
    func setIEAllowVoice(value: Bool) {
        setTCValue(value: value, forKey: "IEAllowVoice")
    }
    
    /// 是否允许朗读中文词义
    func getIEAllowChinesVoice() -> Bool {
        if let bool = getTCValue(key: "IEAllowChinesVoice") as? Bool {
            return bool
        }
        return true
    }
    
    func setIEAllowChinesVoice(value: Bool) {
        setTCValue(value: value, forKey: "IEAllowChinesVoice")
    }
    
    /// 音量大小
    func getIEVolume() -> Float {
        if let float = getTCValue(key: "IEVolume") as? Float {
            return float
        }
        return 1.0
    }
    func setIEVolume(value: Float) {
        setTCValue(value: value, forKey: "IEVolume")
    }
    
    
    /// 播放速度（0~2）
    func getIESpeed() -> Float {
        if let float = getTCValue(key: "IESpeed") as? Float {
            return float
        }
        return 1.0
    }
    func setIESpeed(value: Float) {
        setTCValue(value: value, forKey: "IESpeed")
    }
    
    
    /// 循环播放次数
    ///  0~x 次，-1：无限次
    func getIELoops() -> Int {
        if let int = getTCValue(key: "IELoops") as? Int {
            return int
        }
        return 0
    }
    
    func setIELoops(value: Int) {
        setTCValue(value: value, forKey: "IELoops")
    }
    
    /// 循环播放下一次前的时间间隔
    func getIELoopsInterval() -> Float {
        if let float = getTCValue(key: "IELoopsInterval") as? Float {
            return float
        }
        return 0.5
    }
    
    func setIELoopsInterval(value: Float) {
        setTCValue(value: value, forKey: "IELoopsInterval")
    }
    
    /// 播放速度（0~1）
    /// 0.5是正常速度，0是最慢速度，1是最快速度
    func getIESpeedChines() -> Float {
        if let float = getTCValue(key: "IESpeedChines") as? Float {
            return float
        }
        return 0.5
    }
    
    func setIESpeedChines(value: Float) {
        setTCValue(value: value, forKey: "IESpeedChines")
    }
    
    /// 循环播放中文词义前时间隔多长时间播放下一次
    func getIELoopsChinesInterval() -> Float {
        if let float = getTCValue(key: "IELoopsChinesInterval") as? Float {
            return float
        }
        return 0.0
    }
    
    func setIELoopsChinesInterval(value: Float) {
        setTCValue(value: value, forKey: "IELoopsChinesInterval")
    }
}
