//
//  BottomSlideController.swift
//  GPSControl Pro
//
//  Created by Gio Andriadze on 6/5/17.
//  Copyright © 2017 Casatrade Ltd. All rights reserved.
//

import UIKit

private var ContentOffsetKVO = 0
private var ConstraintConstantKVO = 1;
@objcMembers
public class CTBottomSlideController : NSObject, UIGestureRecognizerDelegate
{
    public enum SlideState
    {
        case collapsed
        case expanded
        case anchored
        case hidden
    }
    
    var topConstraint:NSLayoutConstraint!;
    
    weak var view:UIView!;
    weak var bottomView:UIView!;
    weak var scrollView:UIScrollView?;
    
    weak var navigationController:UINavigationController?;
    
    private var initalLocation:CGFloat!;
    private var initialTouchLocation:CGFloat!;
    
    private var panGestureRecognizer:UIPanGestureRecognizer!;
    
    private var topExpanded:CGFloat = 1110;
    private var topAnchored:CGFloat = 1110;
    private var topClosed:CGFloat = 1110;
    
    private var isInMotion = false;
    
    public var currentState = SlideState.hidden;
    public weak var delegate:CTBottomSlideDelegate?;
    public var isPanelExpanded:Bool = false;
    
    public var onPanelExpanded: (() -> Void)?
    public var onPanelClosed: (() -> Void)?
    public var onPanelCollapsed: (() -> Void)?
    public var onPanelAnchored: (() -> Void)?
    public var onPanelMoved: ((CGFloat) -> Void)?
    
    
    public init(topConstraint:NSLayoutConstraint, parent: UIView, bottomView: UIView, navController:UINavigationController?)
    {
        super.init()
        
        self.topConstraint = topConstraint;
        self.view = parent;
        self.bottomView = bottomView;
        
        if(navController != nil)
        {
            self.set(navController: navController!);
        }
        
        self.initBottomPanel(shouldAnimate: false)
        addConstraintChangeKVO()
    }
    
    deinit
    {
        print("Bottom panel deiniting");
        removeConstraintChangeKVO()
        
        if scrollView != nil{
            self.removeKVO(scrollView: scrollView!)
        }
        if(panGestureRecognizer != nil){
            bottomView?.removeGestureRecognizer(panGestureRecognizer)
        }
        
        self.bottomView = nil;
        self.view = nil;
        self.topConstraint = nil;
    }
    
    public func viewWillTransition(to size:CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        //Start Animation to new Size
        reinitBottomController(with: size)
        coordinator.animate(alongsideTransition: nil, completion: {
            _ in
            //Need to reinit to acquire new height of Status bar, Navigation bar and so on/
            self.initBottomPanel(shouldAnimate: true)
        })
    }
    
    
    //MARK: Setters
    public func set(navController: UINavigationController)
    {
        self.navigationController = navController;
    }
    
    public func set(table:UITableView)
    {
        set(scrollView: table)
    }
    
    public func set(collectionView: UICollectionView) {
        set(scrollView: collectionView)
    }
    
    public func set(scrollView: UIScrollView){
        if (self.scrollView != nil){
            self.removeKVO(scrollView: self.scrollView!)
        }
        
        self.scrollView = scrollView;
        //scrollView!.panGestureRecognizer.require(toFail: panGestureRecognizer)
        self.addKVO(scrollView: self.scrollView!);
    }
    
    
    
    
    //MARK: Toggles
    public func expandPanel()
    {
        if(currentState != .expanded)
        {
            performExpandPanel()
        }
    }
    
    public func anchorPanel()
    {
        if(currentState != .anchored)
        {
            movePanelToAnchor()
        }
    }
    
    public func closePanel()
    {
        if(currentState != .collapsed)
        {
            performClosePanel()
        }
    }
    
    public func hidePanel()
    {
        if(currentState != .hidden)
        {
            performHidePanel()
        }
    }
    
    public func setSlideEnabled(_ enabled: Bool)
    {
        self.panGestureRecognizer?.isEnabled = enabled;
        
    }
    
    
    //MARK: init
    private func reinitBottomController(with size:CGSize)
    {
        if(currentState == .expanded)
        {
            self.topConstraint.constant = self.topExpanded;
        }
        else if(currentState == .anchored)
        {
            self.topConstraint.constant = self.topAnchored;
        }
        else if(currentState == .collapsed)
        {
            topConstraint.constant = self.topClosed
            
            //performClosePanel()
        }
        else
        {
            performHidePanel()
        }
        
        bottomView.layoutIfNeeded()
    }
    
