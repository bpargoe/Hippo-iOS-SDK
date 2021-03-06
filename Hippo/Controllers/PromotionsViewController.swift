//
//  PromotionsViewController.swift
//  HippoChat
//
//  Created by Clicklabs on 12/23/19.
//  Copyright © 2019 CL-macmini-88. All rights reserved.
//

import UIKit

protocol PromotionCellDelegate : class
{
    //func getActionData(data:PromotionCellDataModel, viewController : UIViewController)
    func setData(data:PromotionCellDataModel)
    
    var cellIdentifier : String { get  }
    var bundle : Bundle? { get  }
    
}

typealias PromtionCutomCell = PromotionCellDelegate & UITableViewCell

class PromotionsViewController: UIViewController {

    @IBOutlet weak var promotionsTableView: UITableView!
    @IBOutlet var navigationBackgroundView: UIView!
    
    var data: [PromotionCellDataModel] = []
    weak var customCell: PromtionCutomCell?
    var refreshControl = UIRefreshControl()
    var count = 20
    var isMoreData = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
       // self.title = "ANNOUNCEMENTS"
       setupRefreshController()
        promotionsTableView.backgroundColor = HippoConfig.shared.theme.backgroundColor
//        navigationController?.navigationBar.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor
        
       // UINavigationBar.appearance().barTintColor = HippoConfig.shared.theme.headerTextColor
       // UINavigationBar.appearance().tintColor = HippoConfig.shared.theme.headerTextColor
       // UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : HippoConfig.shared.theme.headerTextColor]
        
       // navigationController?.navigationBar.tintColor = HippoConfig.shared.theme.headerTextColor
        //navigationBackgroundView.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor
        
        navigationBackgroundView.layer.shadowColor = UIColor.black.cgColor
        navigationBackgroundView.layer.shadowOpacity = 0.25
        navigationBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        navigationBackgroundView.layer.shadowRadius = 4
        navigationBackgroundView.backgroundColor = HippoConfig.shared.theme.headerBackgroundColor
        
        let backButton = UIButton(type: .custom)
        //backButton.setImage(UIImage(named: "BackWhite"), for: .normal)
        //backButton.setImage(UIImage(named: "BackWhite", in: FuguFlowManager.bundle, compatibleWith: nil), for: .normal)

        backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        if HippoConfig.shared.theme.leftBarButtonImage != nil {
            backButton.setImage(HippoConfig.shared.theme.leftBarButtonImage, for: .normal)
            backButton.tintColor = HippoConfig.shared.theme.headerTextColor
        }

        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        let item = UIBarButtonItem(customView: backButton)
        self.navigationItem.setLeftBarButton(item, animated: false)
        
        title = HippoConfig.shared.theme.promotionsAnnouncementsHeaderText
        
//        let btnleft : UIButton = UIButton(frame: CGRect(x:0, y:0, width:35, height:35))
//        btnleft.setTitleColor(UIColor.white, for: .normal)
//        btnleft.contentMode = .left
//        //btnleft.setImage(UIImage(named :"home"), for: .normal) //parent app asset
//        //btnleft.setImage(UIImage(named :"backButtonNormalStateIcon"), for: .normal)//hippo asset
//        btnleft.setImage(UIImage(named: "backButtonNormalStateIcon", in: FuguFlowManager.bundle, compatibleWith: nil), for: .normal)
//        btnleft.addTarget(self, action: #selector(backButtonClicked), for: .touchDown)
//        let backBarButon: UIBarButtonItem = UIBarButtonItem(customView: btnleft)
//        backBarButon.tintColor = UIColor.black
//        self.navigationItem.setLeftBarButtonItems([backBarButon], animated: false)
        
    promotionsTableView.register(UINib(nibName: "PromotionTableViewCell", bundle: FuguFlowManager.bundle), forCellReuseIdentifier: "PromotionTableViewCell")
        promotionsTableView.rowHeight = UITableView.automaticDimension
        promotionsTableView.estimatedRowHeight = 50
        if let c = customCell {
          promotionsTableView.register(UINib(nibName: c.cellIdentifier, bundle: c.bundle), forCellReuseIdentifier: c.cellIdentifier)
        }
        // Do any additional setup after loading the view.
    }
    
   
    
    @objc func backButtonClicked()
    {
        HippoConfig.shared.notifiyDeinit()
        _ = self.navigationController?.dismiss(animated: true, completion: nil)
    }
