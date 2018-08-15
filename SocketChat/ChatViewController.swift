//
//  ChatViewController.swift
//  SocketChat
//
//  Created by Gabriel Theodoropoulos on 1/31/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var lblOtherUserActivityStatus: UILabel!
    @IBOutlet weak var tvMessageEditor: UITextView!
    @IBOutlet weak var conBottomEditor: NSLayoutConstraint!
    @IBOutlet weak var lblNewsBanner: UILabel!
    
    var nickname: String!
    private var chatMessages = [[String: String]]()
    private var bannerLabelTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShowNotification(notification:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHideNotification(notification:)), name: .UIKeyboardDidHide, object: nil)
        
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeGestureRecognizer.direction = .down
        swipeGestureRecognizer.delegate = self
        view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTableView()
        configureNewsBannerLabel()
        configureOtherUserActivityLabel()
        
        tvMessageEditor.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SocketIOManager.sharedInstance.getChatMessage { (info) in
            DispatchQueue.main.async {
                self.chatMessages.append(info)
                self.tblChat.reloadData()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: IBAction Methods
    @IBAction func sendMessage(_ sender: Any) {
        if !tvMessageEditor.text.isEmpty {
            SocketIOManager.sharedInstance.send(message: tvMessageEditor.text, to: nickname)
            tvMessageEditor.text = ""
            tvMessageEditor.resignFirstResponder()
        }
    }
    
    // MARK: Custom Methods
    func configureTableView() {
        tblChat.delegate = self
        tblChat.dataSource = self
        tblChat.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "idCellChat")
        tblChat.estimatedRowHeight = 90.0
        tblChat.rowHeight = UITableViewAutomaticDimension
        tblChat.tableFooterView = UIView(frame: .zero)
    }
    
    func configureNewsBannerLabel() {
        lblNewsBanner.layer.cornerRadius = 15.0
        lblNewsBanner.clipsToBounds = true
        lblNewsBanner.alpha = 0.0
    }
    
    func configureOtherUserActivityLabel() {
        lblOtherUserActivityStatus.isHidden = true
        lblOtherUserActivityStatus.text = ""
    }
    
    @objc func handleKeyboardDidShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                conBottomEditor.constant = keyboardFrame.size.height
                view.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleKeyboardDidHideNotification(notification: NSNotification) {
        conBottomEditor.constant = 0
        view.layoutIfNeeded()
    }
    
    func scrollToBottom() {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.chatMessages.count > 0 {
                let lastRowIndexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
                self.tblChat.scrollToRow(at: lastRowIndexPath, at: .bottom, animated: true)
            }
        }
    }
    
    func showBannerLabelAnimated() {
        UIView.animate(withDuration: 0.75, animations: {
            self.lblNewsBanner.alpha = 1.0
        }) { [unowned self] (finished) in
            self.bannerLabelTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { [unowned self] (timer) in
                if self.bannerLabelTimer != nil {
                    self.bannerLabelTimer.invalidate()
                    self.bannerLabelTimer = nil
                }
                
                UIView.animate(withDuration: 0.75, animations: {
                    self.lblNewsBanner.alpha = 0.0
                })
            })
        }
    }

    @objc func dismissKeyboard() {
        if tvMessageEditor.isFirstResponder {
            tvMessageEditor.resignFirstResponder()
        }
    }

    // MARK: UITableView Delegate and Datasource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellChat") as! ChatCell
        
        let currentChatMessage = chatMessages[indexPath.row]
        if let senderNickname = currentChatMessage["nickname"],
            let message = currentChatMessage["message"],
            let messageDate = currentChatMessage["date"] {
            if senderNickname == nickname {
                cell.lblChatMessage.textAlignment = .right
                cell.lblMessageDetails.textAlignment = .right
                cell.lblChatMessage.textColor = lblNewsBanner.backgroundColor
            }
            cell.lblChatMessage.text = message
            cell.lblMessageDetails.text = "by \(senderNickname.uppercased()) @ \(messageDate)"
            cell.lblChatMessage.textColor = .gray
        }
        
        return cell
    }
    
    // MARK: UITextViewDelegate Methods
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    // MARK: UIGestureRecognizerDelegate Methods
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
