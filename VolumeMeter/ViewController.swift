//
//  ViewController.swift
//  VolumeMeter
//
//  Created by Matthew S. Hill on 3/21/17.
//  Copyright © 2017 Matthew S. Hill. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var volumeMeter: UIProgressView!
    
    var engine: AVAudioEngine!
    var player: AVAudioPlayerNode!
    var file = AVAudioFile()
    var timer: Timer?
    var volumeFloat:Float = 0.0
    var fileName = "Put File Name here"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        engine = AVAudioEngine()
        player = AVAudioPlayerNode()
        
        let path = Bundle.main.path(forResource: fileName, ofType: ".mp3")!
        let url = NSURL.fileURL(withPath: path)
        
        let file = try? AVAudioFile(forReading: url)
        let buffer = AVAudioPCMBuffer(pcmFormat: file!.processingFormat, frameCapacity: AVAudioFrameCount(file!.length))
        do {
            try file!.read(into: buffer)
        }
            catch {
                
            }
        
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: buffer.format)
        
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: file?.processingFormat) {
            (buffer : AVAudioPCMBuffer!, time : AVAudioTime!) in
            
            let dataptr = buffer.floatChannelData!
            let dataptee = dataptr.pointee
            let datum = dataptee[Int(buffer.frameLength) - 1]
            
            self.volumeFloat = fabs((datum))
        }
        
        self.player.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
        
        self.engine.prepare()
        do {
            try self.engine.start()
        }
        catch _ {
            
        }
        self.player.play()
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateMeter() {
        self.volumeMeter.setProgress(volumeFloat, animated: false)
        
        if volumeMeter.progress > 0.8 {
            volumeMeter.tintColor = UIColor.red
        }
        else {
            volumeMeter.tintColor = UIColor.green
        }
    }
}

