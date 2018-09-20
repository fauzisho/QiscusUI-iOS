//
//  UIChatListPresenter.swift
//  QiscusUI
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation
import QiscusCore

protocol UIChatListView : BaseView {
    func didFinishLoadChat(rooms : [RoomModel])
    func updateRooms(data: RoomModel)
    func didUpdate(user: MemberModel, isTyping typing: Bool, in room: RoomModel)
}

class UIChatListPresenter {
    
    private var viewPresenter : UIChatListView?
    var rooms : [RoomModel] = [RoomModel]()
    
    init() {
        QiscusUIManager.shared.uidelegate = self
    }
    
    func attachView(view : UIChatListView){
        viewPresenter = view
        QiscusCore.shared.isOnline(true)
    }
    
    func detachView() {
        viewPresenter = nil
    }
    
    func loadChat() {
        self.loadFromLocal()
        self.loadFromServer()
    }
    
    private func loadFromLocal() {
        // get from local
        self.rooms = QiscusCore.database.room.all()
        self.viewPresenter?.didFinishLoadChat(rooms: self.rooms)
    }
    
    private func loadFromServer() {
        // check update from server
        QiscusCore.shared.getAllRoom(limit: 50, page: 1) { (rooms, meta, error) in
            if let results = rooms {
                self.rooms = results
                self.viewPresenter?.didFinishLoadChat(rooms: results)
            }else {
                self.viewPresenter?.setEmptyData(message: "")
            }
        }
    }
}

extension UIChatListPresenter : UIChatDelegate {
    func onChange(user: MemberModel, isOnline online: Bool, at time: Date) {
        //
    }
    
    func onRoom(_ room: RoomModel, gotNewComment comment: CommentModel) {
        // show in app notification
        print("got new comment: \(comment.message)")
        self.viewPresenter?.updateRooms(data: room)

        // MARK: TODO check room already exist?
        if !rooms.contains(where: { $0.id == room.id}) {
            loadFromServer()
        }
        
        // MARK: TODO receive new comment, need trotle
        guard let user = QiscusCore.getProfile() else { return }
        // no update if your comment
        if user.email != comment.userEmail {
            QiscusCore.shared.updateCommentReceive(roomId: room.id, lastCommentReceivedId: comment.id)
        }
    }
    
    func onRoom(_ room: RoomModel, didChangeComment comment: CommentModel, changeStatus status: CommentStatus) {
        //
    }
    
    func onRoom(_ room: RoomModel, thisParticipant user: MemberModel, isTyping typing: Bool) {
        self.viewPresenter?.didUpdate(user: user, isTyping: typing, in: room)
    }
    
    func gotNew(room: RoomModel) {
        // add not if exist
    }

    func remove(room: RoomModel) {
        //
    }
}
