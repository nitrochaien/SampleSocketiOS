//
//  UsersViewController.swift
//  SocketChat
//
//  Created by Gabriel Theodoropoulos on 1/31/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblUserList: UITableView!
    private var users = [[String: AnyObject]]()
    private var nickname: String?
    private var configurationOK = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !configurationOK {
            configureNavigationBar()
            configureTableView()
            configurationOK = true
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if nickname == nil {
            askForNickname()
        }
    }
    
    func askForNickname() {
        let controller = UIAlertController(title: "Socket Chat", message: "Please enter a nickname: ", preferredStyle: .alert)
        controller.addTextField(configurationHandler: nil)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned self] (action) in
            if let text = controller.textFields?.first?.text {
                if text.isEmpty {
                    self.askForNickname()
                } else {
                    self.nickname = text
                    self.connectServer()
                }
            }
        }
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    func connectServer() {
        if let name = nickname {
            SocketIOManager.sharedInstance.connectServer(with: name) { [unowned self] (userList) in
                DispatchQueue.main.async {
                    self.users = userList
                    self.tblUserList.reloadData()
                    self.tblUserList.isHidden = false
                }
            }
        }
    }
    
    @IBAction func exitChat(_ sender: Any) {
        if let name = nickname {
            SocketIOManager.sharedInstance.exitChat(with: name) { [unowned self] in
                DispatchQueue.main.async {
                    self.nickname = nil
                    self.users.removeAll()
                    self.tblUserList.isHidden = true
                    self.askForNickname()
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "idSegueJoinChat" {
                let chatViewController = segue.destination as! ChatViewController
                chatViewController.nickname = nickname
            }
        }
    }

    // MARK: Custom Methods
    func configureNavigationBar() {
        navigationItem.title = "SocketChat"
    }
    
    func configureTableView() {
        tblUserList.delegate = self
        tblUserList.dataSource = self
        tblUserList.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "idCellUser")
        tblUserList.isHidden = true
        tblUserList.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: UITableView Delegate and Datasource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellUser") as! UserCell
        
        cell.textLabel?.text = users[indexPath.row]["nickname"] as? String
        if let status = users[indexPath.row]["isConnected"] as? Bool {
            cell.detailTextLabel?.text = status ? "Online" : "Offline"
            cell.detailTextLabel?.textColor = status ? .green : .red
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}
