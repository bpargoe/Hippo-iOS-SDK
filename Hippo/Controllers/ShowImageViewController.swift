//
//  ShowImageViewController.swift
//  ChitChapp
//
//  Created by Click Labs 65 on 7/23/15.
//  Copyright (c) 2015 click Labs. All rights reserved.
//

import UIKit

class ShowImageViewController: UIViewController , UIScrollViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var imageView: So_UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var crossButton: UIButton!
    var imageToShow: UIImage?
    var imageURLString = ""
    var localImagePath: String? = nil
    
    // define a variable to store initial touch position
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        crossButton.layer.cornerRadius = 5//31.5
        
        let gesture = UIPanGestureRecognizer(target: self, action:(#selector(self.handleGesture(_:))))
//        slideUpView.addGestureRecognizer(gesture)
//        slideUpView.userInteractionEnabled = true
        self.view.addGestureRecognizer(gesture)
        self.view.isUserInteractionEnabled = true
        gesture.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if imageToShow != nil {
            self.imageView.image = imageToShow
        } else if imageURLString.isEmpty == false,
            let url = URL(string: imageURLString) {
            let placeHolderImage = HippoConfig.shared.theme.placeHolderImage
            imageView.kf.setImage(with: url, placeholder: placeHolderImage)
        } else if let localPath = localImagePath, doesFileExistsAt(filePath: localPath) {
            self.imageView.image = UIImage(contentsOfFile: localPath)
        }
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5
        scrollView.flashScrollIndicators()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      return self.imageView
   }
    func doesFileExistsAt(filePath: String) -> Bool {
        return (try? Data(contentsOf: URL(fileURLWithPath: filePath))) != nil
    }
    
    
    @IBAction func crossButtonTapped(_ sender :AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
   
   // MARK: - Type Methods
   class func getFor(imageUrlString: String) -> ShowImageViewController {
      let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
      let vc = storyboard.instantiateViewController(withIdentifier: "ShowImageViewController") as! ShowImageViewController
      vc.imageURLString = imageUrlString
      return vc
   }
    class func getFor(localPath: String) -> ShowImageViewController {
        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "ShowImageViewController") as! ShowImageViewController
        vc.localImagePath = localPath
        return vc
    }
    
    //@IBAction func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
    //func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
    @objc func handleGesture(_ sender: UIPanGestureRecognizer) {
        
        let touchPoint = sender.location(in: self.view?.window)
        if sender.state == UIGestureRecognizer.State.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizer.State.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizer.State.ended || sender.state == UIGestureRecognizer.State.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }
    
}
