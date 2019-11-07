//
//  Tape.swift
//  AudioBook
//
//  Created by Anthonio Ez on 04/05/2019.
//  Copyright © 2019 Breathe. All rights reserved.
//

import UIKit
import AVFoundation

class Tape: NSObject, AudioPlayerDelegate
{    
    var stopped = false;
    var seeking = false
    var firstProgression = false
    var tmr: Timer?

    public override init()
    {
    }
    
    func load()
    {
        App.player = AudioPlayer()
        App.player.mode = .normal;
        App.player.bufferingStrategy = .playWhenPreferredBufferDurationFull;
        App.player.preferredBufferDurationBeforePlayback = TimeInterval(3)
        App.player.preferredForwardBufferDuration = TimeInterval(15)
        
        App.player.delegate = self;
        
        //initAudio()
    }
    
    func initAudio()
    {
        do
        {
            //try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            
            try AVAudioSession.sharedInstance().setMode(AVAudioSession.Mode.moviePlayback)
            print("Playback OK")
            
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        }
        catch
        {
            print(error)
        }
        
    }

    func next()
    {
        if(App.podcastPlaying == nil) { return }
        
        let index = App.episodeIndex + 1;
        if(index >= App.podcastPlaying!.episodes.count)
        {
            stop();
        }
        else
        {
            if (App.player.state.isPlaying)
            {
                pause();
            }

            play(index);
        }
    }
    
    func prev()
    {
        if(App.podcastPlaying == nil) { return }

        let index = App.episodeIndex - 1;
        if(index < 0)
        {
            stop();
        }
        else
        {
            if (App.player.state.isPlaying)
            {
                pause();
            }

            play(index);
        }
    }
    
    func error()
    {
        App.player.stop()
        
        App.raiseEvent(App.EVENT_ERROR)
        
        untimer()
    }
    
    func stop()
    {
        App.logPlay()

        App.player.stop()
        
        App.raiseEvent(App.EVENT_STOPPED);

        untimer()
    }
    
    func playOrPause(_ index: Int)
    {
        if (App.episodeIndex == index)
        {
            if(App.player.state.isPlaying)
            {
                pause()
            }
            else if(App.player.state.isPaused)
            {
                resume()
            }
            else
            {
                play(index);
            }
        }
        else
        {
            if (App.player.state.isPlaying)
            {
                pause();
            }
            
            play(index);
        }
    }
    
    func play(_ index: Int)
    {
        if(App.podcastPlaying == nil)
        {
            return;
        }
        
        if(index < 0 || index > App.podcastPlaying!.episodes.count)
        {
            return;
        }
        
        App.episodePlaying = App.podcastPlaying!.episodes[index];
        App.episodeIndex = index;
        App.raiseEvent(App.EVENT_META);
        
        if(setup())
        {
            App.player.playImmediately();

            stopped = false;
            firstProgression = false;
            
            timer()
            
            App.logPlay()
        }
        else
        {
            error()
        }

        App.logEpisode()
    }
    
