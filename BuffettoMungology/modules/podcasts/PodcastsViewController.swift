//
//  BooksViewController.swift
//  AudioBook
//
//  Created by Anthonio Ez on 29/03/2018.
//  Copyright © 2018 AudioBook. All rights reserved.
//

import UIKit
import Alamofire
import FacebookCore
import FacebookLogin
class PodcastsViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate
{
    @IBOutlet weak var topHead: NSLayoutConstraint!
    @IBOutlet weak var viewHead: UIView!
    @IBOutlet weak var buttonSearch: UIButton!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var likesBtn: UIButton!
    @IBOutlet weak var textSearch: UITextField!
    @IBOutlet weak var bottomBooks: NSLayoutConstraint!
    @IBOutlet weak var labelEmpty: UILabel!
    @IBOutlet weak var collectionPodcasts: UICollectionView!
    var savedItem = false
    
    var navController : UINavigationController!
    @IBOutlet weak var btnLogOutOutlet: UIButton!
    var tapGesture: UITapGestureRecognizer!
    var refreshControl: UIRefreshControl!
    var cellSize = CGFloat(0)
    let window : UIWindow! = nil
    var listings    = [PodcastItem]()

    static func instance() -> PodcastsViewController
    {
        let vc = PodcastsViewController(nibName: "PodcastsViewController", bundle: nil)
        return vc;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(viewTap));
        tapGesture.cancelsTouchesInView = false
        
        viewHead.layer.cornerRadius = 3;
        
        textSearch.delegate = self
        
