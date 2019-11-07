//
//  DetailsViewController.swift
//  BuffettoMungology
//
//  Created by Anthonio Ez on 29/03/2018.
//  Copyright © 2018 BuffettoMungology. All rights reserved.
//

import UIKit
import Alamofire

class DetailsViewController: UIViewController
{
    @IBOutlet weak var topHead: NSLayoutConstraint!
    @IBOutlet weak var labelPodcast: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var buttonPlay: UIButton!
    
    @IBOutlet weak var textContent: UITextView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var index = -1;
    var episode: EpisodeItem!
    
    static func instance(_ item: EpisodeItem, index: Int) -> DetailsViewController
    {
        App.episodeViewing = item;
        
        let vc = DetailsViewController(nibName: "DetailsViewController", bundle: nil)
        vc.index = index;
        vc.episode = item;
        return vc;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        labelPodcast.text = App.podcastViewing?.title ?? "";
        labelTitle.text = episode.title

        labelDesc.text = String(format: "%@ %@", Utils.formatByte(episode.size), Utils.formatDuration(episode.duration / 1000))
        
        UI.roundButton(buttonPlay)
        
        if(episode.text.hasSuffix(".txt"))
        {
            textContent.text = "";

            if(Utils.isOnline())
            {
                texting();
            }
        }
        else
        {
            updateText(episode.text.trim())
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillLayoutSubviews()
    {
        let inset = Utils.insets();
        if(inset.bottom > 0 || inset.top > 0)
        {
            if(inset.top > 0)
            {
                topHead.constant = inset.top + 5
            }
            self.view.setNeedsDisplay();
            self.view.layoutIfNeeded()
        }
        
        super.viewWillLayoutSubviews();
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    @IBAction func onBack(_ sender: UIButton)
    {
        App.raiseEvent(App.EVENT_COLLAPSE)

        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onPlay(_ sender: Any)
    {
        if(App.podcastPlaying == nil)
        {
            App.episodeIndex = -1;
            App.podcastPlaying = App.podcastViewing;
            
            //first time
            App.tape.playOrPause(index);
            
            App.logPodcast()
        }
        else if(App.podcastViewing != nil && App.podcastPlaying!.folder != App.podcastViewing!.folder)
        {
            //new book
            
            App.episodeIndex = -1;
            App.podcastPlaying = App.podcastViewing;
            
            App.tape.playOrPause(index);

            App.logPodcast()
        }
        else if(App.episodeIndex != index)
        {
            //new Episode
            
            App.tape.playOrPause(index);
        }
        else
        {
            //same Episode
                
            App.tape.playOrPause(index);
        }
    }
    
    func texting()
    {
        let url = (App.cloudUrl + "/" + App.podcastViewing.folder + "/" + episode.text).replacingOccurrences(of: " ", with: "%20")

        activityIndicator.startAnimating()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        Alamofire.request(url, method: .get)
            .responseData(queue: DispatchQueue.main, completionHandler: { (res) in
                
                self.activityIndicator.stopAnimating()
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let httpStatus = res.response?.statusCode;
                if(httpStatus == 200)
                {
                    if let data = String(data: res.data!, encoding: String.Encoding.utf8)
                    {
                        //print("access data", data);

                        self.episode.text = data.trim();

                        self.updateText(self.episode.text)

                    }
                }
                else
                {
                    let msg = String(data: res.data!, encoding: String.Encoding.utf8)
                    print("api err", msg ?? "");
                }
            })
    }
    
    func updateText(_ text: String)
    {
        textContent.text = text
    }
}
