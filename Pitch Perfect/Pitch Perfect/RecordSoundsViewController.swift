//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by William Salivar on 3/4/15.
//  Copyright (c) 2015 William Salivar. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate
{
    
    @IBOutlet weak var recordText: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseRecordText: UILabel!
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    var isRecording: Bool = false;
    var paused: Bool = false;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        pauseRecordText.text = "Click to Record"

    }
    
    override func viewWillAppear(animated: Bool)
    {
        recordText.hidden = true
        stopButton.hidden = true
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

   @IBAction func recordAudio(sender: UIButton)
   {
        // We're not recording. Initialize and start recording
        if (!isRecording)
        {
            isRecording = true
            recordText.text = "Recording"
            recordText.hidden = false
            stopButton.hidden = false
            pauseRecordText.text = "Click to Pause"
        
            // Build path to file to store audio
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            
            let currentDateTime = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "ddMMyyyy-HHmmss"
            let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
            let pathArray = [dirPath, recordingName]
            let filePath = NSURL.fileURLWithPathComponents(pathArray)
            
            var session = AVAudioSession.sharedInstance()
            session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
            
            audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        }
        else
        {
            // We're in the middle of recording.  Toggle pause/record modes
            paused = !paused;
            
            if (paused)
            {
                recordText.text = "Recording: Paused"
                pauseRecordText.text = "Click to Record"
                audioRecorder.pause()
            }
            else
            {
                recordText.text = "Recording"
                pauseRecordText.text = "Click to Pause"
                audioRecorder.record()
            }
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool)
    {
        if (flag)
        {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            
            performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "stopRecording")
        {
            // Create view controller object to point to the PlaySoundsViewController 
            // that was passed in as part of the seque
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            let data = sender as RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    // Stop button pressed.  This will trigger segue to next view
    @IBAction func stopAudio(sender: UIButton)
    {
        isRecording = false
        recordText.hidden = true
        stopButton.hidden = true
        pauseRecordText.text = "Click to Record"
        
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }

}

