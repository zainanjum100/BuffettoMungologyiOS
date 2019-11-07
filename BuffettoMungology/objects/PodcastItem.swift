//
//  PodcastItem.swift
//  BuffettoMungology
//
//  Created by Anthonio Ez on 03/05/2019.
//  Copyright © 2019 BuffettoMungology. All rights reserved.
//

import UIKit

class PodcastItem: NSObject, Codable
{
    public var title = "";
    public var author = "";
    public var folder = "";
    public var image = "";
    public var desc = "";

    public var episodes = [EpisodeItem]();
 
    public override init()
    {
        title = "";
        author = "";
        folder = "";
        image = "";
        desc = "";
        
        episodes = [EpisodeItem]();
    }
    
    static func copyElement(_ element: XML.Element) -> PodcastItem?
    {
        let podcast = PodcastItem();
        for item in element.childElements
        {
            //print("item:", item)

            if(item.name == "title")
            {
                podcast.title = item.text ?? ""
            }
            else if(item.name == "author")
            {
                podcast.author = item.text ?? ""
            }
            else if(item.name == "folder")
            {
                podcast.folder = item.text ?? ""
            }
            else if(item.name == "image")
            {
                podcast.image = item.text ?? ""
            }
            else if(item.name == "description")
            {
                podcast.desc = item.text ?? ""
            }
            else if(item.name == "episodes")
            {
                podcast.episodes.removeAll()
                for episodeElement in  item.childElements
                {
                    //print("episode:", episodeElement)
                    
                    if let episodeItem = EpisodeItem.copyElement(episodeElement)
                    {
                        podcast.episodes.append(episodeItem)
                    }
                }
            }
        }
        
        return podcast;
    }

    static func fromJson(_ data: String) -> PodcastItem?
    {
        do
        {
            let jsonData = Data(data.utf8)
            if(jsonData.count > 0)
            {
                let jsonDecoder = JSONDecoder()
                let jsonList = try jsonDecoder.decode(PodcastItem.self, from: jsonData)
                
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
    static func toJson(_ podcast: PodcastItem) -> String
    {
        do
        {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(podcast)
            
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

