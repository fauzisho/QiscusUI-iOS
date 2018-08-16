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
}

class UIChatListPresenter {
    
    private var viewPresenter : UIChatListView?
    var rooms : [RoomModel] {
        get {
            return QiscusCore.storage.getRooms()
        }
    }
    
    init() {
        QiscusCore.delegate = self
    }
    
    func attachView(view : UIChatListView){
        viewPresenter = view
    }
    
    func detachView() {
        viewPresenter = nil
    }
    
    func loadChat() {
        QiscusCore.shared.getAllRoom(limit: 20, page: 1) { (rooms, error) in
            if let results = rooms {
                // load from qiscus core local storage
                self.viewPresenter?.didFinishLoadChat(rooms: results)
            }else {
                self.viewPresenter?.setEmptyData(message: "")
            }
        }
    }
}

extension UIChatListPresenter : QiscusCoreDelegate {
    func onRoom(_ room: RoomModel, gotNewComment comment: CommentModel) {
        // show in app notification
        print("got new comment: \(comment.message)")
        self.viewPresenter?.updateRooms(data: room)
        // MARK: TODO receive new comment, need trotle
        QiscusCore.shared.updateCommentReceive(roomId: room.id, lastCommentReceivedId: comment.id)
    }
    
    func onRoom(_ room: RoomModel, didChangeComment comment: CommentModel, changeStatus status: CommentStatus) {
        //
    }
    
    func onRoom(_ room: RoomModel, thisParticipant user: ParticipantModel, isTyping typing: Bool) {
        //
    }
    
    func onChangeUser(_ user: UserModel, onlineStatus status: Bool, whenTime time: Date) {
        //
    }
    
    func gotNew(room: RoomModel) {
        // add not if exist
        
    }

    func remove(room: RoomModel) {
        //
    }
}
