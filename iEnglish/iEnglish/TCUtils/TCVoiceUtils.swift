//
//  TCVoiceUtils.swift
//  iEnglish
//
//  Created by HTC on 2023/1/26.
//  Copyright © 2023 iHTCboy. All rights reserved.
//

import Foundation
import AVFoundation

class TCVoiceUtils: NSObject {

    static let shared = TCVoiceUtils()
    // 参数
    static var audioPath: String = ""
    static var numberOfLoops: Int = 0
    static var completion: (() -> Void)?
    
    // static var soundId: SystemSoundID = 0
    static var player: AVAudioPlayer?
    
    // TTS
    static var ttsWords = ""
    static var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    static var utterance:AVSpeechUtterance = AVSpeechUtterance(string: "")
    
    static func playSound(audioPath: String, ttsWords: String, numberOfLoops: Int = 0, completion: (() -> Void)? = nil) {
        
        if let player = player, player.isPlaying {
            player.delegate = nil
            player.volume = 0
            player.pause()
        }
        
        if synthesizer.isSpeaking {
            utterance.volume = 0
            synthesizer.delegate = nil
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        
        TCVoiceUtils.audioPath = audioPath
        TCVoiceUtils.ttsWords = ttsWords
        TCVoiceUtils.completion = completion
        TCVoiceUtils.numberOfLoops = numberOfLoops
        
        let fileUrl = URL.init(fileURLWithPath: audioPath)
        
        //初始化播放器对象
        let audioPlay = try! AVAudioPlayer.init(contentsOf: fileUrl)
        player = audioPlay
        player?.delegate = TCVoiceUtils.shared
        //设置声音的大小
        audioPlay.volume = TCUserDefaults.shared.getIEVolume() //范围为（0到1）；
        //设置循环次数，如果为负数，就是无限循环，0表示不循环只播放一次
//        audioPlay.numberOfLoops = TCUserDefaults.shared.getIELoops()
        //允许用户在不改变音调的情况下调整播放率，范围从0.5（半速）到2.0（2倍速）
        let speed = TCUserDefaults.shared.getIESpeed()
        audioPlay.rate = speed
        if speed != 1.0 {
            audioPlay.enableRate = true
        }
        //设置播放进度
        audioPlay.currentTime = 0
        //准备播放,调用此方法将预加载缓冲区并获取音频硬件，这样做可以将调用play方法和听到输出声音之间的延时降低到最小
        audioPlay.prepareToPlay()
        audioPlay.play()
    }
    
    static func playSound(audioPath: String, soundId: inout SystemSoundID) {
        let fileUrl = URL.init(fileURLWithPath: audioPath)
        
        AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundId)

        AudioServicesAddSystemSoundCompletion(soundId, nil, nil, {
            (soundID:SystemSoundID, _:UnsafeMutableRawPointer?) in
            //print(" play audio completioned")
        }, nil)

        AudioServicesPlaySystemSound(soundId)
        //        AudioServicesPlayAlertSound(soundId) //paly and Shake
    }
    
    //设置声音模式（是否设备静音也播放）
    /// - Parameter allowVoice: 是否设备静音也播放
    static func setupVoiceSystem(allowVoice: Bool) {
        if allowVoice {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(AVAudioSession.Category.playback)
            try? audioSession.setActive(true, options: AVAudioSession.SetActiveOptions(rawValue: 0))
        } else {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(AVAudioSession.Category.ambient)
            try? audioSession.setActive(true, options: AVAudioSession.SetActiveOptions(rawValue: 0))
        }
    }
    
    static func tts(text: String) {
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        
        synthesizer.delegate = TCVoiceUtils.shared
        utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language:"zh-CN")
        utterance.volume = TCUserDefaults.shared.getIEVolume()
        utterance.rate = TCUserDefaults.shared.getIESpeedChines() // 范围：0~1
        synthesizer.speak(utterance)
    }
    
    static func stopSound() {
        if let player = player, player.isPlaying {
            player.delegate = nil
            player.volume = 0
            player.pause()
        }
        
        if synthesizer.isSpeaking {
            utterance.volume = 0
            synthesizer.delegate = nil
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    fileprivate func audioPlayerNext(_ player: AVAudioPlayer, _ loops: Int) {
        TCVoiceUtils.numberOfLoops += 1
        // 播放中文
        let allowChinesVoice = TCUserDefaults.shared.getIEAllowChinesVoice()
        if allowChinesVoice && !TCVoiceUtils.ttsWords.isEmpty {
            let interval = TCUserDefaults.shared.getIELoopsChinesInterval()
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(interval)) {
                TCVoiceUtils.tts(text: TCVoiceUtils.ttsWords)
            }
        } else {
            // 符合条件才循环
            if loops >= TCVoiceUtils.numberOfLoops || loops == -1 {
                let interval = TCUserDefaults.shared.getIELoopsInterval()
                // 重复播放，跳到最新的时间点开始播放
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(interval)) {
                    player.play()
                }
            }
        }
    }
    
}

extension TCVoiceUtils: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        let loops = TCUserDefaults.shared.getIELoops()
        let numberOfLoops = TCVoiceUtils.numberOfLoops
        // 第一次播放完，且不重复播放
        if loops == 0 && numberOfLoops == 0 {
            TCVoiceUtils.numberOfLoops = 1
            let allowChinesVoice = TCUserDefaults.shared.getIEAllowChinesVoice()
            // 播放中文
            if allowChinesVoice && !TCVoiceUtils.ttsWords.isEmpty {
                let interval = TCUserDefaults.shared.getIELoopsChinesInterval()
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(interval)) {
                    TCVoiceUtils.tts(text: TCVoiceUtils.ttsWords)
                }
            } else {
                // 结束播放
                TCVoiceUtils.completion?()
            }
            return
        }
        
        // 无限次数播放
        if loops == -1 {
            audioPlayerNext(player, loops)
            return
        }
        
        // 有限次数播放
        guard loops >= TCVoiceUtils.numberOfLoops else {
            // 达到次数，结束播放
            TCVoiceUtils.completion?()
            return
        }
        
        audioPlayerNext(player, loops)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("audioPlayerDecodeError: \(String(describing: error))")
    }
}

extension TCVoiceUtils: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let loops = TCUserDefaults.shared.getIELoops()
        if (loops != 0 && loops >= TCVoiceUtils.numberOfLoops) || loops == -1 {
            let interval = TCUserDefaults.shared.getIELoopsInterval()
            // 重复播放，跳到最新的时间点开始播放
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(interval)) {
                TCVoiceUtils.playSound(audioPath: TCVoiceUtils.audioPath,
                                       ttsWords: TCVoiceUtils.ttsWords,
                                       numberOfLoops: TCVoiceUtils.numberOfLoops,
                                       completion: TCVoiceUtils.completion)
            }
        } else {
            // 结束播放
            TCVoiceUtils.completion?()
        }
    }
}
