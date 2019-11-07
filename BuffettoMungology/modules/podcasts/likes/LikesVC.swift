//
//  LikesVC.swift
//  BuffettoMungology
//
//  Created by ZainAnjum on 11/5/19.
//  Copyright © 2019 Gallivanter. All rights reserved.
//

import UIKit

class LikesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var topHead: NSLayoutConstraint!
    var listings = [PodcastItem]()
    override func viewDidLoad() {
        super.viewDidLoad()

            collectionView.register(UINib(nibName: PodcastViewCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: PodcastViewCell.cellIdentifier)
            collectionView.dataSource = self;
            collectionView.delegate = self;
            
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action:#selector(refresh), for: .valueChanged)
            refreshControl.tintColor = UIColor.white
            
            collectionView.addSubview(self.refreshControl)
    }
    override func viewWillAppear(_ animated: Bool) {
        let likesEpisodes = App.podcasts.filter{
            return UserDefaults.standard.bool(forKey: "\($0.title)")
        }
        self.listings = likesEpisodes
        if self.listings.count == 0{
            self.collectionView.setEmptyMessage("No liked podcast available!")
        }else{
            self.collectionView.restore()
        }
        self.collectionView.reloadData()
    }
    
       @IBAction func onBack(_ sender: UIButton)
       {
           App.raiseEvent(App.EVENT_COLLAPSE)
           
           self.navigationController?.popViewController(animated: true)
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
    static func instance() -> LikesVC
    {
        let vc = LikesVC(nibName: "LikesVC", bundle: nil)
        return vc;
    }
    @objc func refresh()
    {
        refreshControl.endRefreshing()
        
//        reload()
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
//    @IBAction func likesBtnClicked() {
//        print("filled")
//        let likesEpisodes = App.podcasts.filter{
//            return UserDefaults.standard.bool(forKey: "\($0.title)")
//        }
//        likesEpisodes.forEach{
//
//            print($0.title)
//        }
//    }
    
    //MARK:- UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let cellSize = (self.view.frame.width - 20) / 4
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
//        self.savedItem = true
        
    self.navigationController?.pushViewController(EpisodesViewController.instance(item), animated: true)
    }
    

}
extension UICollectionView{
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        if #available(iOS 13.0, *) {
            messageLabel.textColor = .label
        } else {
            messageLabel.textColor = .black
        }
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.systemFont(ofSize: 18)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
