//
//  UIChatListViewController.swift
//  QiscusUI
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore

open class UIChatListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let presenter : UIChatListPresenter = UIChatListPresenter()
    public var rooms : [RoomModel] {
        get {
            return presenter.rooms
        }
    }
    public init() {
        super.init(nibName: "UIChatListViewController", bundle: QiscusUI.bundle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.loadChat()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UIChatListViewCell.nib, forCellReuseIdentifier: UIChatListViewCell.identifier)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.attachView(view: self)
        self.presenter.loadChat()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.detachView()
    }
    
}

extension UIChatListViewController : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIChatListViewCell.identifier, for: indexPath) as! UIChatListViewCell
        let data = self.rooms[indexPath.row]
        cell.data = data
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatView = UIChatViewController()
        chatView.room = self.rooms[indexPath.row]
        self.navigationController?.pushViewController(chatView, animated: true)
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }

    private func getIndexpath(byRoom data: RoomModel) -> IndexPath? {
        // get current index
        for (i,r) in self.rooms.enumerated() {
            if r.id == data.id {
                return IndexPath(row: i, section: 0)
            }
        }
        return nil
    }
}

extension UIChatListViewController : UIChatListView {
    func didUpdate(user: MemberModel, isTyping typing: Bool, in room: RoomModel) {
        let indexPath = getIndexpath(byRoom: room)
        let isVisible = self.tableView.indexPathsForVisibleRows?.contains{$0 == indexPath}
        if let v = isVisible, let index = indexPath, v == true {
            self.tableView.reloadRows(at: [index], with: UITableViewRowAnimation.none)
        }
    }
    
    func updateRooms(data: RoomModel) {
        self.tableView.reloadData()
        // improve only reload for new cell with room data
//        let indexPath = getIndexpath(byRoom: data)
//        let isVisible = self.tableView.indexPathsForVisibleRows?.contains{$0 == indexPath}
//        if let v = isVisible, let index = indexPath, v == true {
//            let newIndex = IndexPath(row: 0, section: 0)
//            self.tableView.reloadRows(at: [index], with: UITableViewRowAnimation.none)
//            self.tableView.moveRow(at: index, to: newIndex)
//        }
    }
    
    func didFinishLoadChat(rooms: [RoomModel]) {
        // 1st time load data
        self.tableView.reloadData()
    }
    
    func startLoading(message: String) {
        //
    }
    
    func finishLoading(message: String) {
        //
    }
    
    func setEmptyData(message: String) {
        //
    }
}
