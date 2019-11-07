//
//  AudioBook.swift
//  AudioBook
//
//  Created by Anthonio Ez on 03/05/2019.
//  Copyright © 2019 Breathe. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class App
{
    static var EVENT_NAME       = "buffettomungology"
    
    static var EVENT_LANG       = "EVENT_LANG"
    static var EVENT_IDLE       = "EVENT_IDLE"
    static var EVENT_LOADING    = "EVENT_LOADING"
    static var EVENT_STARTING   = "EVENT_STARTING"
    static var EVENT_PLAYING    = "EVENT_PLAYING"
    
    static var EVENT_PAUSED     = "EVENT_PAUSED"
    static var EVENT_STOPPED    = "EVENT_STOPPED"
    static var EVENT_ERROR      = "EVENT_ERROR"
    static var EVENT_META       = "EVENT_META"
    static var EVENT_SEEK       = "EVENT_SEEK"
    static var EVENT_TIME       = "EVENT_TIME"
    static var EVENT_COLLAPSE   = "EVENT_COLLAPSE"
    
    static var cloudUrl        = "https://storage.googleapis.com/buffettomungoly";
    static var podcastXml      = "https://storage.googleapis.com/buffettomungoly/podcast.xml";
    
    static var podcasts    = [PodcastItem]()
    static var podcastViewing: PodcastItem!     = nil;
    static var podcastPlaying: PodcastItem!     = nil;
    
    static var episodeIndex                     = -1;
    static var episodePlaying: EpisodeItem!     = nil;
    static var episodeViewing: EpisodeItem!     = nil;
    static var episodePosition                  = Double(0);
    static var episodeDuration                  = Double(0);

    static var appName          = "";
    static var audioTitle       = "";
    static var audioAuthor      = "";
    static var streamUrl        = "";
    static var seekable         = false;
        
    static var player       = AudioPlayer()

    static var navController: UINavigationController!
    
    static var tape = Tape();
    
    static func raiseEvent(_ type: String)
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: App.EVENT_NAME), object: type, userInfo: nil)
    }
    
    static func home()
    {
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn"){
            AppDelegate.pushController(MainViewController.instance(), animated: true);
        }else{
            AppDelegate.pushController(SocialMediaLogin.instance(), animated: true);
//            window?.rootViewController = SocialMediaLogin.instance()
        }
            
        
        
    }
    func setisLoggedin(_ set: Bool) {
        UserDefaults.standard.set(set, forKey: "isLoggedIn")
    }
    func isLoggedin() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    public static func openUrl(_ url: String)
    {
        UIApplication.shared.openURL(URL(string: url)!)
    }
    
    public static func logPlay()
    {
        Prefs.index     = App.episodeIndex;
        Prefs.position  = App.episodePosition
        Prefs.duration  = App.episodeDuration
    }
    
    public static func logPodcast()
    {
        Prefs.podcast = PodcastItem.toJson(App.podcastPlaying);
    }
    
    public static func logEpisode()
    {
        Prefs.episode = EpisodeItem.toJson(App.episodePlaying);
    }
    
    public static func unlogPlay()
    {
        App.episodeIndex    = Prefs.index
        App.episodePosition = Prefs.position
        App.episodeDuration = Prefs.duration
    
        App.episodePlaying = EpisodeItem.fromJson(Prefs.episode)
        App.podcastPlaying = PodcastItem.fromJson(Prefs.podcast)
        
        App.episodeViewing = App.episodePlaying
        App.podcastViewing = App.podcastPlaying
    }

}
