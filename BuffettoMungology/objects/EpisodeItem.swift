//
//  EpisodeItem.swift
//  BuffettoMungology
//
//  Created by Anthonio Ez on 03/05/2019.
//  Copyright © 2019 Breathe. All rights reserved.
//

import Foundation

class EpisodeItem: NSObject, Codable
{
    public var title = "";
    public var text = "";
    public var file = "";
    public var duration = Double(0);
    public var size = Double(0);

    public override init()
    {
        title = "";
        text = "";
        file = "";
        duration = 0;
        size = 0;
    }

    static func copyElement(_ element: XML.Element) -> EpisodeItem?
    {
        let episode = EpisodeItem();
        for item in element.childElements
        {
            //print("item:", item)
            
            if(item.name == "title")
            {
                episode.title = item.text ?? ""
            }
            else if(item.name == "file")
            {
                episode.file = item.text ?? ""
            }
            else if(item.name == "text")
            {
                episode.text = item.text ?? ""
            }
            else if(item.name == "duration")
            {
                episode.duration = Double(item.text ?? "0") ?? 0
            }
            else if(item.name == "size")
            {
                episode.size = Double(item.text ?? "0") ?? 0
            }
        }
        
        return episode;
    }
    
    static func fromJson(_ data: String) -> EpisodeItem?
    {
        do
        {
            let jsonData = Data(data.utf8)
            if(jsonData.count > 0)
            {
                let jsonDecoder = JSONDecoder()
                let jsonList = try jsonDecoder.decode(EpisodeItem.self, from: jsonData)
                
                return jsonList
            }
        }
        catch
        {
            print(error.localizedDescription)
        }
        
        return nil;
    }
    
    @discardableResult
    static func toJson(_ episode: EpisodeItem) -> String
    {
        do
        {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(episode)
            
            if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            {
                //print("toJson:", jsonString)
                return jsonString
            }
        }
        catch
        {
            print(error.localizedDescription)
        }
        
        return "";
    }
}
