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
        QiscusCore.shared.isOnline(true)
    }
    
    func detachView() {
        viewPresenter = nil
    }
    
    func loadChat() {
        QiscusCore.shared.getAllRoom(limit: 50, page: 1) { (rooms, meta, error) in
            if let results = rooms {
                self.viewPresenter?.didFinishLoadChat(rooms: results)
            }else {
                self.viewPresenter?.setEmptyData(message: "")
            }
        }
    }
}

extension UIChatListPresenter : QiscusCoreDelegate {
    func onChange(user: MemberModel, isOnline online: Bool, at time: Date) {
        //
    }
    
    func onRoom(_ room: RoomModel, gotNewComment comment: CommentModel) {
        // show in app notification
        print("got new comment: \(comment.message)")
        // self.viewPresenter?.updateRooms(data: room)
        // MARK: TODO receive new comment, need trotle
        QiscusCore.shared.updateCommentReceive(roomId: room.id, lastCommentReceivedId: comment.id)
    }
    
    func onRoom(_ room: RoomModel, didChangeComment comment: CommentModel, changeStatus status: CommentStatus) {
        //
    }
    
    func onRoom(_ room: RoomModel, thisParticipant user: MemberModel, isTyping typing: Bool) {
        //
    }
    
    func gotNew(room: RoomModel) {
        // add not if exist
    }

    func remove(room: RoomModel) {
        //
    }
}
