//
//  IHTCTTSViewController.swift
//  iWuBi
//
//  Created by HTC on 2023/1/27.
//  Copyright © 2023 HTC. All rights reserved.
//

import UIKit
import AVFoundation

class IHTCTTSViewController: UIViewController {

    
    lazy var playItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem:  UIBarButtonItem.SystemItem.play, target: self, action: #selector(playPlaylist))
        return item
    }()
    
    lazy var stopItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem:  UIBarButtonItem.SystemItem.stop, target: self, action: #selector(stopPlaylist))
        return item
    }()
    
    lazy var pauseItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem:  UIBarButtonItem.SystemItem.pause, target: self, action: #selector(pausePlaylist))
        return item
    }()
    
    lazy var textView: UITextView = {
        let text = UITextView()
        text.delegate = self
        text.isEditable = true
        text.alwaysBounceVertical = true
        text.font = UIFont.systemFont(ofSize: 20)
        text.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            text.backgroundColor = .secondarySystemGroupedBackground
        }
        return text
    }()
    
    lazy var placeholderLabel : UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "粘贴需要播放的文本内容..."
        placeholderLabel.font = UIFont.systemFont(ofSize: 20)
        placeholderLabel.sizeToFit()
//        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 10)
        if #available(iOS 13.0, *) {
            placeholderLabel.textColor = .tertiaryLabel
        } else {
            placeholderLabel.textColor = .lightGray
        }
        placeholderLabel.isHidden = false
        return placeholderLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "文字转语音(TTS)"
        self.navigationItem.rightBarButtonItem = playItem
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        if #available(iOS 13.0, *) {
            view.backgroundColor = .secondarySystemGroupedBackground
        }
        
        textView.text = "粘贴需要播放的文本内容..."
        view.addSubview(textView)
//        view.addSubview(placeholderLabel)
        let constraintViews = [
            "textView": textView
        ]
        let vFormat = "V:|-0-[textView]-0-|"
        let hFormat = "H:|-5-[textView]-5-|"
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: vFormat, options: [], metrics: [:], views: constraintViews)
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: hFormat, options: [], metrics: [:], views: constraintViews)
        view.addConstraints(vConstraints)
        view.addConstraints(hConstraints)
        view.layoutIfNeeded()
        
        textView.becomeFirstResponder()
    }
    
    deinit {
        IHTCTTSViewController.stopTTS()
    }

}

// 播放列表操作
extension IHTCTTSViewController {
    
    @objc
    func playPlaylist() {
        let words = textView.text ?? ""
        guard !words.isEmpty else {
            return
        }
        IHTCTTSViewController.playTTS(text: words, delegate: self) { [weak self] in
            self?.navigationItem.rightBarButtonItem = self?.playItem
        }
        self.navigationItem.rightBarButtonItem = stopItem
    }
    
    @objc
    func stopPlaylist() {
        if IHTCTTSViewController.pauseTTS() {
            self.navigationItem.rightBarButtonItem = pauseItem
        } else {
            self.navigationItem.rightBarButtonItem = playItem
        }
    }
    
    @objc
    func pausePlaylist() {
        if IHTCTTSViewController.continueTTS() {
            self.navigationItem.rightBarButtonItem = stopItem
        } else {
            self.navigationItem.rightBarButtonItem = playItem
        }
    }
}

// MARK: - UITextViewDelegate
extension IHTCTTSViewController: UITextViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        placeholderLabel.isHidden = !textView.text.isEmpty
//    }
//    func textViewDidEndEditing(_ textView: UITextView) {
//        placeholderLabel.isHidden = !textView.text.isEmpty
//    }
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        placeholderLabel.isHidden = true
//    }
}

// MARK: - TTS
extension IHTCTTSViewController: AVSpeechSynthesizerDelegate {
    
    // 参数
    static var setupSuccess: Bool = false
    static var completion: (() -> Void)?
    // TSS
    static var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    static var utterance:AVSpeechUtterance = AVSpeechUtterance(string: "")
    
    static func playTTS(text: String, delegate: AVSpeechSynthesizerDelegate, completion: (() -> Void)? = nil) {
        
        // 设置声音
        if !self.setupSuccess {
            self.setupSuccess = true
            self.setupVoiceSystem(allowVoice: true)
        }
        
        if synthesizer.isSpeaking {
            utterance.volume = 0
            synthesizer.delegate = nil
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        
        IHTCTTSViewController.completion = completion
        
        synthesizer.delegate = delegate
        utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language:"zh-CN")
//        utterance.volume = 1
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate // 范围：0~1
        synthesizer.speak(utterance)
    }
    
    @discardableResult
    static func pauseTTS() -> Bool {
        return synthesizer.pauseSpeaking(at: AVSpeechBoundary.word)
    }
    
    @discardableResult
    static func continueTTS() -> Bool {
        return synthesizer.continueSpeaking()
    }
    
    static func stopTTS() {
        if synthesizer.isSpeaking {
            utterance.volume = 0
            synthesizer.delegate = nil
            synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
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
    
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // 结束播放
        IHTCTTSViewController.completion?()
    }
}
