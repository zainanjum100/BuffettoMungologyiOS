//
//  MainViewController.swift
//  BuffettoMungology
//
//  Created by Anthony Ezeh on 13/07/2019.
//  Copyright © 2019 Gallivanter. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMobileAds

class MainViewController: UIViewController, CTBottomSlideDelegate, GADBannerViewDelegate, URLSessionDownloadDelegate, URLSessionDelegate
{
        
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewFloater: UIView!
    @IBOutlet weak var viewPlayer: UIView!
    @IBOutlet weak var viewControl: UIView!
    @IBOutlet weak var imagePodcast: UIImageView!
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var buttonAction: UIButton!

    @IBOutlet weak var topFloater: NSLayoutConstraint!
    @IBOutlet weak var heightFloater: NSLayoutConstraint!
    
    @IBOutlet weak var sliderPlayer: UISlider!
    @IBOutlet weak var labelPosition: UILabel!
    @IBOutlet weak var labelRemaining: UILabel!
    @IBOutlet weak var buttonSpeed: UIButton!
    
    let hPlayer = CGFloat(70)
    let hControl = CGFloat(210)
    
    var index = 0;
    var code = "";
    
    var firstTime = true;
    let seekMax = Float(1000)
    let placeHolder = UIImage(named: "logo.png");


    var bottomController: CTBottomSlideController!
    var tapGesture: UITapGestureRecognizer!
    
    var navController: UINavigationController!
    var bannerView: GADBannerView!
    