//    @objc func backButtonClicked() {
//        _ = self.navigationController?.dismiss(animated: true, completion: nil)
//    }
    
    internal func setupRefreshController() {
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .themeColor
        promotionsTableView.backgroundView = refreshControl
        refreshControl.addTarget(self, action: #selector(reloadrefreshData(refreshCtrler:)), for: .valueChanged)
    }
    
    @objc func reloadrefreshData(refreshCtrler: UIRefreshControl) {
        isMoreData = false
        self.getAnnouncements(endOffset:19, startOffset: 0)
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.setTheme()
        self.getAnnouncements(endOffset: 19, startOffset: 0)
    }
    
    func getAnnouncements(endOffset:Int,startOffset:Int) {
        
        let params = ["end_offset":"\(endOffset)","start_offset":"\(startOffset)","en_user_id":HippoUserDetail.fuguEnUserID,"app_secret_key":HippoConfig.shared.appSecretKey]
        
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: params, extendedUrl: AgentEndPoints.getAnnouncements.rawValue) { (response, error, _, statusCode) in
            
            if error == nil
            {
                self.refreshControl.endRefreshing()
                let r = response as? NSDictionary
                if let arr = r!["data"] as? NSArray
                {
                    print("push response>>> \(arr)")
                    
                    if startOffset == 0 || arr.count >= 19
                    {
                        if startOffset == 0 && self.data.count > 0
                        {
                            self.data.removeAll()
                        }
                        
                        for item in arr
                        {
                            let i = item as! [String:Any]
                            let dataNew = PromotionCellDataModel(dict:i)
                            print(dataNew)
                            self.data.append(dataNew!)
                        }
                    }
                    else
                    {
                        self.isMoreData = true
                    }
                    
                }
               
            }
             self.promotionsTableView.reloadData()
        }
            
    }

}



extension PromotionsViewController: UITableViewDelegate,UITableViewDataSource
{
    func EmptyMessage(message:String)
    {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.textColor = UIColor.black40
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.systemFont(ofSize: 15)//UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        promotionsTableView.backgroundView = messageLabel;
        promotionsTableView.separatorStyle = .none;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if data.count > 0
        {
            promotionsTableView.backgroundView = nil
            return 1
           
        }
        else
        {
            isMoreData = true
            let message = "No announcements yet"
            self.EmptyMessage(message: message)
            promotionsTableView.backgroundColor = UIColor.clear
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let c = customCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: c.cellIdentifier, for: indexPath) as? PromtionCutomCell else {
                return UITableView.defaultCell()
            }
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
//            cell.promotionTitle.text = "This is a new tittle"
//            cell.descriptionLabel.text = "This is description of promotion in a new format"
         //   cell.set(data: data[indexPath.row])
            
            return cell
        } else {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionTableViewCell", for: indexPath) as? PromotionTableViewCell else {
            return UITableView.defaultCell()
        }
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
      
        cell.set(data: data[indexPath.row])
        
        return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

//        let h = data[indexPath.row]
//        print(h.cellHeight)
//        return h.cellHeight

       // return 266
        
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //HippoConfig.shared.delegate?.promotionMessageRecievedWith(response:[:], viewController: self)
        let d = data[indexPath.row]
        if d.deepLink.isEmpty
        {
            
        }
        else
        {
            if d.skipBot.isEmpty
            {
                HippoConfig.shared.isSkipBot = false
            }
            else
            {
                HippoConfig.shared.isSkipBot = true
            }
            //HippoConfig.shared.openChatScreen(withLabelId: Int(data[indexPath.row].channelID) ?? 0)
            
            let labelID = d.channelID
            let conversationViewController = ConversationsViewController.getWith(labelId:"\(labelID)")
        self.navigationController?.pushViewController(conversationViewController, animated: true)
            
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if indexPath.row + 1 == self.data.count {
            print("do something")
            if !isMoreData
            {
                let previousOffset = count
                count = 19 + count
                getAnnouncements(endOffset: count, startOffset: previousOffset)
                promotionsTableView.backgroundView = nil
            }
        }
    }
   
}


    

