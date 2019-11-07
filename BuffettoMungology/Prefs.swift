//
//  Prefs.swift
//  AudioBook
//
//  Created by Anthonio Ez on 03/05/2019.
//  Copyright © 2019 Breathe. All rights reserved.
//

import Foundation

public class Prefs
{
    static let KEY_PLAY_INDEX      = "play_index";
    
    static let KEY_PLAY_POSITION   = "play_position";
    static let KEY_PLAY_DURATION   = "play_duration";
    
    static let KEY_PLAY_PODCAST    = "play_podcast";
    static let KEY_PLAY_EPISODE    = "play_episode";
    
    
    static public func getBool(_ key: String, defValue: Bool) -> Bool
    {
        let defaults: UserDefaults = UserDefaults.standard
        if(defaults.object(forKey: key) == nil)
        {
            return defValue
        }
        else
        {
            return defaults.bool(forKey: key);
        }
    }
    static public func setBool(_ key: String, value: Bool)
    {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(value, forKey: key);
        defaults.synchronize()
    }
        
    static public func getInt(_ key: String, defValue: Int) -> Int
    {
        let defaults: UserDefaults = UserDefaults.standard
        if(defaults.object(forKey: key) == nil)
        {
            return defValue
        }
        else
        {
            return defaults.integer(forKey: key);
        }
    }
    static public func setInt(_ key: String, value: Int)
    {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(value, forKey: key);
        defaults.synchronize()
    }
    
    static public func getDouble(_ key: String, defValue: Double) -> Double
    {
        let defaults: UserDefaults = UserDefaults.standard
        if(defaults.object(forKey: key) == nil)
        {
            return defValue
        }
        else
        {
            return defaults.double(forKey: key);
        }
    }
    static public func setDouble(_ key: String, value: Double)
    {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(value, forKey: key);
        defaults.synchronize()
    }
    
    static public func getString(_ key: String, defValue: String) -> String
    {
        let defaults: UserDefaults = UserDefaults.standard
        if(defaults.object(forKey: key) == nil)
        {
            return defValue
        }
        else
        {
            return defaults.string(forKey: key)!;
        }
    }
    static public func setString(_ key: String, value: String)
    {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(value, forKey: key);
        defaults.synchronize()
    }
    
    static public func getData(_ key: String, defValue: Data) -> Data?
    {
        let defaults: UserDefaults = UserDefaults.standard
        if(defaults.object(forKey: key) == nil)
        {
            return defValue
        }
        else
        {
            return defaults.data(forKey: key);
        }
    }
    static public func setData(_ key: String, value: Data)
    {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(value, forKey: key);
        defaults.synchronize()
    }

    //MARK: - Settings
    static public var index: Int
    {
        get
        {
            return getInt(KEY_PLAY_INDEX, defValue: 0);
        }
        set(value)
        {
            setInt(KEY_PLAY_INDEX, value: value)
        }
    }
    
    static public var position: Double
    {
        get
        {
            return getDouble(KEY_PLAY_POSITION, defValue: 0);
        }
        set(value)
        {
            setDouble(KEY_PLAY_POSITION, value: value)
        }
    }
    
    static public var duration: Double
    {
        get
        {
            return getDouble(KEY_PLAY_DURATION, defValue: 0);
        }
        set(value)
        {
            setDouble(KEY_PLAY_DURATION, value: value)
        }
    }
    
    static public var podcast: String
    {
        get
        {
            return getString(KEY_PLAY_PODCAST, defValue: "");
        }
        set(value)
        {
            setString(KEY_PLAY_PODCAST, value: value)
        }
    }
    
    static public var episode: String
    {
        get
        {
            return getString(KEY_PLAY_EPISODE, defValue: "");
        }
        set(value)
        {
            setString(KEY_PLAY_EPISODE, value: value)
        }
    }

}