    static func instance() -> MainViewController
    {
        let vc = MainViewController(nibName: "MainViewController", bundle: nil)
        return vc;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(floaterTap));
        tapGesture.cancelsTouchesInView = false
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)

        navController = UINavigationController(rootViewController: PodcastsViewController.instance())
        navController.isToolbarHidden = true;
        navController.isNavigationBarHidden = true
        navController.willMove(toParent: self)
        navController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navController.view.frame = CGRect(x: 0, y: 0, width: viewMain.frame.width, height: viewMain.frame.height)
        self.viewMain.addSubview(navController.view)

        addChild(navController)
        
        navController.didMove(toParent: self)

        bottomController = CTBottomSlideController(topConstraint: topFloater, parent: view, bottomView: viewPlayer, navController: self.navigationController)
        bottomController?.delegate = self;
        
        buttonSpeed.layer.borderColor = UIColor(hex: "#D8DADE").cgColor
        buttonSpeed.layer.borderWidth = 1;
        buttonSpeed.layer.cornerRadius = 5
        
        sliderPlayer.value = 0;
        sliderPlayer.minimumValue = 0;
        sliderPlayer.maximumValue = seekMax;
        
        progressView.progress = 0;
        
        bannerView.isHidden = true
        bannerView.adUnitID = "ca-app-pub-1361855967936104/2353264627"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackEvent), name: NSNotification.Name(rawValue: App.EVENT_NAME), object: nil)
        
        firstTime = true;

        view.bringSubviewToFront(viewFloater)
        
        view.addSubview(bannerView)
        bannerView.load(GADRequest())
    }
    
    override public func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.viewPlayer.addGestureRecognizer(tapGesture)

        DispatchQueue.main.async {
           
            if(self.firstTime)
            {
                self.firstTime = false;
                
                self.setupPanel();
            }
            
            self.updateNavFrame()
        }

    }
    
    override public func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated);
        
        self.viewPlayer.removeGestureRecognizer(tapGesture)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        
        updatePanel();
        updateNavFrame();
        bottomController?.viewWillTransition(to: size, with: coordinator)
    }

    override func viewWillLayoutSubviews()
    {
        updatePanel();
        updateNavFrame();

        super.viewWillLayoutSubviews();
    }
    
    //MARK:- CTBottomSlideDelegate
    func didPanelClosed()
    {
        viewControl.isHidden = true;
        progressView.isHidden = false;
        
        updateNavFrame()
    }
    
    func didPanelCollapse()
    {
        viewControl.isHidden = true;
        progressView.isHidden = false;
        
        updateNavFrame()
    }
    
    func didPanelExpand()
    {
        viewControl.isHidden = false;
        progressView.isHidden = true;
        
        updateNavFrame()

    }
    
    func didPanelAnchor()
    {
        viewControl.isHidden = false;
        progressView.isHidden = true;
        
        updateNavFrame()
    }
    
    func didPanelMove(panelOffset: CGFloat)
    {
        
    }

    //MARK:- Events
    @objc func floaterTap(sender: UITapGestureRecognizer)
    {
        let v = sender.view
        let loc = sender.location(in: v)
        let sv = v?.hitTest(loc, with: nil) // note: it is a `UIView?`
        
        if sv == buttonPlay
        {
            
        }
        else
        {
            if(bottomController?.currentState == .expanded)
            {
                bottomController?.closePanel()
            }
            else if(bottomController?.currentState == .anchored)
            {
                bottomController?.closePanel()
            }
            else if(bottomController?.currentState == .collapsed)
            {
                bottomController?.expandPanel()
            }
        }
    }
    
     var fileUrl: URL?
            func fetchAndSaveFile(safeUrl: String) {
                // Create destination URL
    //            self.startActivityIndicator()
                let documentsUrl:URL =  getDocumentsDirectory()
                let podcastName: String
                if let podcast = App.podcastPlaying
                {
                    podcastName = podcast.title
                }else{
                    podcastName = ""
                }
                let destinationFileUrl = documentsUrl.appendingPathComponent("\(podcastName).mp3")
                
                let fileURL = URL(string: safeUrl)
                
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue())
                let request = URLRequest(url:fileURL!)
                
                let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                    if let tempLocalUrl = tempLocalUrl, error == nil {
                        // Success
                        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                            print("Successfully downloaded. Status code: \(statusCode)")
                            
                        }
                        
                        do {
                            try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                            DispatchQueue.main.async {
                                let pdfLoc = NSData(contentsOf: destinationFileUrl)
    //                            self.document  = [pdfLoc]
                                
    //                            ApiService.instance.fileUrl = destinationFileUrl
    //                                if let pdfDocument = PDFDocument(url: destinationFileUrl) {
    //                                    self.pdfView.displayMode = .singlePageContinuous
    //                                    self.pdfView.autoScales = true
    //                                    self.pdfView.document = pdfDocument
    //                                    self.stopActivityIndicator()
    //                                }
                                
                                
                                
                            }
                        } catch (let writeError) {
                            print("Error creating a file \(destinationFileUrl) : \(writeError)")
    //                        self.clearAllFilesFromTempDirectory()
                            DispatchQueue.main.async {
                                self.viewDidLoad()
                            }
                            
                        }
                        
                    } else {
                        print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "nil valv");
                    }
                }
                task.resume()
            }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("finish downloading task")
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        print(percentage)
    }
    @IBAction func downloadBtnTapped(_ sender: UIButton) {
        let link = (App.cloudUrl + "/" + App.podcastPlaying!.folder + "/" + App.episodePlaying!.file).replacingOccurrences(of: " ", with: "%20")
//        fetchAndSaveFile(safeUrl: "https://funksyou.com/fileDownload/Songs/0/32527.mp3")
        let urlString = "https://funksyou.com/fileDownload/Songs/0/32527.mp3"
//        App.podcastPlaying.title
//        savePdf(urlString: urlString, fileName: "vaste")
        print(pdfFileAlreadySaved(url: urlString, fileName: "vaste"))
        
    }
    func savePdf(urlString:String, fileName:String) {
            DispatchQueue.main.async {
                let url = URL(string: urlString)
                let pdfData = try? Data.init(contentsOf: url!)
                let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
                let pdfNameFromUrl = "\(fileName).mp3"
                let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
                do {
                    try pdfData?.write(to: actualPath, options: .atomic)
                    print("mp3 successfully saved!")
                } catch {
                    print("mp3 could not be saved")
                }
            }
        }

        func showSavedPdf(url:String, fileName:String) {
            if #available(iOS 10.0, *) {
                do {
                    let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                    for url in contents {
                        if url.description.contains("\(fileName).mp3") {
                           // its your file! do what you want with it!

                    }
                }
            } catch {
                print("could not locate mp3 file !!!!!!!")
            }
        }
    }

    // check to avoid saving a file multiple times
    func pdfFileAlreadySaved(url:String, fileName:String)-> Bool {
        var status = false
        if #available(iOS 10.0, *) {
            do {
                let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("\(fileName).mp3") {
                        status = true
                    }
                }
            } catch {
                print("could not locate mp3 file !!!!!!!")
            }
        }
        return status
        