        textSearch.attributedPlaceholder = NSAttributedString(string: textSearch.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.4)])
        textSearch.addTarget(self, action: #selector(searchChanged), for: UIControl.Event.editingChanged)
        textSearch.addTarget(self, action: #selector(searchSubmitted), for: UIControl.Event.editingDidEnd)

        collectionPodcasts.backgroundColor = .clear
        collectionPodcasts.register(UINib(nibName: PodcastViewCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: PodcastViewCell.cellIdentifier)
        collectionPodcasts.dataSource = self;
        collectionPodcasts.delegate = self;
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(refresh), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        
        collectionPodcasts.addSubview(self.refreshControl)
        
        labelEmpty.isHidden = true;
        
       
        
        searchClose();
    }
    
    

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.view.addGestureRecognizer(tapGesture)

        view.setNeedsLayout()
        view.layoutIfNeeded()

        DispatchQueue.main.async {
            self.cellSize = (self.view.frame.width - 20) / 4

            if(self.listings.count == 0 )
            {
                self.reload()
            }
            else
            {
                self.update()
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        self.view.removeGestureRecognizer(tapGesture)
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
    
   
  
    @objc func performLogout(){
          
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator);
        
        cellSize = (size.width - 20) / 4

        collectionPodcasts.collectionViewLayout.invalidateLayout()
        
        self.view.setNeedsDisplay()
    }
    
    //MARK: - UICollectionViewDataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return listings.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PodcastViewCell.cellIdentifier, for: indexPath) as! PodcastViewCell
        let item = listings[indexPath.row];
        cell.setData(item);
        return cell
        
    }
    @IBAction func likesBtnClicked() {
//        print("filled")
//        let likesEpisodes = App.podcasts.filter{
//            return UserDefaults.standard.bool(forKey: "\($0.title)")
//        }
//        let vc = LikesVC.instance()
//        vc.listings = likesEpisodes
        navigationController?.pushViewController(LikesVC.instance(), animated: true)
    }
    //MARK:- UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: cellSize, height: cellSize)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 0.0, left: 5, bottom: 0.0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return CGFloat(5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return CGFloat(0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
        App.raiseEvent(App.EVENT_COLLAPSE)

        let item = listings[indexPath.row]
        self.savedItem = true
        
    self.navigationController?.pushViewController(EpisodesViewController.instance(item), animated: true)
    }

    //MARK:- UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        return true
    }

    //MARK:- Actions
    @IBAction func onSearch(_ sender: Any)
    {
        searchOpen()
    }
    
    @IBAction func onClose(_ sender: Any)
    {
        searchClose()
    }
    
    //MARK:- Events
    @objc func viewTap(sender: UITapGestureRecognizer)
    {
        //textSearch.resignFirstResponder()
    }
    
    @objc func searchChanged()
    {
        search()
    }

    @objc func searchSubmitted()
    {
        textSearch.resignFirstResponder()

        search()
    }
    
    //MARK:- Funcs
    @objc func refresh()
    {
        refreshControl.endRefreshing()
        
        reload()
    }
    
    func update()
    {
        collectionPodcasts.reloadData()
        
        refreshControl.endRefreshing()

        labelEmpty.isHidden = (listings.count != 0)
    }
    
    func search()
    {
        listings.removeAll()
        let phrase = (textSearch.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
        if(phrase.count == 0)
        {
            listings.append(contentsOf: App.podcasts)
        }
        else
        {
            for podcast in App.podcasts
            {
                if(
                    podcast.title.lowercased().contains(phrase)
                        || podcast.author.lowercased().contains(phrase)
                        || podcast.desc.lowercased().contains(phrase)
                        || podcast.folder.lowercased().contains(phrase)
                )
                {
                    listings.append(podcast)
                }
            }
        }
        
        update()
    }

    func searchOpen()
    {
        textSearch.text = ""
        buttonSearch.isHidden = true
        buttonClose.isHidden = false
        textSearch.isHidden = false
        likesBtn.isHidden = true
        btnLogOutOutlet.isHidden = true
        
        textSearch.becomeFirstResponder()
    }
    
    func searchClose()
    {
        btnLogOutOutlet.isHidden = false
        buttonSearch.isHidden = false
        likesBtn.isHidden = false
        buttonClose.isHidden = true;
        textSearch.isHidden = true
        
        textSearch.text = "";
        textSearch.resignFirstResponder()
    }

    func podcastList()
    {
        _ = SwiftOverlays.showBlockingWaitOverlay()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        Alamofire.request(App.podcastXml, method: .get)
            .responseData(queue: DispatchQueue.main, completionHandler: { (res) in
                
                SwiftOverlays.removeAllBlockingOverlays()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let httpStatus = res.response?.statusCode;
                if(httpStatus == 200)
                {
                    if let data = String(data: res.data!, encoding: String.Encoding.utf8)
                    {
                        //rint("access data", data);
                        
                        let xml = try! XML.parse(data)

                        let podcasts = xml["podcasts"]
                        //print("podcasts:", podcasts)
                        
                        App.podcasts.removeAll()
                        if let element = podcasts.element
                        {
                            for podcastElement in  element.childElements
                            {
                                //print("podcast:", podcastElement)
                                
                                if let podcastItem = PodcastItem.copyElement(podcastElement)
                                {
                                    App.podcasts.append(podcastItem)
                                }
                            }
                        }

                        self.listings.removeAll()
                        self.listings.append(contentsOf: App.podcasts)
                        
                        self.update()
                        
                        return
                    }
                }
                else
                {
                    let msg = String(data: res.data!, encoding: String.Encoding.utf8)
                    print("api err", msg ?? "");
                }
                
                self.refreshControl.endRefreshing()
                
                self.failed("Unable to load podcasts!");
            })
    }
    
    @objc func reload()
    {
        if(Utils.isOnline())
        {
            labelEmpty.isHidden = true;
            
            podcastList()
        }
        else
        {
            failed("No internet connection!");
        }
        
    }
    
    func failed(_ msg: String)
    {
        Utils.alert(self, "Error", msg, response: {
            
        })
        
        update()
    }
    
    @IBAction func btnLogOutAction(_ sender: Any) {
        
        if let token = AccessToken.current{
            AccessToken.current =  nil
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
}

