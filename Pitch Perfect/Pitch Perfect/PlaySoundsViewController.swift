//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by William Salivar on 3/4/15.
//  Copyright (c) 2015 William Salivar. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    enum playMode: Int
    {
        case playingNone = 0,
        playingSlow = 1,
        playingFast = 2,
        playingHigh = 3,
        playingLow = 4
    }
    
    var echoEnabled: Bool = false;
    var reverbEnabled: Bool = false;
    
    var player:AVAudioPlayer!
    var receivedAudio:RecordedAudio!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    var currentPlayMode: playMode = playMode.playingNone
    
    // All control labels
    @IBOutlet weak var slowLabel: UILabel!
    @IBOutlet weak var fastLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var reverbLabel: UILabel!
    @IBOutlet weak var echoLabel: UILabel!
    
    // Other sliders and switches
    @IBOutlet weak var slowSlider: UISlider!
    @IBOutlet weak var fastSlider: UISlider!
    @IBOutlet weak var highFreqSlider: UISlider!
    @IBOutlet weak var lowFreqSlider: UISlider!
    
    @IBOutlet weak var echoSwitch: UISwitch!
    @IBOutlet weak var reverbSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the player with the path to recorded audio and allow changes 
        // to the playback rate
        player = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        player.enableRate = true

        // Instantiate audio engine
        audioEngine = AVAudioEngine()
        
        // Setup our audioFile to point to the same path to recorded audio.  
        // This is for the audioEngine
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        
        // Initialize the labels
        slowLabel.text = NSString(format: "%.1f", slowSlider.value)
        fastLabel.text = NSString(format: "%.1f", fastSlider.value)
        highLabel.text = NSString(format: "%.1f", highFreqSlider.value)
        lowLabel.text = NSString(format: "%.1f", lowFreqSlider.value)

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // Handlers for all the UI events
    //
    
    @IBAction func slowButton(sender: UIButton) 
    {
        audioEngine.stop()
        audioEngine.reset()
        
        let rate: Float = slowSlider.value
        playAudioWithVariableRate(rate, mode: playMode.playingSlow)
    }

    @IBAction func fastButton(sender: UIButton)
    {
        audioEngine.stop()
        audioEngine.reset()
        
        let rate: Float = fastSlider.value;
        
        playAudioWithVariableRate(rate, mode: playMode.playingFast)
    }
    
    @IBAction func stopButton(sender: UIButton)
    {
        player.rate = 1.0;
        player.stop();
        audioEngine.stop()
        audioEngine.reset()
        currentPlayMode = playMode.playingNone
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton)
    {
        var pitch: Float = highFreqSlider.value
        playAudioWithVariablePitch(pitch, mode: playMode.playingFast)
    }
    
    @IBAction func playDarthvaderAudio(sender: UIButton)
    {
        let pitch: Float = lowFreqSlider.value
        playAudioWithVariablePitch(pitch, mode: playMode.playingLow)
    }
    

    @IBAction func slowSlider(sender: UISlider) {
        var rate: Float = sender.value
        slowLabel.text = NSString(format: "%.1f", rate)
        playAudioWithVariableRate(rate, mode: playMode.playingSlow)
    }
    
    @IBAction func fastSlider(sender: UISlider) {
        var rate: Float = sender.value
        fastLabel.text = NSString(format: "%.1f", rate)
        playAudioWithVariableRate(rate, mode: playMode.playingFast)
    }
    
    @IBAction func highFreqSlider(sender: UISlider)
    {
        var pitch: Float = sender.value
        highLabel.text = NSString(format: "%.1f", pitch)
        playAudioWithVariablePitch(pitch, mode: playMode.playingHigh)
        
    }
    
    @IBAction func lowFreqSlider(sender: UISlider)
    {
        var pitch: Float = sender.value
        lowLabel.text = NSString(format: "%.1f", pitch)
        playAudioWithVariablePitch(pitch, mode: playMode.playingLow)
    }
    
    @IBAction func toggleEcho(sender: UISwitch)
    {
        echoEnabled = sender.on
        
        if (echoEnabled)
        {
            echoLabel.text = "Echo On"
        }
        else
        {
            echoLabel.text = "Echo Off"
        }
    }
    
    @IBAction func toggleReverb(sender: UISwitch)
    {
        reverbEnabled = sender.on
        
        if (reverbEnabled)
        {
            reverbLabel.text = "Reverb On"
        }
        else
        {
            reverbLabel.text = "Reverb Off"
        }
    }
    
    //
    // Playback logic
    //
    
    // Uses standard audio player with playback rate passed in
    func playAudioWithVariableRate(rate: Float, mode: playMode)
    {
        if (currentPlayMode != mode)
        {
            player.stop()
            player.currentTime = 0.0;
            currentPlayMode = mode
        }
        
        player.rate = rate
        player.play()
    }
    
    // More extensive playback with AVAudioEngine allows various
    // filters to be applied to the audio source
    func playAudioWithVariablePitch(pitch: Float, mode: playMode)
    {
        player.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        currentPlayMode = mode
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        var echoEffect = AVAudioUnitDelay();
        if (echoEnabled)
        {
            echoEffect.delayTime = 1
            echoEffect.wetDryMix = 1
        }
        else
        {
            echoEffect.delayTime = 0
            echoEffect.wetDryMix = 0
            echoEffect.reset()
        }
        audioEngine.attachNode(echoEffect)
        
        var reverbEffect = AVAudioUnitReverb()
        if (reverbEnabled)
        {
            reverbEffect.loadFactoryPreset(AVAudioUnitReverbPreset.LargeHall2)
            reverbEffect.wetDryMix = 30
        }
        else
        {
            reverbEffect.loadFactoryPreset(AVAudioUnitReverbPreset.SmallRoom)
            reverbEffect.wetDryMix = 0
        }
        audioEngine.attachNode(reverbEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: echoEffect, format: nil)
        audioEngine.connect(echoEffect, to: reverbEffect, format: nil)
        audioEngine.connect(reverbEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: playbackStopHandler)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
        
    }
    
    // Callback to reset the current mode when audio is done playing
    func playbackStopHandler()
    {
        currentPlayMode = playMode.playingNone
    }
}