//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//        let url = NSURL(fileURLWithPath: path)
//        if let pathComponent = url.appendingPathComponent("nameOfFileHere") {
//            let filePath = pathComponent.path
//            let fileManager = FileManager.default
//            if fileManager.fileExists(atPath: filePath) {
//                print("FILE AVAILABLE")
//            } else {
//                print("FILE NOT AVAILABLE")
//            }
//        } else {
//            print("FILE PATH NOT AVAILABLE")
//        }
    }
    @objc func playbackEvent(notification: Notification)
    {
        if (notification.name.rawValue != App.EVENT_NAME) { return }
        
        if let type = notification.object as? String
        {
            print("event:", type);
            
            switch(type)
            {
            case App.EVENT_META:
                resetTime()
                updateMeta()
                break;
                
            case App.EVENT_LOADING:
                labelDesc.text = "Loading..."

                pauseUI()
                break;
                
            case App.EVENT_STARTING:
                labelDesc.text = "Starting..."
                print("playing....")
                pauseUI()
                break;
                
            case App.EVENT_PLAYING:
                updateMeta()
                pauseUI()
                break;
                
            case App.EVENT_PAUSED:
                updateMeta()
                playUI()
                break;
                
            case App.EVENT_STOPPED:
                updateMeta()
                stopUI();
                break;
                
            case App.EVENT_ERROR:
                
                stopUI();
                
                labelDesc.text = "An error ocurred!";
                break;
                
            case App.EVENT_TIME:
                updateMeta()
                updateTime()
                break;
                
            case App.EVENT_COLLAPSE:
                bottomController?.closePanel()
                break;
                
            default:
                break;
            }
        }
    }

    //MARK:- Actions
    @IBAction func onRewind(_ sender: Any)
    {
        App.tape.rewind(10)
    }
    
    @IBAction func onPlay(_ sender: Any)
    {
        App.tape.playOrPause(App.episodeIndex)
    }
    
    @IBAction func onAction(_ sender: Any) 
    {
        App.tape.playOrPause(App.episodeIndex)
    }
    
    @IBAction func onForward(_ sender: Any)
    {
        App.tape.forward(30)
    }
    
    @IBAction func onSpeed(_ sender: Any)
    {
        let dropDown = DropDown()
        dropDown.direction = .top
        dropDown.anchorView = buttonSpeed;
        dropDown.width = 70
        dropDown.cellHeight = 36
        dropDown.bottomOffset = CGPoint(x: 10, y: -buttonSpeed.frame.size.height);
        
        var speeds = [String]()

        var step = 0.25;
        for _ in 0..<12
        {
            speeds.append(String(format: "%.2f", step) + "x");
            step += 0.25;
        }
        
        dropDown.dataSource = speeds;
        
        dropDown.selectionAction = { (index: Int, item: String) in
            
            let rate = Float(0.25 + (0.25 * Float(index)));
            
            App.tape.rate(rate)
        }
        dropDown.show()
    }
    
    @IBAction func onInfo(_ sender: Any)
    {
        bottomController.closePanel()
        self.navController.pushViewController(DetailsViewController.instance(App.episodePlaying, index: App.episodeIndex), animated: true)
    }
    
    @IBAction func onSliderChanged(_ sender: Any)
    {
        let progress = sliderPlayer.value;
        
        progressView.progress = (progress / seekMax);
        
        let value = Double(progress / seekMax) * App.episodeDuration
        App.tape.seek(value)
        
    }
    
    //MARK:- Funcs
    func setupPanel()
    {
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        heightFloater.constant = hPlayer
        
        updatePanel()
        
        if(App.podcastPlaying != nil && App.episodePlaying != nil)
        {
            bottomController?.currentState = .expanded;
            bottomController.closePanel();
            viewFloater.isHidden = false;
            
            updateMeta();
            updateTime();
        }
        else
        {
            bottomController?.currentState = .expanded;
            bottomController?.hidePanel()
            viewFloater.isHidden = true;
        }
    }
    
    func updatePanel()
    {
        var fheight = view.frame.height
        fheight -= (bannerView.isHidden ? 0 : 50)
        
        let opened = fheight - hPlayer - hControl - UI.insets().bottom
        let closed = fheight - hPlayer - UI.insets().bottom;
        
        bottomController?.setExpandedTopMargin(pixels: opened)
        bottomController?.setAnchoredTopMargin(pixels: opened)
        bottomController?.setClosedTopMargin(pixels: closed)
    }
    
    func updateNavFrame()
    {
        let bh = CGFloat(50)
        let ib = UI.insets().bottom

        bannerView.frame = CGRect(x: 0, y: view.frame.height - ib - bh, width: view.frame.width, height: bh)

        var h = CGFloat(0);
        h += (viewFloater!.isHidden ? 0 : hPlayer)
        h += (bannerView!.isHidden ? 0 : bh)
        h += ib
        
        navController.view.frame = CGRect(x: 0, y: 0,
                                          width: viewMain.frame.width,
                                          height: viewMain.frame.height - h)
    }
    
    func pauseUI()
    {
        buttonPlay.setImage(UIImage(named: "ic_pause_48pt"), for: .normal);
        buttonAction.setImage(UIImage(named: "ic_pause_48pt"), for: .normal);
    }
    
    func playUI()
    {
        buttonPlay.setImage(UIImage(named: "ic_play_arrow_48pt"), for: .normal);
        buttonAction.setImage(UIImage(named: "ic_play_arrow_48pt"), for: .normal);
    }
    
    func stopUI()
    {
        labelPosition.text = "0:00"
        sliderPlayer.value = 0
        progressView.progress = 0;
        buttonPlay.setImage(UIImage(named: "ic_play_arrow_48pt"), for: .normal);
        buttonAction.setImage(UIImage(named: "ic_play_arrow_48pt"), for: .normal);
    }
    
    func resetTime()
    {
        sliderPlayer.value = 0;
        progressView.progress = 0;
        labelPosition.text = "0:00";
        labelRemaining.text = "0:00"
    }
    
    func updateMeta()
    {
        var title = "";
        var desc = "";
        var image = "";
        
        if let podcast = App.podcastPlaying
        {
            image = (App.cloudUrl + "/" + podcast.folder + "/" + podcast.image).replacingOccurrences(of: " ", with: "%20")
            title = podcast.title
            
        }
        
        if let episode = App.episodePlaying
        {
            desc = episode.title;
        }
        
        labelTitle.text = title;
        labelDesc.text = desc;
        
        if(image.count == 0)
        {
            imagePodcast.image = placeHolder
        }
        else
        {
            imagePodcast.sd_setImage(with: URL(string: image), placeholderImage: placeHolder, options: SDWebImageOptions.init(rawValue: 0), completed: nil)
        }
        
        if(App.player.state.isPlaying || App.player.state.isBuffering)
        {
            pauseUI()
        }
        else
        {
            playUI()
        }
        
        if(bottomController.currentState == CTBottomSlideController.SlideState.hidden || viewFloater.isHidden)
        {
            updatePanel()
            updateNavFrame()
            
            bottomController.closePanel()
            viewFloater.isHidden = false
        }
    }
    
    func updateTime()
    {
        let progress = Float(App.episodePosition / App.episodeDuration)
        progressView.progress = progress

        let value = progress * seekMax
        sliderPlayer.value = Float(value);
        
        labelPosition.text = Utils.formatDuration(App.episodePosition);
        labelRemaining.text = Utils.formatDuration(App.episodeDuration - App.episodePosition);
    }
    
    //MARK:- GADBannerViewDelegate
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView)
    {
        print("adViewDidReceiveAd")

        let hstate = bannerView.isHidden;
        bannerView.isHidden = false;
        
        updatePanel()
        updateNavFrame()

        if(hstate)
        {
            let state = bottomController.currentState;
            bottomController.currentState = CTBottomSlideController.SlideState.hidden
            if(state == CTBottomSlideController.SlideState.expanded )
            {
                bottomController?.expandPanel()
            }
            else if(state == CTBottomSlideController.SlideState.anchored )
            {
                bottomController?.anchorPanel()
            }
            else if(state == CTBottomSlideController.SlideState.collapsed )
            {
                bottomController?.closePanel()
            }
        }

        view.setNeedsUpdateConstraints()
        view.layoutIfNeeded()
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError)
    {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView)
    {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView)
    {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView)
    {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView)
    {
        print("adViewWillLeaveApplication")
    }
      
    func getDocumentsDirectory() -> URL {
        //        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //        return paths[0]
        
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath =  tDocumentDirectory.appendingPathComponent("MY_TEMP")
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    NSLog("Couldn't create folder in document directory")
                    NSLog("==> Document directory is: \(filePath)")
                    return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                }
            }
            
            NSLog("==> Document directory is: \(filePath)")
            return filePath
        }
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