    @discardableResult
    func setup() -> Bool
    {
        let link = (App.cloudUrl + "/" + App.podcastPlaying!.folder + "/" + App.episodePlaying!.file).replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: link);
        let item = AudioItem(highQualitySoundURL: url, mediumQualitySoundURL: url, lowQualitySoundURL: url)
        if(item != nil)
        {
            item!.title = App.podcastPlaying!.title;
            item!.artist = App.episodePlaying!.title;
            
            App.player.currentItem = item!
            //App.player.play(item: item!)
            
            return true
        }
        else
        {
            return false
        }
    }
    
    func resume()
    {
        firstProgression = false;
        App.raiseEvent(App.EVENT_LOADING)
        
        App.player.resume()
        
        timer()
    }
    
    func pause()
    {
        App.player.pause()
        
        untimer()
        
        App.logPlay()
    }
    
    func seek(_ value: Double)
    {
        firstProgression = false;
        seeking = true
        
        App.episodePosition = value

        App.player.seek(to: value);
        
        App.logPlay()
        
        App.raiseEvent(App.EVENT_TIME)
    }
    
    func rate(_ value: Float)
    {
        App.player.rate = value
    }
    
    func rewind(_ duration: TimeInterval)
    {
        if(App.podcastPlaying == nil) { return }

        let dur = App.player.currentItemDuration ?? 0
        let pos = App.player.currentItemProgression ?? 0;

        if(dur == 0) { return }
        
        App.episodeDuration = dur;
        App.episodePosition = pos;
        
        var value = App.episodePosition - duration;
        if(value < 0)
        {
            value = 0;
        }
       
        seek(value);
    }
    
    func forward(_ duration: TimeInterval)
    {
        if(App.podcastPlaying == nil) { return }

        let dur = App.player.currentItemDuration ?? 0
        let pos = App.player.currentItemProgression ?? 0;
        
        if(dur == 0) { return }
        
        App.episodeDuration = dur;
        App.episodePosition = pos;

        let value = App.episodePosition + duration;
        if(value > App.episodeDuration)
        {
            return
        }

        seek(value);
    }
    
    @objc func timing()
    {
        //print("timing:")
        
        //App.raiseEvent(App.EVENT_TIME)
    }
    
    func timer()
    {
        untimer()
        
        tmr = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timing), userInfo: nil, repeats: true)
    }
    
    func untimer()
    {
        if(tmr != nil)
        {
            tmr!.invalidate();
            tmr = nil;
        }
    }
    
    public func remoteControlReceived(with event: UIEvent)
    {
        guard event.type == .remoteControl else {
            return
        }
        
        switch event.subtype {
        case .remoteControlBeginSeekingBackward:
            rewind(10)
            break;

        case .remoteControlBeginSeekingForward:
            forward(30)
            break;

        case .remoteControlEndSeekingBackward:
            break;

        case .remoteControlEndSeekingForward:
            break;

        case .remoteControlNextTrack:
            next()
            break;

        case .remoteControlPreviousTrack:
            prev()
            break;

        case .remoteControlPause,
             .remoteControlTogglePlayPause where App.player.state.isPlaying:
            pause()
            break;

        case .remoteControlPlay,
             .remoteControlTogglePlayPause where App.player.state.isPaused:
            resume()
            break;

        case .remoteControlStop:
            stop()
            break;

        default:
            break
        }
    }

    //MARK: - AudioPlayerDelegate
    func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState)
    {
        print("didChangeStateFrom:", from, "to", state)
        
        if(state.isBuffering || state.isWaitingForConnection)
        {
            App.raiseEvent(App.EVENT_LOADING)
        }
        else if(state.isPlaying)
        {
            App.raiseEvent(App.EVENT_STARTING)
        }
        else if(state.isPaused)
        {
            App.raiseEvent(App.EVENT_PAUSED)
        }
        else if(state.isNexted)
        {
            next()
        }
        else if(state.isFailed)
        {
            App.raiseEvent(App.EVENT_ERROR)
        }
        else if(state.isStopped)
        {
            App.raiseEvent(App.EVENT_STOPPED)
        }
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, willStartPlaying item: AudioItem)
    {
        print("willStartPlaying")
        
        App.raiseEvent(App.EVENT_STARTING);
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateProgressionTo time: TimeInterval, percentageRead: Float)
    {
        print("didUpdateProgressionTo:", time)
        
        App.episodePosition = App.player.currentItemProgression ?? 0;
        App.episodeDuration = App.player.currentItemDuration ?? 0

        if(seeking)
        {
            seeking = false
        }
        else
        {
            if(firstProgression)
            {
                App.raiseEvent(App.EVENT_TIME)
            }
            else
            {
                firstProgression = true
                App.raiseEvent(App.EVENT_PLAYING)
            }
        }
        
        App.logPlay()
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didFindDuration duration: TimeInterval, for item: AudioItem)
    {
        //App.raiseEvent(App.EVENT_TIME)
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateEmptyMetadataOn item: AudioItem, withData data: Metadata)
    {
        print("didUpdateEmptyMetadataOn")
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didLoad range: TimeRange, for item: AudioItem)
    {
        //print("didLoad: ", range.earliest, range.latest)
        
        //App.raiseEvent(App.EVENT_TIME)
    }

}
