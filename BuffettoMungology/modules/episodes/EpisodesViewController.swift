//
//  EpisodesViewController.swift
//  BuffettoMungology
//
//  Created by Anthonio Ez on 29/03/2018.
//  Copyright © 2018 BuffettoMungology. All rights reserved.
//

import UIKit
import SDWebImage

class EpisodesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imagePodcast: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var topHead: NSLayoutConstraint!
    @IBOutlet weak var btnStarOutlet: UIButton!
    var data = UserDefaults.standard
    var obj : EpisodeItem = EpisodeItem()
    var isBookMark = false
    
    var loaded = false;
    
    static func instance(_ item: PodcastItem) -> EpisodesViewController
    {
        App.podcastViewing = item;
        
        let vc = EpisodesViewController(nibName: "EpisodesViewController", bundle: nil)
        return vc;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.separatorColor = UIColor.clear
        self.tableView.backgroundColor = .clear
        self.tableView.register(UINib(nibName: EpisodeViewCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: EpisodeViewCell.cellIdentifier)

        labelTitle.text = App.podcastViewing.title;
        labelDesc.text = App.podcastViewing.desc.trim()
        
        let url = (App.cloudUrl + "/" + App.podcastViewing.folder + "/" + App.podcastViewing.image).replacingOccurrences(of: " ", with: "%20")
        imagePodcast.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "logo.png"), options: SDWebImageOptions.init(rawValue: 0), completed: nil)
        
        if data.bool(forKey: "\(App.podcastViewing.title)") == true {
                  btnStarOutlet.setImage(UIImage(named: "filledstar"), for: .normal)
              } else {
                  btnStarOutlet.setImage(UIImage(named: "star"), for: .normal)
              }

    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        update();
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
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return EpisodeViewCell.cellHeight;
    }
    
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return App.podcastViewing.episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let item = App.podcastViewing.episodes[indexPath.row];
        let cell = self.tableView.dequeueReusableCell(withIdentifier: EpisodeViewCell.cellIdentifier, for: indexPath as IndexPath) as! EpisodeViewCell
        cell.setData(item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        App.raiseEvent(App.EVENT_COLLAPSE)

        let item = App.podcastViewing.episodes[indexPath.row];
         
        self.navigationController?.pushViewController(DetailsViewController.instance(item, index: indexPath.row), animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - Actions
    @IBAction func onBack(_ sender: UIButton)
    {
        App.raiseEvent(App.EVENT_COLLAPSE)
        
        self.navigationController?.popViewController(animated: true)
    }
        
    func update()
    {
        tableView.reloadData()
    }
    
    @IBAction func btnStarAction(_ sender: Any) {
        
        if btnStarOutlet.currentImage == (UIImage(named: "star")) {
            
            btnStarOutlet.setImage(UIImage(named: "filledstar"), for: .normal)
            data.set(true,forKey: "\(App.podcastViewing.title)")
            self.isBookMark = true
            
        }
        else {
             btnStarOutlet.setImage(UIImage(named: "star"), for: .normal)
            data.set(false,forKey: "\(App.podcastViewing.title)")
             self.isBookMark = false
        }
        
    }
    
    
}