    private func initBottomPanel(shouldAnimate:Bool)
    {
        panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.moveViewWithGestureRecognizer(panGestureRecognizer:)))
        panGestureRecognizer.delegate = self;
        bottomView.addGestureRecognizer(panGestureRecognizer);
        updateConstraint(shouldAnimate: shouldAnimate);
    }
    
    public func updateConstraint(shouldAnimate:Bool) -> Void
    {
        if(currentState == .expanded)
        {
            if(shouldAnimate)
            {
                performExpandPanel()
            }
            else
            {
                self.topConstraint.constant = self.topExpanded;
            }
        }
        else if(currentState == .anchored)
        {
            if(shouldAnimate)
            {
                movePanelToAnchor()
            }
            else
            {
                self.topConstraint.constant = self.topAnchored;
            }
            
        }
        else if(currentState == .collapsed)
        {
            if(shouldAnimate)
            {
                performClosePanel()
            }
            else
            {
                topConstraint.constant = self.topClosed
            }
        }
        else
        {
            performHidePanel()
        }
        
        bottomView.layoutIfNeeded()
    }
    
    public func setExpandedTopMargin(pixels: CGFloat)
    {
        var checkedPixels = pixels;
        if(checkedPixels < 0){
            checkedPixels = 0;
        }
        
        self.topExpanded = pixels;
    }
    
    public func setAnchoredTopMargin(pixels: CGFloat)
    {
        var checkedPixels = pixels;
        if(checkedPixels < 0){
            checkedPixels = 0;
        }
        
        self.topAnchored = pixels
    }
    
    public func setClosedTopMargin(pixels: CGFloat)
    {
        var checkedPixels = pixels;
        if(checkedPixels < 0){
            checkedPixels = 0;
        }
        
        self.topClosed = pixels;
    }
    
    
    //MARK: Gesture recognition
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if(currentState != .collapsed && scrollView != nil){
            if let tempTableView:UITableView = scrollView as? UITableView{
                
                let check = tempTableView.isEditing;
                let locationInTable = touch.location(in: bottomView);
                if(check && tempTableView.frame.contains(locationInTable)){
                    return false;
                }
            }
        }
        
        return true;
    }
    
    
    public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        initalLocation = topConstraint.constant;
        initialTouchLocation = touches.first?.location(in: self.view).y
    }
    
    @objc func moveViewWithGestureRecognizer(panGestureRecognizer:UIPanGestureRecognizer ){
        let touchLocation:CGPoint = panGestureRecognizer.location(in: self.view);
        if initialTouchLocation == nil
        {
            initialTouchLocation = touchLocation.y;
            initalLocation = topConstraint.constant;
        }
        
        if(panGestureRecognizer.state == .changed)
        {
            var pos = initalLocation - (initialTouchLocation - touchLocation.y)
            
            /*
             if(topConstraint.constant < self.topExpanded)
             {
             topConstraint.constant = self.topExpanded;
             }
             else if(topConstraint.constant > self.topClosed)
             {
             topConstraint.constant = self.topClosed;
             }
             else if(topConstraint.constant < self.topAnchored + 23)
             {
             //topConstraint.constant = self.topAnchored;
             }
             */
            
            if(!panGestureRecognizer.isUp(theViewYouArePassing: self.view))
            {
                //up
                if(pos < self.topExpanded)
                {
                    pos = self.topExpanded;
                }
            }
            else
            {
                //dn
                if(pos > self.topClosed)
                {
                    pos = self.topClosed;
                }
            }
            
            topConstraint.constant = pos;
            
            isInMotion = true;
            
            UIView.animate(withDuration: 0.1, animations: {
                self.view.layoutIfNeeded();
            }, completion: { _ in
                self.isInMotion = false;
            });
            
            
        }
        else if(panGestureRecognizer.state == .ended){
            
            if(!panGestureRecognizer.isUp(theViewYouArePassing: self.view))
            {
                //up
                if(initialTouchLocation - touchLocation.y > 23)
                {
                    if(topConstraint.constant < self.topAnchored - 23)
                    {
                        self.performExpandPanel()
                    }
                    else
                    {
                        self.movePanelToAnchor()
                    }
                }
                else
                {
                    if(topConstraint.constant > self.topAnchored + 23)
                    {
                        self.performClosePanel()
                        
                        self.delegate?.didPanelClosed();
                        self.onPanelClosed?();
                        
                    }
                    else
                    {
                        self.movePanelToAnchor()
                    }
                }
            }
            else
            {
                //dn
                if(topConstraint.constant > self.topAnchored + 23)
                {
                    self.performClosePanel()
                    
                    self.delegate?.didPanelClosed();
                    self.onPanelClosed?();
                }
                else
                {
                    self.movePanelToAnchor()
                }
            }
            initialTouchLocation = nil;
        }
        
    }
    
    
    private func movePanel(by offset:CGFloat)
    {
        if(initalLocation == nil)
        {
            initalLocation = topConstraint.constant
        }
        
        topConstraint.constant = (initalLocation - offset);
        
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded();
        }, completion: { _ in
            self.isInMotion = false;
        });
        
    }
    
    private func movePanelToAnchor()
    {
        currentState = .anchored
        
        isPanelExpanded = true;
        isInMotion = true;
        
        self.topConstraint.constant = self.topAnchored;
        
        self.view.setNeedsLayout();
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded();
            
        }, completion: { _ in
            self.isInMotion = false;
        });
        
        
        delegate?.didPanelAnchor();
        self.onPanelAnchored?();
    }
    
    private func performExpandPanel()
    {
        
        currentState = .expanded;
        isInMotion = true;
        
        isPanelExpanded = true;
        self.topConstraint.constant = self.topExpanded;
        
        self.view.setNeedsLayout();
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded();
        }, completion: { _ in
            self.isInMotion = false;
        });
        
        delegate?.didPanelExpand();
        self.onPanelExpanded?();
    }
    
    
    private func performClosePanel()
    {
        currentState = .collapsed
        isInMotion = true;
        
        isPanelExpanded = false;
        self.view.layoutIfNeeded();
        
        UIView.animate(withDuration: 0.25, animations: {
            self.topConstraint.constant = self.topClosed;
            self.view.layoutIfNeeded();
        }, completion: { _ in
            self.isInMotion = false;
        });
        
        delegate?.didPanelCollapse();
        self.onPanelCollapsed?();
    }
    
    private func performHidePanel()
    {
        currentState = .hidden
        isInMotion = true;
        isPanelExpanded = false;
        self.view.layoutIfNeeded();
        
        UIView.animate(withDuration: 0.25, animations: {
            self.topConstraint.constant = self.view.frame.height;
            self.view.layoutIfNeeded();
        }, completion: { _ in
            self.isInMotion = false;
        });
        
        delegate?.didPanelCollapse();
        self.onPanelCollapsed?();
        
    }
    
    private func addConstraintChangeKVO()
    {
        topConstraint?.addObserver(self, forKeyPath: "constant", options: [.initial, .new], context: &ConstraintConstantKVO);
    }
    
    private func removeConstraintChangeKVO()
    {
        topConstraint?.removeObserver(self, forKeyPath: "constant", context: &ConstraintConstantKVO);
    }
    
    //MARK: Tableview
    private func removeKVO(scrollView: UIScrollView) {
        scrollView.removeObserver(
            self,
            forKeyPath: "contentOffset",
            context: &ContentOffsetKVO
        )
    }
    
    private func addKVO(scrollView: UIScrollView) {
        scrollView.addObserver(
            self,
            forKeyPath: "contentOffset",
            options: [.initial, .new],
            context: &ContentOffsetKVO
        )
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
            
        case .some("contentOffset"):
            checkOffset();
        case .some("constant"):
            firePanelMoved();
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
    }
    
    private func firePanelMoved()
    {
        let offset:CGFloat = 1 - (topConstraint.constant/self.topClosed);
        self.delegate?.didPanelMove(panelOffset: offset)
        self.onPanelMoved?(offset)
        
    }
    
    func checkOffset()
    {
        if scrollView == nil || isInMotion{
            return
        }
        
        //    if(scrollView!.contentOffset.y < 0)
        //    {
        //        scrollView!.contentOffset.y = 0
        //        scrollView?.isUserInteractionEnabled = false
        //    }
        
        
        if(scrollView!.contentOffset.y < -50)
        {
            if(currentState == .anchored)
            {
                self.closePanel();
            }
            else if(currentState == .expanded)
            {
                self.movePanelToAnchor()
            }
        }
        else if(scrollView!.contentOffset.y > 50)
        {
            if(currentState == .anchored || self.topAnchored <= self.topExpanded)
            {
                self.expandPanel()
            }
            else if(currentState == .collapsed)
            {
                self.movePanelToAnchor()
            }
        }
    }
    
    
}
